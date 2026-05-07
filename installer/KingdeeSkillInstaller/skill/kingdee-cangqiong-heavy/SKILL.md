---
name: kingdee-cangqiong-heavy
description: 当用户询问苍穹/BOS/COSMIC 平台的官方文档、机制原理、架构概念、API 文档说明、版本差异、平台级报错原因时触发。也在用户明确说"苍穹"或"BOS"且不是问代码实现时触发。不处理星瀚或星空特有的产品功能。不处理纯代码实现问题（代码实现由 kingdee-cangqiong-dev-tips 负责）。
---

# 金蝶苍穹重度知识库

苍穹是金蝶低代码开发平台底座。本技能负责回答苍穹平台机制、官方文档和报错解释类问题。代码实现问题由 kingdee-cangqiong-dev-tips 负责。

## 工作方式

1. 先读 `references/config.md` 获取 BASE_PATH。
2. 再读 `references/reading-guide.md`，按其中的四步查询流程执行。

## 回答规则

- 回答开头说明所引用的官方文档来源（专题名 + 文章标题）。
- 推荐回答顺序：① 官方机制结论 → ② 版本边界/限制 → ③ 官方链接。
- 若文章含版本约束（如"V4.0 以上"）且用户未说明版本，先询问版本再作答。
- 若涉及代码实现，提示用户同时使用 kingdee-cangqiong-dev-tips。
- 每次回答后附 official_url 对应的官方链接。

## 禁止行为

- 不在无官方证据时编造 SDK、接口或报错原因。
- 不把星瀚或星空的产品层内容当作苍穹平台事实。
- 不处理纯代码实现问题。

## 参考文件

- `references/config.md`：路径配置（安装时修改）
- `references/reading-guide.md`：查询流程与读取指令
