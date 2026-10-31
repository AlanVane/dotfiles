# Session: git hooks（钩子）

## Learner Profile

- Level: 零实操（诊断：只在概念层听过；预测题「exit 1 → 提交被拒、HEAD 不动」✓ 首答即中）
- Language: 中文
- Started: 2026-10-31
- Prior Topics: [[git-aliases]]（6/6）、[[git-rebase]]（7/7）、[[cherry-pick]]（7/7）、[[git-first-aid]]（7/7）、[[merge-conflicts]]（5/5）、[[git-remote-collab]]（7/7）、[[git-worktree]]（4/4）、[[git-submodule]]（5/5）

## Concept Map

| #   | Concept                                                                                | Prerequisites | Status   | Score | Last Reviewed | Review Interval |
| --- | -------------------------------------------------------------------------------------- | ------------- | -------- | ----- | ------------- | --------------- |
| 1   | 钩子模型：git 在固定时机执行本机脚本，只按退出码裁决（0 放行 / 非 0 拦下）——谁在做决定 | -             | mastered | 85%   | 2026-10-31    | 1d              |
| 2   | 钩子清单与时序：客户端 vs 服务端；pre 类能拦、post 类只能看；各在账本哪一步            | 1             | mastered | 85%   | 2026-10-31    | 1d              |
| 3   | 存放与分享：.git/hooks 是本机物件、不入库；.sample 不执行；同事 clone 后没有你的 hook  | 1             | mastered | 90%   | 2026-10-31    | 1d              |
| 4   | 工程化：core.hooksPath + 受版本管理的 hooks 目录（husky / lefthook 的本质）            | 3             | mastered | 85%   | 2026-10-31    | 1d              |
| 5   | 执行环境与踩坑：cwd、hook 里调 git、改 index 的坑、--no-verify、pre-push 的 stdin 协议 | 1, 2          | mastered | 85%   | 2026-10-31    | 1d              |
| 6   | 实战：pre-commit 挡调试语句 + commit-msg 校验格式，跑通拦截 / 放行 / 绕过              | 2, 4, 5       | mastered | 85%   | 2026-10-31    | 1d              |

## Misconceptions

| #   | Concept  | Misconception                                                 | Root Cause                                                                                         | Status                     | Counter-Example Used                                                                   |
| --- | -------- | ------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- | -------------------------- | -------------------------------------------------------------------------------------- |
| 1   | 钩子模型 | 「hook 没执行权限 → git 会报错要求 chmod +x」（把提示当关卡） | 把 hook 当 git 的正式部件/契约；实际 hook 是可选外挂，git 只找可执行文件，找不到就跳过（提示可关） | open（机制层已通，待换形） | 无执行位 → 提示 + 提交照样过 a9255c4；加回 +x → `HOOK RAN` + exit=1 真拦；练习三格全对 |

## Session Log

- [2026-10-31] 新课开张：git hooks（用户在「内部结构 / bisect / hooks / 提前复习」四选一中选中）。诊断：仅概念层听过（.sample 未看、未手写、未用框架）；预测题「pre-commit 写 exit 1 → 提交被拒、HEAD 不动」✓ 首答即中——注意这是「门卫直觉」罕见命中的一次（hook 确实是关卡），后续须把「谁在做决定」这层拆开，避免把 hook 能力当成 git 内建能力
  - [2026-10-31] 概念 1 押注翻车（误解 #1）：hook 无执行位 → 押「报错，要求加执行权限」✗（半对：git 2.56 确实打一条 `提示：…钩子被忽略`，但**提交照样过** a9255c4、exit=0；加回 +x 后同一脚本 `HOOK RAN` + exit=1 才真拦）→ 病根：把 hook 当 git 的正式部件/契约，以为 git 会校验并兜底；实际 hook 是可选外挂，git 只找可执行文件，找不到就跳过（提示还可用 `advice.ignoredHook false` 关掉）
