---
name: kingdee-cangqiong-dev-tips
description: Use when Codex needs to answer, design, review, or integrate Kingdee Cangqiong / BOS development tasks and knowledge, including 苍穹开发问答、BOS 插件、表单或列表页面取值/赋值、单据体或子单据体处理、父子页面交互、F7 选择界面、DynamicObject 数据处理、SaveServiceHelper、BusinessDataServiceHelper、QueryServiceHelper、OperationServiceHelper，以及审核团队投稿并把可复用结论整合进这份 skill.
---

# 金蝶苍穹开发速查

使用这个 skill 处理金蝶云苍穹 / BOS 常见开发问答，以及维护这份 skill 的投稿审核和知识整合。知识主体来源于《苍穹开发必备100个小知识 V2.1》，正文已拆成按主题可检索的参考文件。

## 两种模式

### 1. 问答模式

用于回答苍穹开发具体问题。

工作顺序：

1. 先读取 `references/index.md`，只做主题路由，不要先把所有参考文件都读一遍。
2. 根据索引判断问题落点，再只读取 1 个最相关的主题文件。
3. 仅当问题明显跨主题时，才补读第 2 个主题文件。
4. 用当前项目真实的单据、字段、实体编码、操作编码、插件类型替换示例占位值。

### 2. 维护模式

用于审核团队投稿、给出中文修改建议、把可复用结论整合进正式 skill。

工作顺序：

1. 先读取 `references/contribution-governance.md`。
2. 再读取 `references/index.md` 判断投稿应该归入哪个主题文件。
3. 只读取与投稿主题最相关的参考文件，不要为了整合一个投稿而全量读取所有文档。
4. 按治理规则判断是直接整合、补充后整合、仅归档贡献，还是退回。

## 主题分流

- 页面取值、赋值、列表、页面参数、View 控制、单据体/子单据体：读取 `references/pages.md`
- 前后端交互、值更新事件、点击事件、父子页面通信、F7 选择界面：读取 `references/interaction.md`
- 新建/保存/查询/删除数据对象、DynamicObject、过滤条件、ORM：读取 `references/backend-data.md`
- 代码触发操作、刷新、提示、界面插件和操作插件传参：读取 `references/operations.md`
- 先不确定落点时：先看 `references/index.md`

## 检索建议

- 优先按“运行位置 + 动作 + 对象”组关键词，例如 `界面插件 propertyChanged 基础资料赋值`、`服务端 QueryServiceHelper 过滤条件`。
- API 名称通常比自然语言更稳定，可直接搜 `getModel`、`getValue`、`getEntryEntity`、`DynamicObject`、`QueryServiceHelper`、`BusinessDataServiceHelper`、`SaveServiceHelper`、`OperationServiceHelper`。
- 需要快速定位时，优先用 `rg "<关键字>" skill/kingdee-cangqiong-dev-tips/references`

## 改写规则

- 把文档里的 `"文本字段标识"`、`"entryentity"`、`"kded_simplebill"`、示例单据名等占位值替换成当前项目真实标识。
- 先分清运行位置。界面插件问题优先沿用 `this.getView()`、`this.getModel()`、页面事件；服务端数据问题优先沿用 `DynamicObject`、ORM、各类 ServiceHelper。
- 如果用户只问“怎么做”，先给最短可用片段，再补 1 到 2 句说明它应放在哪个插件或事件里。
- 如果示例依赖表单设计器引用字段、基础资料属性、元数据配置，要显式提醒这些前置条件。
- 不要虚构苍穹 API。文档没有覆盖的部分，要基于当前代码库或现有 SDK 用法补证据。

## 维护规则

- 正式 skill 只保留可复用结论，不原样搬运项目现场过程。
- 同类问题优先合并到已有小节，不为单次案例新建大段重复内容。
- 新增内容后要同步更新 `references/index.md`，确保后续仍能先查索引再读正文。
- 如果投稿不足以形成稳定结论，允许保留在 `contributions/`，但不要污染正式 skill。

## 常见误区

- 不要把界面插件代码直接搬到服务端逻辑里；`this.getView()`、`this.getModel()` 这一类调用先确认运行上下文。
- 不要直接照抄示例里的字段标识和实体编码；这些大多只是教学占位值。
- 不要只给 API 名称不给落点；回答时说明代码应该放在什么插件、事件或操作阶段。
- 不要为了一次审核把所有参考文档全量读入；这会降低检索效率，也违背渐进式披露目标。

## 参考文件

- `references/index.md`: 主题路由索引、检索入口、渐进式披露规则
- `references/contribution-governance.md`: 投稿审核标准、整合标准、中文反馈模板
- `references/overview.md`: 原始资料说明
- `references/pages.md`: 页面相关知识
- `references/interaction.md`: 交互相关知识
- `references/backend-data.md`: 后端数据相关知识
- `references/operations.md`: 操作相关知识
