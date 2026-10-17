# settings.gitconfig 评审报告

- 评审日期: 2026-10-17
- 环境: git 2.56.0 / delta 0.20.1 / difftastic 0.71.0 / linux
- 结论: **整体质量高，配置可用且已验证生效；有 2 个应修复项、若干可选优化项，无致命错误。**

---

## 一、总体评价

配置结构清晰（fold 分区、注释充分、引用了出处链接），引用的外部文件（`ignore`、`gitattributes`、`gitmessage`）均存在，依赖工具（`delta`、`difft`、`nvim`）均已安装。`core.pager`、`delta`、`difftool`、`mergetool` 各环节实测能正常工作。

---

## 二、应修复项

### 1. `plus-color` / `minus-color` 已废弃且与 `plus-style` / `minus-style` 冲突（L45-46）

```gitconfig
plus-color = "#0e3c15"
minus-color = "#5a0c0f"
```

- delta 早已废弃 `plus-color`/`minus-color`（它们是 `plus-style`/`minus-style` 的旧别名）。
- 本文件 L49-55 又定义了 `plus-style` / `minus-style` / `plus-emph-style` / `minus-emph-style`，两组配置语义重叠，当前靠"文件中靠后的定义生效"才没有出错，属于隐患。
- **建议**: 直接删除这两行（颜色值已包含在 `*-style` 里）。

### 2. `inspect-raw-lines = false` 不被推荐（L56）

delta 官方说明该选项默认为 `true`，且 delta 作者明确表示"你可能不想关掉它"——关闭后 delta 不再检查原始 ANSI 序列，在某些终端/颜色嵌套场景下会出现渲染错乱。实测本机默认 diff 场景无差异，但收益也几乎为零。
**建议**: 删除该行，恢复默认 `true`。

---

## 三、可选优化项

### 3. `merge.conflictStyle = diff3` → 建议升级为 `zdiff3`（L136）

git ≥ 2.35 提供 `zdiff3`，在 diff3 基础上做了智能分块（公共祖先部分只显示必要行），冲突大文件时输出显著更短。本机 git 2.56 完全支持：

```gitconfig
conflictStyle = zdiff3
```

### 4. `rerere` 可加 `autoupdate = true`（L165-166）

开启后 rerere 会自动把学到的解决方案写入暂存区，省去手动 `git add`。

```gitconfig
[rerere]
    enabled = true
    autoupdate = true
```

### 5. `credential.helper = cache --timeout=360000000`（L162）

- 语法无误，但 `cache` 方式凭据存在 `/tmp` 的 unix socket + 内存里，**重启/注销后即失效**，100 年的 timeout 实际意义有限。
- 若希望持久化且更安全，可改用系统 keyring：
  ```gitconfig
  helper = secretservice   # 需要 git-credential-libsecret / libsecret
  ```

### 6. `core.pager` 脚本健壮性（L29-39）

逻辑验证正确（80+ 列普通终端 → side-by-side；fzf preview 且终端 ≥160 → 用 `$FZF_PREVIEW_COLUMNS`；其余 → 普通 delta）。两个小建议：

- `$COLUMNS`、`$FZF_PREVIEW_COLUMNS` 未加引号，且 `tput cols` 在 `TERM` 未设置时输出为空，会导致 `[` 报 `unary operator expected`（虽会 fallback 到 else 分支不致命，但会打印错误）。可改为：
  ```sh
  COLUMNS=$(tput cols 2>/dev/null || echo 80)
  if [ "$COLUMNS" -ge 80 ] && [ -z "$FZF_PREVIEW_COLUMNS" ]; then
  ```
- 终端刚好 80 列时就开 side-by-side，每行只剩 ~38 列有效宽度，实际很难读。可把阈值提高到 120：
  ```sh
  if [ "$COLUMNS" -ge 120 ] && [ -z "$FZF_PREVIEW_COLUMNS" ]; then
  ```

### 7. `hyperlinks = true` + `vscode://` 链接（L66-67）

依赖终端支持 OSC-8 超链接（iTerm2/kitty/wezterm 支持；部分终端会显示为原始 URI）。当前用 nvim + vscode 链接说明你在 VSCode 终端里用得多，基本没问题，仅提醒：在不支持的终端里 `git log --oneline` 输出会带一串裸 URI。

### 8. `[pager] log = false` 的副作用（L113）

关闭了 `git log` 的 pager，长 log 会直接刷屏。推测是为了配合 fzf/terminal 搜索，是有意为之；若非必要，`log = false` 只在 alias 里局部关掉更安全（如 `lg = log --no-pager ...`）。

---

## 四、确认无误的项（抽查验证）

| 项                                                                       | 说明                                           |
| ------------------------------------------------------------------------ | ---------------------------------------------- |
| `[init] defaultBranch = main`                                            | ✅ 现代默认，无问题                            |
| `core.autocrlf = input` + `safecrlf = true`                              | ✅ Linux/Mac 下推荐组合                        |
| `core.untrackedCache`                                                    | ✅ 已在 git 内核默认开启，显式声明无害         |
| `core.excludesfile` / `attributesfile` 路径                              | ✅ 两个文件实际存在                            |
| `core.whitespace` 规则                                                   | ✅ 语法正确                                    |
| `[delta]` feature groups（`unobtrusive-line-numbers` / `decorations`）   | ✅ delta 能正确解析并应用                      |
| `[difftool "difftastic"]` 的假 hash 参数                                 | ✅ difftastic 官方推荐写法，用于正确显示文件名 |
| `[mergetool "nvim"]` `Gvdiffsplit!` + `trustExitCode`                    | ✅ fugitive 配套写法，`:cq` 可中止             |
| `[pull] rebase = true`、`[fetch] prune`、`[rebase] autosquash/autoStash` | ✅ 现代工作流标准组合                          |
| `[push] followTags`                                                      | ✅ 语法正确                                    |
| `commit.template` 路径                                                   | ✅ 文件存在                                    |
| `[interactive] diffFilter = delta --color-only`                          | ✅ delta 标准集成方式                          |
| `[delta] features = ...` 引用的两个子组                                  | ✅ 均在后文定义，顺序无问题                    |

---

## 五、优先级小结

| 优先级   | 项                                                                           |
| -------- | ---------------------------------------------------------------------------- |
| 建议修复 | #1 删除废弃的 `plus-color`/`minus-color`；#2 恢复 `inspect-raw-lines` 默认值 |
| 值得采纳 | #3 `zdiff3`；#4 `rerere.autoupdate`；#6 pager 脚本加引号/提阈值              |
| 按需考虑 | #5 凭据持久化方式；#7 终端兼容性；#8 log pager                               |
