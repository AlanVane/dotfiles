# Fontconfig 配置评审报告

> 评审对象：`font/.config/fontconfig/` 下的全部配置文件（约 700 行）
> 评审方式：通读全部源码 + 在 Arch Linux 本机用 `fc-conflist` / `fc-match` / `fc-pattern` 做实际生效验证
> 评审日期：2026-10-16

---

## 一、总览

```
font/.config/fontconfig/
├── fonts.conf                    # 主配置（361 行）：渲染参数 + 通用字体族优先级 + CJK 分语言策略
├── web-ui-fonts.conf             # CSS UI 字体关键字映射（ui-monospace / -apple-system 等）
├── web.conf                      # 网页惯用字体映射（Menlo、YouTube Noto）
├── source-han-for-noto-cjk.conf  # Noto CJK → 思源（Source Han）统一映射
└── win-replacements.conf         # Windows/苹果字体名 → 思源系列替代
```

部署方式：`~/.config/fontconfig/` 下全部是**指向 dotfiles 仓库的符号链接**（stow 管理），README.org 也明确记录了"配置必须放在 `~/.config/fontconfig/fonts.conf`，放别处是废弃用法"——这点与 fontconfig 官方文档一致，是正确的前提认知。

**总体评价：这是一份高质量、明显经过实战打磨的配置。** 它大量借鉴并整理自 lilydjwg 的 fontconfig 配置（README 里有出处），但在中文分区、字体版本（Font Awesome 7）、gvim/Twemoji 的 workaround 等细节上做了自己的本地化。逻辑清晰、注释充分（每个决策都写了"为什么"），且在本机实测全部按预期生效。

---

## 二、加载链路与生效机制（实测）

`fc-conflist` 确认的实际加载顺序：

```
/etc/fonts/conf.d/10-* … 49-*   ← 发行版默认（hinting、metric-aliases、nonlatin 等）
  ↓
~/.config/fontconfig/
    web-ui-fonts.conf → web.conf → source-han-for-noto-cjk.conf → win-replacements.conf
    → fonts.conf（主文件，通过 <include> 引入上面 4 个）
  ↓
/etc/fonts/conf.d/50-user.conf … 90-synthetic.conf
/etc/fonts/fonts.conf
```

两个关键机制值得注意：

1. **用户配置与系统配置是叠加关系，不是替换。** 主文件里 `<include ignore_missing="yes">conf.d</include>` 引入的是 `~/.config/fontconfig/conf.d`（相对路径相对于配置文件自身目录解析），这个空目录是留给用户自己扩展的挂载点——设计得很干净。
2. **替代规则靠 `assign` 抢占生效。** 比如 `win-replacements.conf` 里"微软雅黑"用 `mode="assign"` 把 family 列表**整个替换**成思源黑体，这样排在后面的发行版规则（如 `65-nonlatin.conf` 里对 Microsoft YaHei 的映射）因为再也匹配不到原始 family 名而失效。实测确认：`fc-match 微软雅黑` → 思源黑体，而非 WenQuanYi。**这是"用规则顺序 + 替换语义压制发行版默认"的精髓手法。**

---

## 三、精华详解

### 1. 渲染参数基线（fonts.conf 12–47 行）——"克制"

```xml
autohint=false, hinting=true, hintstyle=hintslight,
antialias=true, lcdfilter=lcddefault, rgba=rgb
```

这是现代 FreeType2 的标准最优解，注释里把每条的理由都写了：

- **关 autohint**：FreeType2 的原生微调已足够好，autohint 反而会破坏字体设计者的 hinting；
- **hintslight 而非 hintfull**：full 会为了像素对齐牺牲字形细节（竖线被拉伸、点阵丢失）。注释还指出"如果 DPI ≥ 300 可以干脆关 hinting"——这是对 HiDPI 用户的正确建议；
- **rgba=rgb + lcddefault**：现代显示器基本都是 RGB 条状排列，这是子像素渲染（Sub-pixel Rendering）的正确配置，能显著提升小字号清晰度（副作用是轻微色晕，滚动时文字有彩色边缘——配置里没提但属已知权衡）。

### 2. 例外规则的"外科手术式"打法（49–76 行）

