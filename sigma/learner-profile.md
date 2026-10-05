# Learner Profile

Updated: 2026-10-05

## Learning Style

- Preferred explanation mode: concrete examples（scratch repo 实测最能落地；抽象机制问题常答「不知道」，需梯子降阶到具体场景）
- Pace: moderate — 识别类问题快，机制复述类问题需要时间，多次「不知道」后经降阶梯子可完成推理
- Responds best to: 反例实验 + 预测问题（先预测再实测，矛盾驱动模型更新）；梯子末格填空（worked example 留最后一步）
- Struggles with: 无提示地复述机制；新场景预测（模型未内化时会退回旧误解）

## Misconception Patterns

- 未验证时倾向猜测 git 的破坏性行为（「会覆盖」「会丢失」），不基于证据（seen in: git-aliases，误解 #4、#5）
- shell 符号/术语易混：`\|` vs `\|\|`（seen in: git-aliases）
- 把工具输出当有类型的值而非字符串：`0` 是数字不是字符串（seen in: git-aliases）
- 模型复述正确 ≠ 已内化：正确复述后新场景仍会触发旧误解，需实验 + 应用双重确认才算解决（seen in: git-aliases，误解 #4）
- 表述混淆：机制说对但措辞错位，如「push 之后才有 commit 历史」（实为 push=远程备份，历史本地就有）（seen in: git-aliases，概念 6）——反问澄清即可，不需反例实验

## Mastered Topics

| Topic                       | Concepts Mastered | Date       | Key Strengths                                                                                | Persistent Gaps              |
| --------------------------- | ----------------- | ---------- | -------------------------------------------------------------------------------------------- | ---------------------------- |
| git aliases（topic 工作流） | 6/6（全部完成）   | 2026-10-05 | 探针语义、两态 checkout 规则（自推导）、小抄模型（自走通）、td vs tmg 删除辨析、实测纠错意识 | snapshot、stash-history 未讲 |

## Metacognition

- Self-assessment accuracy: well-calibrated（两次自评「扎实」均与 rubric 85% 一致）
- Fluency illusion frequency: occasional — 复述正确后新场景仍触发旧误解（误解 #4）；解决靠双实验 + 应用检验
