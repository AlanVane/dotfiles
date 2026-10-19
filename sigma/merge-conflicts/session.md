# Session: merge 与冲突解决

## Learner Profile

- Level: 高起点（rebase 7/7、cherry-pick 7/7、急救箱 7/7；基线/重放模型全部可迁移；档案挂账「三方对比为讲解所得」——本轮诊断显示已随重放模型自愈）
- Language: 中文
- Started: 2026-10-15
- Prior Topics: [[git-aliases]]（6/6）、[[git-rebase]]（7/7）、[[cherry-pick]]（7/7）、[[git-first-aid]]（7/7）

## Concept Map

| #   | Concept                                         | Prerequisites | Status   | Score | Last Reviewed | Review Interval |
| --- | ----------------------------------------------- | ------------- | -------- | ----- | ------------- | --------------- |
| 1   | 快进 vs 三方（merge 触发条件）                  | -             | mastered | 90%   | 2026-10-19    | 4d              |
| 2   | 冲突现场与标记阅读（diff3 三段）                | 1             | mastered | 90%   | 2026-10-18    | 2d              |
| 3   | 裁决流程（名单 → 编辑 → add → continue；abort） | 2             | mastered | 85%   | 2026-10-19    | 4d              |
| 4   | merge vs rebase 辨析                            | 1, 3          | mastered | 90%   | 2026-10-19    | 4d              |
| 5   | 综合实操（三合一现场全程指挥）                  | 3, 4          | mastered | 95%   | 2026-10-18    | 2d              |

## Misconceptions

| #   | Concept                                                                            | Misconception | Root Cause | Status | Counter-Example Used |
| --- | ---------------------------------------------------------------------------------- | ------------- | ---------- | ------ | -------------------- |
| -   | （本课 0 误解——三方/基线模型全面接管新概念；诊断 Q2 的机制空经一次押注实验即自填） |               |            |        |                      |

## Session Log