```xml
<!-- 全局关闭内嵌点阵，唯独放行 Twemoji -->
<test name="family" compare="not_eq"><string>Twemoji</string></test>
→ embeddedbitmap=false
```

以及 gvim 里 Twemoji 斜体显示空白的 workaround（只对 `prgname=gvim` + Twemoji 关 antialias）。注释里还记录了更宽泛写法（`qual="all"`）在 Firefox/Chrome 上的副作用排查过程——**这是典型的"踩坑-收敛-注释留痕"工程实践，是这份配置最有价值的部分**：未来自己或别人改动时不会重蹈覆辙。

### 3. 三通用族（generic family）的优先级栈（115–170 行）

以 sans-serif 为例：

```
sans-serif → DejaVu Sans → 思源黑体 → Twemoji → Font Awesome 7 Free/Brands
```

这个设计的精妙之处：

- **拉丁优先、CJK 兜底**：DejaVu 排第一只负责拉丁字母和符号，汉字逐字符 fallback 到思源黑体。实测 `fc-match sans-serif:lang=zh-cn` 返回 DejaVu Sans 是正常的——fc-match 返回的是栈顶字体，实际渲染时按字形逐个回退；
- **把 emoji 和图标字体塞进每个通用族**：意味着任何请求 sans-serif/serif/monospace 的程序（终端、浏览器、GUI 应用）都能直接渲染出彩色 emoji 和 Font Awesome 图标，不用程序自己配 fallback 链。**这是很多人折腾 Pango/Xft fallback 都没解决的问题，这里用一个列表优雅解决；**
- **serif 也配了 Twemoji 和 FA**：不因"衬线体不该有 emoji"这种洁癖而牺牲实际显示效果——实用主义。

另外 `system-ui` → prepend `sans-serif` 的映射，覆盖了越来越多 Chromium/Electron 应用使用的 `system-ui` 关键字。

### 4. "不用 Noto Sans CJK SC，用思源黑体"的深思熟虑（172–173 行注释）

> 不使用 Noto Sans CJK SC 是因为这个字体会在特定情况下显示片假名
> 用 SC 名称是为了在 locale 为 en 等情况下默认到 zh_CN

这段注释体现了两个深度认知：

- **Noto Sans CJK 与 Source Han Sans 是同一套字形的双胞胎**，但 Noto 版在某些 locale 匹配下日文假名和中文汉字的取舍会有差异；用思源的中文本地化名（思源黑体/思源黑體）能锁定区域变体；
- **`source-han-for-noto-cjk.conf` 把所有 5 个 Noto CJK 变体（SC/TC/HK/JP/KR）全部 assign 成 Source Han**，彻底消除双胞胎字体并存导致的"同一页混用两个版本"问题（字重名、标点形态都可能不一致）。这是 CJK 字体管理里最容易被忽略的坑，这份配置正面解决了。

### 5. 分语言 CJK 精细策略（175–345 行）

为 zh-HK、zh-TW、ja、ko 各写了一组（monospace/serif/sans-serif 三连）规则：

```
lang contains "zh-" 且 contains "-HK" + serif    → DejaVu Serif + Source Han Serif HC
lang contains "zh-" 且 contains "-HK" + monospace → DejaVu Sans Mono + Source Han Sans HC
ja + serif     → DejaVu Serif + Source Han Serif      ← ja 变体不加后缀，默认日文区
ja + sans      → DejaVu Sans + Source Han Sans
ja + monospace → DejaVu Sans Mono + Source Han Sans
ko + *         → … + Source Han Sans/Serif K
```

亮点：

- **双条件 `zh-` + `-HK` 精确锁定繁中香港**，避免误伤 zh-CN；
- **每条都以 DejaVu 打头**：保证终端里英文/数字仍然是等宽的 DejaVu Sans Mono，中文才回退到思源——`fc-match monospace:lang=zh-hk` → DejaVu Sans Mono，验证正确；
- **注释解释了"用 SC 名默认 zh_CN、避免 Noto 显示片假名"**，而大陆用户没有单独的 zh-CN 规则块，直接复用通用族里的思源黑体——**用"不写规则"来表达简体默认，是克制且正确的取舍**（少 30 行重复 XML）；
- ja 分支用 `Source Han Sans`（无后缀 = 日文默认），注释特意说明 monospace 里不用 Noto Sans Symbols 是因为它渲染 🅥 高度异常——又一处实战痕迹；
- monospace 的 ja/ko/HK/TW 分支都显式再写一次 `DejaVu Sans Mono` 打头，是刻意保证"等宽栈顶永远是等宽拉丁字体"，不依赖前面通用 monospace 规则的执行顺序。

