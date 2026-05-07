# 金蝶苍穹 Skill 路由索引

这份索引只负责两件事：

1. 把开发问题路由到最相关的主题文件
2. 控制读取范围，避免每次都全量读取所有参考文档

## 渐进式披露规则

固定读取顺序：

1. 先读本索引
2. 再读 1 个最相关主题文件
3. 只有明显跨主题时，才补读第 2 个主题文件

禁止默认行为：

- 不要先把 `pages.md`、`interaction.md`、`backend-data.md`、`operations.md` 全部读一遍
- 不要因为问题里出现多个关键词，就机械加载全部文档
- `overview.md` 只在需要确认资料来源或知识范围时再读取，不作为默认正文入口

## 一级路由：先按运行位置判断

- 明显是界面插件、表单事件、列表取值：优先在 `pages.md` 或 `interaction.md` 之间判断
- 明显是服务端对象、保存查询删除、ORM：优先读 `backend-data.md`
- 明显是代码触发操作、操作结果、界面刷新、插件传参：优先读 `operations.md`

## 二级路由：按动作和对象细分

### `pages.md`

适用问题：

- 表单页面字段取值
- 页面字段赋值
- 基础资料属性取值
- 单据体/子单据体取值与赋值
- 列表页面选中行、列表字段
- 页面参数、View 状态控制

优先关键词：

- `getModel`
- `getValue`
- `setValue`
- `单据体`
- `子单据体`
- `列表`
- `选中行`
- `页面参数`

### `interaction.md`

适用问题：

- 值更新事件
- 用户点击事件
- 父子页面通信
- F7 选择界面
- 前后端交互
- 代码赋值后是否触发联动

优先关键词：

- `propertyChanged`
- `beginInit`
- `endInit`
- `click`
- `itemClick`
- `父子页面`
- `F7`
- `过滤`

### `backend-data.md`

适用问题：

- 新建数据对象
- 保存、查询、删除数据对象
- DynamicObject 处理
- ORM 查询
- 过滤条件

优先关键词：

- `DynamicObject`
- `DynamicObjectCollection`
- `QueryServiceHelper`
- `BusinessDataServiceHelper`
- `SaveServiceHelper`
- `QFilter`
- `ORM`

### `operations.md`

适用问题：

- 代码触发提交、审核、保存等操作
- 操作后刷新界面
- 操作后提示
- 界面插件与操作插件传参

优先关键词：

- `invokeOperation`
- `OperationServiceHelper`
- `afterDoOperation`
- `updateView`
- `操作插件`
- `提示`
- `传参`

## 跨主题判定

只有在下面这类问题里，才建议补读第 2 个主题文件：

- “页面赋值后为什么没有触发联动”：
  先读 `pages.md`，再补读 `interaction.md`
- “前端拿到值后要调用提交/审核操作”：
  先读 `pages.md` 或 `interaction.md`，再补读 `operations.md`
- “保存前先拼装数据对象，再执行操作”：
  先读 `backend-data.md`，再补读 `operations.md`

如果主问题已经能在一个主题里解决，就不要再继续扩读。
