# Session: gh CLI（GitHub 命令行）

## Learner Profile

- Level: 近零实操（诊断：只做过 `gh auth login/status`；读过 `git/.config/git/conf/gh-参考手册.md` 739 行，但未动手）
- Language: 中文
- Started: 2026-11-04
- Prior Topics: [[git-aliases]]（6/6）、[[git-rebase]]（7/7）、[[cherry-pick]]（7/7）、[[git-first-aid]]（7/7）、[[merge-conflicts]]（5/5）、[[git-remote-collab]]（7/7）、[[git-worktree]]（4/4）、[[git-submodule]]（5/5）、[[git-hooks]]（6/6）

## Concept Map

| #   | Concept                                                                                            | Prerequisites | Status      | Score | Last Reviewed | Review Interval |
| --- | -------------------------------------------------------------------------------------------------- | ------------- | ----------- | ----- | ------------- | --------------- |
| 1   | 心智模型：gh = GitHub API 的客户端（不是 git 的包装）；PR/issue/release 住服务器，git 只管本地账本 | -             | mastered    | 85%   | 2026-11-04    | 1d              |
| 2   | 认证与凭据：auth login/status/setup-git、token scopes、GH_TOKEN、多账号                            | 1             | mastered    | 85%   | 2026-11-04    | 1d              |
| 3   | 仓库与远程：repo view/clone/fork，origin vs upstream                                               | 1, 2          | mastered    | 85%   | 2026-11-04    | 1d              |
| 4   | PR 全流程：branch → push → pr create → checks → review → merge → 删分支                            | 1, 2, 3       | mastered    | 85%   | 2026-11-04    | 1d              |
| 5   | PR 本地侧：pr list/view/checkout/diff，检出别人 PR 跑测试、读讨论串                                | 4             | not-started | -     | -             | -               |
| 6   | Issue 联动：issue create/list/develop（issue → 分支 → PR）                                         | 4             | not-started | -     | -             | -               |
| 7   | Actions/CI：run list/view/watch、失败步骤日志、rerun、workflow_dispatch                            | 4             | not-started | -     | -             | -               |
| 8   | 兜底与自动化：gh api、alias/extension、脚本里的 GH_TOKEN、反模式（别用 gh 传大文件/密钥）          | 2, 4, 7       | not-started | -     | -             | -               |

## Misconceptions

| #   | Concept  | Misconception                                     | Root Cause                                                                  | Status                              | Counter-Example Used                                                                                                                                                                                                              |
| --- | -------- | ------------------------------------------------- | --------------------------------------------------------------------------- | ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | 心智模型 | 「PR 对象住本机」（gh 命令在本地跑 = 对象在本地） | 把 gh 当 git 的本地包装；同「账本/实物」族：命令的运行位置 ≠ 对象的存放位置 | **resolved（2026-11-04 换形通过）** | 反证：同事浏览器打开 `github.com/.../pulls` 读到的是服务器上的对象 → 自纠「PR 住远端服务器」✓；`gh api` 读 PR #1：只有 head/base 端点 + diff_url，无 diff 内容 → 换形题「改 base，diff 会变吗」→「会变，PR 是记录，diff 即时算」✓ |

## Session Log

