# 苍穹知识库读取指南

## 路径说明

先读 `references/config.md` 获取 BASE_PATH。

苍穹库根路径：{BASE_PATH}\苍穹帮助中心全量库

若 `{BASE_PATH}` 对应目录不存在，先提示用户检查并修改 `references/config.md`，不要继续按错误路径检索。

---

## 四步查询流程

### 第一步：L1 词汇路由

用 Grep 工具搜索以下文件，匹配用户问题中的接口名、类名、报错短语、菜单词、功能词：

```
{BASE_PATH}\苍穹帮助中心全量库\search\l1-routing.jsonl
```

每行格式：`{"term": "...", "type": "...", "l2_shards": ["00","3a"], "article_ids": [...]}`

- 命中 → 取所有命中行的 l2_shards 合并去重 → 进第二步
- 未命中 → 进备用路由

**备用路由（L1 未命中时）：**

用 Grep 工具直接搜索以下目录的所有分片文件（约 11 MB，可接受）：

```
{BASE_PATH}\苍穹帮助中心全量库\search\l2-shards\
```

- 命中 → 记录 article_id → 跳至第三步
- 仍未命中 → 回答"文档库未找到相关内容，建议访问金蝶官方帮助中心"

---

### 第二步：L2 分片定位文章

只读取第一步命中的分片（通常 1-3 个）：

```
{BASE_PATH}\苍穹帮助中心全量库\search\l2-shards\{shard_id}.jsonl
```

在分片内按 `title` / `keywords` / `api_terms` / `error_terms` 字段筛选，选出最相关的 1-2 篇。

记录：`article_id`、`title`、`summary_brief`、`official_url`、`has_images`、`has_pdf`

---

### 第三步：读取 enriched-json 全文

用 Glob 工具定位文件：

```
{BASE_PATH}\苍穹帮助中心全量库\normalized\articles-enriched-json\**\{article_id}.json
```

读取以下字段：

- `title`、`official_url`
- `summary_brief`（文章摘要，含 [图片] 占位符）
- `sections[].section_title` + `sections[].section_summary`（主要文字内容，优先于 summary_brief）
- 若 `has_images: true` → 同时读取 `images[]` 数组：
  - `images[].context_before`（图片前文，描述图片展示的内容）
  - `images[].context_after`（图片后文）
  - `images[].resolved_url`（图片直链，可在浏览器查看）
- 若 `has_pdf: true` → 读取对应 PDF 转文字文件：
  ```
  {BASE_PATH}\苍穹帮助中心全量库\normalized\attachments-text\
  ```

---

### 第四步：组合回答

**文字内容：** 优先使用 `sections[].section_summary`，比 `summary_brief` 更结构化。

**图片处理规则：**

- 不要把所有图片 URL 堆砌在答案里
- 只在该步骤的文字描述不足以说明操作位置时，才附图片上下文和链接
- 格式：
  ```
  ↳ 此步骤有截图
    上文：{context_before}
    下文：{context_after}
    查看：{resolved_url}
  ```

**回答结构：**

1. 官方机制结论（来源：专题名 + 文章标题）
2. 版本限制（若有）
3. 代码实现提示（如涉及插件编写，建议同时使用 kingdee-cangqiong-dev-tips）
4. 官方链接：{official_url}

若文章含版本约束（如"V4.0 以上"、"V6.0.12"）且用户未说明版本，先询问版本再作答。

---

## 禁止直接读取的文件

| 文件 | 原因 |
|------|------|
| `search\l2-articles.jsonl`（11 MB） | 体积过大，通过 l2-shards 分片访问 |
| `search\l3-sections.jsonl` | 已从分发包移除，不再使用 |
| `search\l4-assets.jsonl` | 数据已在 enriched-json images 数组 |
| `search\l1-routing-vocab.json` | 已废弃旧词汇表 |