- [2026-10-31] 概念 1 梯子：问「打印拒绝文案 + exit 0」→ 答「不知道」→ 梯子留格「安检门后那个人只收一个信号，是什么」→ 答「**exit 后的数字**」✓（退出码模型一次命中）→ 追问该场景结局 → 答「会正常 commit，**不显示**拒绝的消息」◐（结论对、输出层错：以为通过的 hook 输出会被吞）→ 沙盘 `/tmp/opencode/hooks-lab/repo` 实测：stderr 那行照常显示、commit b9dc8a0 成功、exit=0、status 干净 → 反例击破「看文字判断」模型
- [2026-10-31] 概念 1 收口：问「同事说『git 会检查代码、不合规不让提交』哪里不准」→ 答「git 看的是 exit 码，不是看检查是否通过」✓（机制层正中；未点出「这不是 git 内建检查、而是你本机脚本」，留给概念 3）→ **概念 1 mastered 85%（1d 复习）**
- [2026-10-31] 概念 1 练习关（填空 + 三小问）：①`1` ②`0` ✓、完整路径 `.git/hooks/pre-commit` ✓、`chmod +x` ✓ 一次全对 → 我实跑验证：含 `debugger` → exit=1 拦下；清掉后 a4baed4 通过；**附带教材**：上一轮被拦时暂存的 c.txt 原样留在 index、混进了下一次成功提交（拦下 = 账本零改动）
- [2026-10-31] 概念 2（时序与两栏）全程：①四钩子排序 ✓ 全对；②「名字里写着拦不住的是哪个」→ 猜 `commit-msg` ✗（自陈「猜的，不知道为啥」——诚实报缺口，按规矩走梯子不讲解）；③`post-commit` 里 exit 1 结局 → 「不知道」→ 梯子「它跑的时候账记了没」→「**已经记进账本**」✓ → 自答出 post 族只能事后抱怨；④回修 `commit-msg`：「它跑时账记了吗 / exit 1 有用吗」→「没有 / 有用」✓；⑤「信息必须以 feat:/fix: 开头写哪个钩子」→「commit-msg，因为 pre-commit 看不见消息」✓（novel application + discrimination 双中）；⑥远端 `pre-receive` exit 1 预测「push 被拒、本地提交保留」✓ → 实测 `! [remote rejected] (pre-receive hook declined)`、远端零引用、本地 f0f7efb 完好；⑦关口题「怎么让所有人绕不过去」→ 层对（远端）✓、名字错（`commit-msg`）✗ → 拆字补 `pre-receive` ✓
- [2026-10-31] 概念 2 收口：自评「Solid 扎实」，rubric 85%——时序/信任边界/novel application 全独立命中，唯一靠梯子的是**服务端钩子名字**（与 submodule 160000 同型：标签召回弱，概念不缺）→ **mastered 85%（1d）**；记档：「commit-msg 是客户端钩子，远端只有 pre-receive/update/post-receive」列为复习标签项
- [2026-10-31] 概念 3（存放与分享）：①clone 后同事会被拦吗 → 「不会被拦」✓；②`git ls-files` 列它吗 → 「不会，hook 不是被追踪的文件」✓（停在工作区层，追一层）；③「git 凭什么找到 .git/hooks/pre-commit」→ **「靠路径约定，到点就找」**✓（零梯子，正中；这是概念 3 的机制核心）；④sample 默认启用会怎样 → 「被拒，提交不了」✓（并点出他自己仓库里就有中文文件名）；⑤克隆体实测：非 sample 钩子为空、`debugger` 畅通提交 3da20a4；⑥判别题「.gitmodules 跟 clone 走、hook 不跟」→ 「.gitmodules 被跟踪、hook 不是」◐→ 追问「hook 是对象库里的对象吗」→「**不是**」✓（落到实物层，主病灶这次没复发）；⑦练习：`cp tools/pre-commit .git/hooks/pre-commit; chmod +x` ✓ 全对
- [2026-10-31] 概念 3 收口：自评「Solid」，rubric 90%——依据这次配得上（路径约定、不在对象库、sample 逻辑、安装动作全独立命中）→ **mastered 90%（1d）**
- [2026-10-31] 概念 4（工程化）：①「README 写 cp」的坏法 → 「没看 README / 没完整执行」✓、另答「.git/hooks 目录还没创建」✗（每个 init/clone 都自带该目录 + sample，已当场纠正）；②「两周后你改了真本，照 README 拷过的同事跑哪版」→「**旧版：他拷的那一版**」✓（副本漂移点破）；③自答出软链方案 ✓（知道能力、不知配置名）；④补 `core.hooksPath` 并实测：`git config core.hooksPath tools/hooks` 后 debugger 当场拦下（t2.js 留暂存区）、配置来源 `file:.git/config`、克隆体该配置为空且 `tools/` 未提交（`?? tools/`）；⑤「core.hooksPath 解决了哪一半」→「改 hooks 目录」◐（模糊）→ 讲清两半：**内容不漂**（工作区真本）vs **那行 config 仍每人一次**；⑥「没跑 npm install 会拦吗」→「不生效，直接过」✓；⑦husky 不认识 → 补讲（npm prepare/postinstall → 自动 `git config core.hooksPath .husky`）；⑧**押注翻车**：「husky 就足够让谁也躲不掉」✗ → 被要求与前两答对账 → **自己抓矛盾**「husky 需要跑 npm install，不能同时成立」✓（自我抓矛盾通道再次生效）→ 收口：本地 hook 永远有缺口（不装依赖 / 不跑脚本 / --no-verify），只有服务端强制
- [2026-10-31] 概念 4 收口：rubric 85%（机制与自纠到位，首答把工具当强制）→ **mastered 85%（1d）**；记档：**「工具 = 强制」是新变体**（husky 填了「本地也能绕不过」的幻想位），对策同前：先问「它跑在哪一步、谁可以跳过」
- [2026-10-31] 概念 5（执行环境与踩坑）：①`commit --no-verify` 跳过哪些 → 「提交前那批全跳」✓；实测（`pathdemo` 接 `core.hooksPath tools/hooks`）：无 `-n` 时 debugger 先被 pre-commit 挡、消息不合规时被 commit-msg 挡（`❌ 消息要以 feat:/fix: 开头`）、`--no-verify` 下两者全跳过但 **post-commit 照跑**（`[post-commit 跑了]`）→ 边界＝「提交前那批」；②cwd 预测 → 「不知道」→ 实测子目录 `sub/` 提交时 hook 的 `pwd` = **仓库根**、`$0` = 相对路径 `tools/hooks/pre-commit` → 讲解「绝对路径或 `git rev-parse --show-toplevel`」；③hook 里格式化并 `git add` → 「**是修正后的**；风险：忘了 add 就提交旧的」✓（一次命中，含风险）
- [2026-10-31] 概念 5 收口：rubric 85%（cwd 靠讲解，其余独立命中）→ **mastered 85%（1d）**；未覆盖（留到复习/实战）：pre-push 的 stdin 协议 `local ref local sha remote ref remote sha`、服务端 `update` 逐 ref 调用
- [2026-10-31] 概念 6（实战）：自己写出 `tools/hooks/pre-commit`（awk 解析 `git diff --cached -U0`，命中 `debugger`/`console.log` 输出 `文件:行号: 内容` 并 exit 1）+ `tools/hooks/commit-msg`（取首条非注释行、`feat:/fix:/chore:` 白名单、失败打印示例）+ 安装（`git config core.hooksPath tools/hooks` + `chmod +x` 两文件）→ 我按四条验收实跑：合规 `ad3f97b` 过；消息 `add b` → `commit-msg` 拦并打印格式；`debugger` + `--no-verify` → `1cc6998` 过；行号准确（`app.js:2`/`app.js:3`，非 hunk 行号）→ **mastered 85%**
- [2026-10-31] **git hooks 全课收官 6/6**（85/85/90/85/85/85，均分 86%）；新增误解 1 起（#1「无执行位 = git 报错拦我」= 门卫家族的新形态：把提示当关卡），另有变体「husky = 强制」（首答，自己抓矛盾后收）。**产物**：`git-hooks/session.md`、`roadmap.html`、`summary.html`；沙盘 `/tmp/opencode/hooks-lab`（repo / remote.git / client / clone-test / pathdemo / pathdemo2 / final）
- [2026-10-31] **复习排期**：11-01 到期 9 笔（submodule 3/4/5 + hooks 1-6）→ 按上限 5 笔优先清 `submodule 3/4/5`（含硬指标：概念 4 零梯子说出「那边没有这个对象」）+ `hooks 1/2`（押注换形：无执行位、路径约定）；`hooks 3-6` 顺延 11-02。11-03 submodule 2（4d）；11-07 submodule 1（8d）
- [2026-10-31] 复习债：本轮无到期项（概念 3/4/5 明日 11-01 到期、概念 2 11-03、概念 1 11-07）