### 6. Web 生态适配层（web-ui-fonts.conf + web.conf）

```
CSS 关键字        → 映射
ui-monospace      → monospace      (GitHub 代码块)
ui-sans-serif     → sans-serif
ui-serif          → serif
-apple-system     → sans-serif
Menlo             → monospace      (Python 文档等把 Menlo 放栈顶)
YouTube Noto      → DejaVu Sans + 思源黑体
```

**这是整套配置里"跨平台体验"价值最高的部分**：网页 CSS 的 `font-family: -apple-system, ui-sans-serif…` 在 Linux 上本来会全部落空、直接掉到浏览器默认字体；这里统一劫持到你定义的通用族，网页在 Linux 上的观感立刻统一成 DejaVu + 思源。实测 `fc-match Menlo` → DejaVu Sans Mono ✓。

### 7. win-replacements.conf——对"外来字体名"的收口

把 宋体/新宋体/Simsun/黑体/微软雅黑/STHeiti/Mingliu/新細明體 全部映射到思源系列，另外：

- `Courier` → prepend `monospace`（注释：默认会落到 Nimbus Mono PS，其连字宽度是错的——又一处踩坑记录）；
- `Roboto Mono` → prepend `monospace`；
- 注意这里用了不同 edit 语义：宋体类用 `assign`（彻底替换），Mingliu 类用 `append`（保留原名在前）——对繁中场景留了"如果真装了 Mingliu 就用原字体"的余地，细微但合理。

### 8. 杂项的工程素养

- `<selectfont><rejectfont>Nimbus Sans</rejectfont>`：注释说它在 GitHub 上引发问题。实测本机根本没装 Nimbus（`fc-list | grep -ci nimbus` = 0），这条是**防御性配置**——哪天 ghostscript 之类带进 Nimbus 也不会翻车；
- `Source Code`（contains 匹配）→ monospace：一网打尽 Source Code Pro/TS/等各种变体请求；
- `<dir>`、`<cachedir>` 显式声明系统 + 用户两级目录：虽然多数情况下是重复的，但保证了用户配置的**自包含性**——即使系统配置被破坏，单独这份文件也能拉起完整字体栈；
- Noto Color Emoji → Twemoji（assign binding strong）：程序显式请求 Noto Color Emoji 时（不少应用硬编码）统一换成本机首选的 Twemoji。

---

## 四、实测验证结果（本机）

| 查询                                                    | 结果                                                         | 符合预期                    |
| ------------------------------------------------------- | ------------------------------------------------------------ | --------------------------- |
| `sans-serif`                                            | DejaVu Sans（→ 思源黑体兜底）                                | ✅                          |
| `monospace`                                             | DejaVu Sans Mono                                             | ✅                          |
| `serif`                                                 | DejaVu Serif                                                 | ✅                          |
| `serif:lang=zh-tw`                                      | DejaVu Serif（→ 思源宋体 TC 兜底）                           | ✅                          |
| `monospace:lang=zh-hk`                                  | DejaVu Sans Mono                                             | ✅                          |
| `sans-serif:lang=ko` / `:lang=ja`                       | DejaVu Sans（→ 思源 K/日文变体兜底）                         | ✅                          |
| `Noto Color Emoji`                                      | **Twemoji**                                                  | ✅ 替换生效                 |
| `Liberation Sans`                                       | DejaVu Sans                                                  | ✅                          |
| `Menlo` / `Source Code Pro` / `Courier` / `Roboto Mono` | DejaVu Sans Mono                                             | ✅                          |
| `ui-monospace`（GitHub 代码块场景）                     | DejaVu Sans Mono                                             | ✅                          |
| `微软雅黑`                                              | 思源黑体                                                     | ✅ 压制了发行版 65-nonlatin |
| `宋体`                                                  | 思源宋体                                                     | ✅                          |
| `Font Awesome 7 Brands`                                 | `/usr/share/fonts/OTF/Font Awesome 7 Brands-Regular-400.otf` | ✅ 实装                     |
| `Twemoji`                                               | `/usr/share/fonts/twemoji/twemoji.ttf`                       | ✅ 实装                     |