- [2026-11-04] 新课开张：gh CLI（用户在「git 内部结构 / bisect / gh / 收课」四选一中选中）。诊断：只做过 `auth login/status`，其余零实操；本机 gh 2.102.1，已登录 AlanVane（ssh 协议，scopes 含 repo/workflow/read:org/gist/admin:public_key），dotfiles 远程 `appleshan/dotfiles`。
- [2026-11-04] 诊断题 1：本地 `feature` 未 push，直接 `gh pr create` → 答「PR 住本机」✗ + 「需要 push」✓ → 反证「同事浏览器从哪台机器读到 PR」→ 自纠「PR 住远端服务器」✓（误解 #1 active，待换形把关）。概念 1 开工。
- [2026-11-04] 概念 1 主体：①`git push` vs `gh pr create` → push 对象到远端 ✓、不能先有 PR 再 push ✓；但「pr create 传 diff」✗ → 思想实验「建完 PR 再 push 一笔，diff 会变吗」→「不知道」→ `gh api` 读真实 PR #1 JSON（head/base + head_sha/base_sha + diff_url，无 diff 内容）→ 骨架填空「请求里有 diff 吗 / PR 是记录还是补丁包」→「没有 / 记录」✓；②换形：改 base、代码不动 → 「会变，PR 是记录，diff 即时算」✓。
- [2026-11-04] 概念 1 实践关：`gh repo view appleshan/dotfiles --json name,defaultBranchRef,visibility,url` 跑通，指出 `visibility` 只有 GitHub 知道 ✓ → **mastered 85%（1d）**，误解 #1 关口关闭。
- [2026-11-04] 概念 2（认证）：①https clone 的仓库 gh 登录了、git push 还问密码 → 「git 没配用 gh 的 auth」✓ → 追问「setup-git 写哪类配置」→「不知道」→ 摆本机真实配置 `credential.https://github.com.helper = !/usr/bin/gh auth git-credential` → 「git 主动执行 helper」✓、「交出的密码是 gh 的 auth token」✓；②CI 无浏览器 → 「GH_TOKEN、不该用交互式 login、环境变量优先」✓；③私有仓库报 404 → 「可能是没权限」◐ → 追问「为什么用 404 掩盖 403」→「防无权限访问者」✓；④实践：`gh auth status` 读出 AlanVane / 5 个 scopes / ssh，补 workflow 的命令 `gh auth refresh -s repo -s read:org -s workflow` ✓ → **mastered 85%（1d）**。
- [2026-11-04] 概念 3（仓库与远程）：①fork --clone 后 origin/upstream 各指谁 → 「origin=fork 副本、upstream=被 fork 的仓库」✓、「不能推 upstream 因为没权限」✓；②跨 fork 的 `--head` 只写 `feature` 为何不够 → 「不知道」→ 梯子「一百个同名 feature」→ 填 `owner/proj:feature` ✗（仓库全名当 owner）→ 指 fork 地址 `git@github.com:AlanVane/proj.git` → 「AlanVane」✓；③交错题（PR 已开后再 push）→ 「不用重开、diff 即时重算」✓；④实践 `gh repo fork --help`：`--clone` 克隆、`--remote` 只加 remote、已有本地仓库用 `--remote` ✓（理由表述含糊，但方向对）→ **mastered 85%（1d）**；附注：默认行为是 fork 设为 origin、原 origin 改名 upstream，可用 `--remote-name` 改。
- [2026-11-04] 概念 4（PR 全流程）：①push 之后到 merge 的关卡 → 只知道 `pr create`，其余「不知道」→ 给骨架填格 + 真实 PR #14918 数据（checks/reviewDecision）→ `checks`=第 3 格、`reviewDecision`=第 4 格 ✓、红灯 GitHub 拦 ✓；②checks 绿 + approved 仍可能失败 → 「不知道」→ 最小反例（A 改名 foo→bar / B 新增 foo 调用）判「A 的测试炸」✗ → 追问「报错指向 B 的文件」✓ → 语义冲突 + update branch 方向（main→feature，feature 多一笔）✓；③linear history → `--merge` 造 2 父提交、`--squash` 单父；A 压一笔用 `--squash`、B 保留逐笔用 `--rebase` ✓；④实践：`gh pr checks 14918` 12 通过 / 0 失败 / 6 跳过 ✓，`mergeStateStatus=UNKNOWN`（GitHub 未算）；四值配对 DIRTY/BEHIND/BLOCKED/CLEAN 全对 ✓ → **mastered 85%（1d）**。
- [2026-11-04] **收课（用户选择）**。本轮 4/8 概念通关：1 心智模型 85%、2 认证 85%、3 仓库与远程 85%、4 PR 全流程 85%；概念 5-8 未开。误解 1 起（#1「PR 住本机」）当日 resolved。实践关 3 次：`repo view`（visibility 服务器字段）、`auth status`（账号/scopes/ssh + refresh 命令）、`pr checks 14918`（12 通/0 败/6 跳 + mergeStateStatus=UNKNOWN + 四值配对）。**留债**：11-05 复习 gh 1-4（1d）＋ submodule 3/4（1d，押注首答翻车项）；gh 5-8 下次续。**画像观察**：解释型问题后段「不知道」增多（语义冲突、--squash/--rebase 选择），但读真实 JSON/help 后能推；命令标签（`--head owner:branch`）仍需具体地址锚定。