- [2026-10-15] 新课开张：merge 与冲突解决（三选一用户选定，推荐项）
- [2026-10-15] 诊断：Q1 三方对比 ✓ 全对（共同祖先 + ours + theirs）——档案挂账「讲解所得」自愈（重放模型的基线概念迁移成功）；Q2 快进触发条件 ◐ 答成「--no-ff 保住分支历史」（拿工具套，机制空——老模式复现）→ 出不分叉现场 A 押注题 → ✓ 押 A → 实测：`Fast-forward`，log 五节点直线，F1/F2 直接进 main 历史——**打脸 Q2 原答**（丢的不是 commit，是「发生过 merge」的记录）
- [2026-10-15] 现场 B 押注 ✓✓「不能快进；新 commit 双父 = M4 + F2」→ 布景失误一轮（M4 误建在 F2 头上 → git「已经是最新的」，顺手教了 up-to-date 语义）→ 重摆真分叉 → 实测全中：ort 策略自动合并无冲突（M4 动 hotfix.txt、F 动 app.txt 井水不犯河水），新节点 5e22896 双父结构与押注一致 → 收口：✓「main 没有新 commit（是 feature 祖先）→ 快进；分叉 → 造新 commit」——**快进条件自推导完成**；Q2 时机对结论缺 → 降梯三表（①单方改 ②异行同拼 ③同行冲突）→ ✓ 双填空「hotfix.txt=①、app.txt=①」（ort 无冲突合并的三方解释到位）→ **现场 C 押注** ✓✓「暂停不造 commit、文件带标记待裁决」→ 实测冲突：`UU`、HEAD 仍 M5（押注证实）、**diff3 风格标记三段可见**（HEAD/||||||| bec86b0 基线/feature）→ 两问：✓ Q1「中间段 = 祖先 commit」✓ Q2 自写完整裁决序列（`git diff --diff-filter=U` 找名单——参数小众且精准 → 编辑 → add → merge --continue），实跑生效 → 他出裁决内容「feature A / feature B」→ 追问两点：✗ 无争议行 `v1` 被删——**自认手误**（教训：裁决只动打架段）+ ◐ 站队理由「应该这样」（真实场景依据=问作者/看需求）→ 按「恢复 v1 + 站 feature」执行 → UU→M→`merge --continue` → 双父节点 0f50a31 诞生（与 5e22896 对照：同样结构、区别只在谁裁决）→ 出放弃合并命令构词题 → ✓ `git merge --abort`（构词法满分）→ 实测：再造冲突当场反悔，无痕还原（status 空 / HEAD 不动 / 文件复原）→ **冲突工具箱四件套齐**（读标记 / diff-filter=U / 编辑+add+continue / abort）→ 概念 4 两场景题 ✓✓ 双过——场景 1「rebase -i，这 3 个 commit 还没被别人 pull」（**安全判据定位到 commit 粒度**，黄金法则精确认知）；场景 2「merge，保留 feature 历史」→ 补深层理由（merge 只加不改，对 pull 过的同事零影响）→ 口诀定案「独占未推 → rebase 整理；共享已推 → merge」→ **最终实操**：三文件现场（shared.txt 双方同行改 / bothadd.txt 双方同名新建异内容 / common+shared2+featurefile 单方动）→ 押注三连 ✓✓✓（自动合三个 / 冲突俩 / 停车不造 commit）→ 实测一字不差（AA / UU / A 三态齐全）→ 他出双裁决（shared.txt=feature edit、bothadd.txt=v1 feature，均站 feature）→ 执行 → 双父节点 5090408，六文件清点无误、common.txt 保住 main 版 → 自评「扎实」= rubric 一致
- [2026-10-15] **🎓 merge 与冲突解决 结课：5/5**。本课 0 误解（对比急救箱 3 连胜）——重放/基线模型全面接管，档案挂账「三方对比讲解所得」在诊断阶段即自愈。间隔复习债：5 项，10-16 起可复习
- [2026-10-17] 复习债③：Q-a rebase 收尾序列 ✓（add → rebase --continue，**无混入**——两次复发点首过）+ Q-b merge 版 ✓ → 追问机制 ◐→✓（「状态不同」贴标签 → 降梯填空：**rebase=继续跑完重放名单；merge=造完眼前这一个 commit**）→ 概念 3/4 复习通过（1d → 2d）
- [2026-10-17] 复习债⑤（一石二鸟押注）：押 a ✓（rebase 后 main log 只有 B-C-D，看不到 E′/F′——同时构成 rebase 误解销账战第 2 胜）；**押 b ✗ 押「造新 commit」→ 实测 `Fast-forward`（单父 2152954）**——10-15 自己推导的快进条件在「刚 rebase 完」现场失灵 → 诊断追问 → ✓ 自纠「我还以为是分叉呢」——错图=没让现场跟着上一步 rebase 更新（模型对、现场未刷新），非机制缺失；概念 1 interval 重置 1d（10-18 干净押一次升 2d）
- [2026-10-17] 补考提前通过：远程协作课实操现场（本地 main 落后服务器 → 自写 fetch+pull，**实测前押「快进」命中**，单父 08bc723）→ 概念 1 升 2d
- [2026-10-18] 复习债·第三批（2 项，逾期 2 天）：概念 2 冲突标记 ✓ diff3 中段=祖先基线 + 三方价值（看清双方各自怎么变）+ 补考裁决读图（丢的是 v2 同事版）→ 1d→**2d**；概念 5 三方预测 ✓ UU / AA / 单方动=自动合并三态全对 → 1d→**2d**（顺带：本日综合独立补考中远程协作 5/6/7 升 2d，见 git-remote-collab）

- [2026-10-19] 复习债·概念 1 快进条件（10-17/10-18 两次押错后的 10-19 再验）：方向 ✓「自己没有它缺的 commit」+ 边界 ✓（同位置 → 「什么也不会发生」= 已是最新，不产生 commit）→ 2d→**4d**

- [2026-10-19] 复习债第三批 2 项：概念 3 裁决流程 ✓ 四步一字不差（diff --diff-filter=U 名单 → 编辑 → add → merge --continue）→ 2d→**4d**；概念 4 辨析 ✓ merge 留分叉（合并节点）/ rebase 拉直线 → 2d→**4d**