`fc-pattern -c`（应用配置替换后的模式）进一步确认：

- `YouTube Noto` → `DejaVu Sans, 思源黑体, …`（两个 assign 值都保留）
- `Mingliu` → `Mingliu, 思源宋體, …`（append 语义：原名保留、替代在后）
- `宋体` → `思源宋体, …`（assign 语义：原名被清除）

---

## 五、可改进点（小问题，非硬伤）

1. **Font Awesome 7 硬编码**：升级到 FA 8 时，通用族列表里 4 处 `Font Awesome 7 Free/Brands` 需要同步改名（FA 不提供无版本号的别名）。建议在 README.org 里记一笔"升级 FA 时要改 fonts.conf"，或改用 `contains` 匹配的 `<match>` 规则。
2. **渲染参数与 Arch `conf.d` 存在冗余**：`10-hinting-slight.conf`、`11-lcdfilter-default.conf`（以及若启用的 `10-sub-pixel-rgb.conf`）与主文件 12–47 行重复。无害（值相同），但如果哪天发行版默认变了（比如 Arch 调整 hintstyle），可能出现"改了 conf.d 不生效"的困惑。可选做法：保持现状但在注释里说明"此处有意冗余以自包含"；或反过来删掉主文件渲染段、只依赖 conf.d。
3. **`<dir>/usr/share/fonts</dir>` 同理**：用户配置与 `/etc/fonts/fonts.conf` 重复声明，fontconfig 会去重，但维护心智上要注意两处。
4. **zh-HK/zh-TW/ja/ko 四组共 12 个 match 块**较冗长，fontconfig 没有宏/模板机制，属于语言本身的限制；如果想减负，可以只保留 monospace 那组（终端场景收益最大），serif/sans 的区域差异实际感知较弱。不改也完全没问题。
5. **fc CLI 连字符解析怪癖（验证时的坑，非配置问题）**：直接跑 `fc-match ui-monospace` 时，fc 命令行工具会把 `ui-monospace` 在连字符处截断解析成 `ui`，导致看起来像规则失效。实测带转义的 `fc-match 'ui\-monospace'` 正确返回 DejaVu Sans Mono。同理 `Noto Color Emoji` 要以空格形式书写、`-apple-system` 前置连字符会被当成命令行选项（需 `--` 分隔）。以后自己验证时注意别被这些假象骗了。
6. **`test` 元素未显式写 `qual` 时默认为 `any`**（见 `/usr/share/xml/fontconfig/fonts.dtd`）：主文件里部分 `<test name="family">` 写了 `qual="any"`，部分没写，行为一致但风格不统一；统一加上可提升可读性。

---

## 六、总结

这份配置的"精华"可以浓缩为四个设计哲学：

1. **一切以注释留痕**——每个非常规决策（gvim Twemoji、Nimbus Sans、Mingliu append、Noto 片假名、Nimbus Mono 连字宽度）都记录了原因和踩坑过程，可维护性极强；
2. **拉丁/CJK/emoji/图标四层栈式 fallback**，用一个 family 列表解决了通常需要 Pango fallback 链才能解决的问题；
3. **用 `assign` 替换语义 + include 顺序**主动压制发行版默认规则，保证自己的优先级说了算；
4. **Web 生态关键字（ui-\*、-apple-system、Menlo）统一收口**，让网页在 Linux 上的字体表现与设计意图一致。

### 验证命令速查

```bash
fc-conflist                                   # 查看配置加载顺序
fc-match 'monospace' --format='%{family}\n'   # 查族栈顶
fc-match 'ui\-monospace' --format='%{family}\n'  # 注意连字符必须转义
fc-match -- '-apple-system' --format='%{family}\n'  # 前置连字符需 -- 分隔
fc-pattern 'Menlo' -c --format='%{family}\n'  # -c = 应用配置替换后打印完整族列表
fc-cache -fv                                  # 改动字体后重建缓存
```

### 参考资料（见 README.org）

- Linux 上的字体配置与故障排除: https://blog.lilydjwg.me/2023/3/5/linux-fonts.216591.html
- https://github.com/lilydjwg/dotconfig/tree/base/fontconfig
