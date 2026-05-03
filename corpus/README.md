# 语料发布说明

这个目录只保存 heavy skill 语料的发布清单，不保存真正的大文件语料。

原因很简单：

- 三套帮助中心语料和两个元数据索引总体量较大
- 不适合直接放进 Git 仓库历史
- 团队第一次安装时，改为从当前仓库的 GitHub Release 资产自动下载

## 当前发布清单

见：

- `release-manifest.json`
- `PUBLISH_RELEASE.md`

其中约定了一个 Release tag：

- `heavy-corpus-v1`

以及 5 个发布资产文件名：

- `cangqiong-help-center.zip`
- `xinghan-help-center.zip`
- `xingkong-help-center.zip`
- `xinghan-metadata-index.jsonl`
- `xingkong-metadata-index.jsonl`

## 维护人辅助脚本

仓库内还提供了一个本地打包脚本：

- `scripts/build-corpus-release-assets.ps1`

它会把维护机上的现有语料目录和两个元数据索引整理成上面这 5 个 Release 资产文件。

## 维护人打包要求

请把本机语料根目录中的以下内容整理为 Release 资产：

- `苍穹帮助中心全量库`
- `星瀚帮助中心全量库`
- `星空帮助中心全量库`
- `星瀚元数据-index.jsonl`
- `星空元数据-index.jsonl`

### zip 资产要求

3 个帮助中心目录请分别压缩为 zip 上传：

- `cangqiong-help-center.zip`
- `xinghan-help-center.zip`
- `xingkong-help-center.zip`

建议要求：

- 每个 zip 解压后，内部最好直接得到一个目录
- 目录名建议分别是：
  - `苍穹帮助中心全量库`
  - `星瀚帮助中心全量库`
  - `星空帮助中心全量库`

如果 zip 内目录名不同，安装脚本也会尝试兼容“只有一个顶层目录”的情况。

### 元数据索引要求

两个索引文件直接作为 Release 资产上传：

- `xinghan-metadata-index.jsonl`
- `xingkong-metadata-index.jsonl`

## 同事安装后的默认目录

首次安装语料时，脚本默认：

1. 优先安装到 `D:\KingdeeDocs`
2. 若目标机器没有 `D:` 盘，则自动改用：
   `C:\Users\<用户名>\KingdeeDocs`

如果目录不存在，脚本会自动创建。

## 后续更新规则

- 第一次安装：下载 skill + 下载语料资产 + 回写 heavy skill 的 `BASE_PATH`
- 后续执行 `update-skill`：只更新 skill，不重复下载语料
- 若以后更换语料位置，可单独再次执行 `install-corpus-from-github.ps1`
