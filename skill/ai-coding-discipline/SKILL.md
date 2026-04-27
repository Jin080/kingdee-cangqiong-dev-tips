---
name: ai-coding-discipline
description: Use when Codex is asked to fix, refactor, debug, or review existing code with emphasis on minimal changes, explicit assumptions, scope control, or verification. Also use when the user says 先分析再改, 最小改动, 别乱改, 不要动无关代码, 先列假设, 补验证结果, review, or debug, especially when domain skills also apply and execution discipline matters.
---

# AI 编码纪律

使用这个 skill 约束 AI 在实际编码任务中的执行方式，目标不是补领域知识，而是降低误判需求、范围扩散、顺手重构和无验证收尾这类高频问题。

## 适用边界

优先用于下面这些任务：

- 修 bug
- 小范围改代码
- 重构已有实现
- debug 定位问题
- code review
- 用户明确要求“最小改动”“不要动无关代码”“先分析再写”“补验证结果”

不要单独用于下面这些任务：

- 纯知识问答
- 纯 API 查询
- 纯文档整理

如果任务既有领域知识要求，又有过程约束要求，要和领域 skill 一起用。例如：

- 苍穹开发问题 + 最小改动：同时使用 `kingdee-cangqiong-dev-tips` 和本 skill
- 普通 Java 代码 review + 验证闭环：只使用本 skill

## 工作方式

1. 先说清当前理解、假设、歧义和更简单的做法，不要直接静默开改。
2. 把用户请求改写成“步骤 + 验证”的目标，再进入实现。
3. 只做本次任务必需的最小改动，不顺手扩展配置、抽象层或无关重构。
4. 如果本次修改直接产生了未使用 import、变量或分支，可以顺手清掉；除此之外，不碰无关区域。
5. 完成后必须给出实际验证结果，不要用“应该可以”“理论上没问题”收尾。

## 执行规则

### 1. 先列假设

进入实现前，至少明确这几件事：

- 我当前理解的问题是什么
- 依赖的前提是什么
- 哪些地方还有歧义
- 如果歧义不消除，可能走向哪几种实现

### 2. 先定义成功标准

尽量把模糊目标改写成可验证目标，例如：

- “修复这个问题” -> “复现问题、最小修复、复现场景验证消失”
- “改一下这段代码” -> “只调整指定逻辑、验证输出变化、确认无无关 diff”

### 3. 最小改动优先

可以做：

- 修复用户明确指出的问题
- 增加完成本次任务所必需的最小测试或校验
- 删除本次改动直接造成的无用 import、变量或分支

不要顺手做：

- 改无关模块命名
- 扩展成通用框架或抽象层
- 大范围重排代码或统一格式
- 删除原本就存在但与本次任务无关的旧问题代码

### 4. 验证先于结论

在说“改好了”“修复完成”“可以了”之前，必须先跑对应验证命令或完成清晰的验证步骤。

## 常见触发词

- `修 bug`
- `最小改动`
- `别大改`
- `不要动无关代码`
- `先分析`
- `先列假设`
- `验证结果`
- `review`
- `code review`
- `debug`
- `重构`

## 补充参考

如果任务比较复杂，或者需要更细的触发场景和示例，读取 `references/scenarios.md`。
