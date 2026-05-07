# kingdee-cangqiong-dev-tips

团队协作维护的多 skill 仓库，当前以金蝶苍穹 / BOS 开发和 AI 编码协作为主。

这个仓库把“正式发布版 skill”和“团队投稿内容”分开管理：

- `skill/`：正式发布版 skill 目录，下面可以放多个正式 skill，普通同事本地真正使用的就是这里的内容
- `contributions/`：同事提交的原始经验，维护人每周整理
- `templates/`：投稿模板
- `scripts/`：安装和更新正式版 skill 的脚本
- `corpus/`：heavy skill 语料发布清单和维护说明
- `贡献审核与整合规则.md`：维护人审核投稿和整合正式 skill 的仓库级规则，不属于 skill 本体

当前正式 skill：

- `skill/kingdee-cangqiong-dev-tips/`：金蝶苍穹 / BOS 开发知识
- `skill/ai-coding-discipline/`：AI 编码纪律、最小改动、验证闭环、review / debug 过程约束
- `skill/kingdee-cangqiong-heavy/`：苍穹官方帮助中心重度知识库，回答平台机制、版本边界、官方报错与平台级说明
- `skill/kingdee-xinghan-heavy/`：星瀚官方帮助中心重度知识库，回答星瀚产品层功能、配置、操作步骤与报错
- `skill/kingdee-xingkong-heavy/`：星空官方帮助中心重度知识库，回答星空产品层功能、配置、操作步骤与报错

> 注意：
> 这 3 个官方知识 skill 依赖本地帮助中心语料包，不是纯文本小 skill。
> 安装后需要按各自 `references/config.md` 把 `BASE_PATH` 改成当前机器上的语料根目录。
> 仓库更新脚本已经处理为“保留本机已修改过的 config.md”，后续更新不会把本机路径冲回默认示例值。
> 若要让星瀚 / 星空 skill 具备“写插件时识别表单、字段、按钮标识”的能力，还需要在同一个 `BASE_PATH` 根目录下放入：
> `星瀚元数据-index.jsonl`、`星空元数据-index.jsonl`

## 协作模型

这个仓库建议这样使用：

- 仓库维护人：你
- 团队成员：加入仓库作为 `Write` 协作者
- 普通同事本地：只安装正式版 skill，不需要把整个仓库作为日常工作目录
- 投稿方式：通过 GitHub 网页创建分支和 PR，把经验文档放进指定投稿目录

这样做的原因很直接：

- 普通同事不需要学完整 Git 流程
- 本地不需要长期保留一份仓库副本
- 维护人可以集中整理投稿内容，避免正式 skill 失控膨胀

## 分支说明

- `main`：稳定发布分支，普通使用者只从这里更新正式 skill
- `develop`：收集和整理分支，团队投稿先合并到这里
- `feature/<name>-<topic>`：个人或临时整理分支

建议规则：

- 普通同事的投稿 PR：`feature/*` 或网页自动分支 -> `develop`
- 维护人的每周整理 PR：整理分支 -> `main`

## 权限建议

团队内部 12 人建议都加入仓库，权限设为：

- `Write`

不要给普通同事：

- `Admin`

配合 ruleset 后，`Write` 权限足够让他们：

- 创建分支
- 提交文件
- 发起 PR
- 参与审核

同时又不会让他们直接推送 `main` 和 `develop`。

## 普通同事：第一次安装正式 skill

普通同事本地只需要安装正式版 skill，不需要 clone 整个仓库。

执行下面命令即可从 GitHub 下载 `main` 分支中的全部正式 skill，并在需要时自动下载 heavy skill 语料：

```powershell
powershell -ExecutionPolicy Bypass -Command "& {
  $script = Join-Path $env:TEMP 'install-kingdee-workstation.ps1'
  Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Jin080/kingdee-cangqiong-dev-tips/main/scripts/install-workstation-from-github.ps1' -OutFile $script
  & powershell -ExecutionPolicy Bypass -File $script
}"
```

默认安装到：

```text
C:\Users\你的用户名\.codex\skills\
```

语料默认安装目录：

```text
D:\KingdeeDocs
```

如果目标机器没有 `D:` 盘，则自动改用：

```text
C:\Users\你的用户名\KingdeeDocs
```

如果该目录不存在，脚本会自动创建。

脚本会做两件事：

1. 把仓库 `skill/` 目录下的所有正式 skill 同步到本机 Codex skills 目录
2. 如果本次安装包含 heavy skill，则自动从当前仓库的 GitHub Release 资产下载语料和元数据索引，并回写 3 个 heavy skill 的 `references/config.md`

如果只想安装指定的正式 skill，也可以带 `-SkillNames`。例如只安装：

- `kingdee-cangqiong-heavy`
- `kingdee-xinghan-heavy`

命令示例：

```powershell
powershell -ExecutionPolicy Bypass -Command "& {
  $script = Join-Path $env:TEMP 'install-kingdee-workstation.ps1'
  Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Jin080/kingdee-cangqiong-dev-tips/main/scripts/install-workstation-from-github.ps1' -OutFile $script
  & powershell -ExecutionPolicy Bypass -File $script -SkillNames 'kingdee-cangqiong-heavy','kingdee-xinghan-heavy'
}"
```

如果只安装轻量 skill，例如：

- `kingdee-cangqiong-dev-tips`
- `ai-coding-discipline`

则不会触发 heavy 语料下载。

## 普通同事：后续更新正式 skill

维护人发布正式版后，普通同事只需要执行一条更新命令：

```powershell
powershell -ExecutionPolicy Bypass -Command "& {
  $script = Join-Path $env:TEMP 'update-kingdee-skill.ps1'
  Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Jin080/kingdee-cangqiong-dev-tips/main/scripts/update-skill-from-github.ps1' -OutFile $script
  & powershell -ExecutionPolicy Bypass -File $script
}"
```

这个更新流程只会同步仓库 `skill/` 目录下的全部正式 skill，例如：

- `skill/kingdee-cangqiong-dev-tips/`
- `skill/ai-coding-discipline/`
- `skill/kingdee-cangqiong-heavy/`
- `skill/kingdee-xinghan-heavy/`
- `skill/kingdee-xingkong-heavy/`

不会把下面这些目录安装到 Codex skills 目录：

- `contributions/`
- `templates/`
- `corpus/`
- `README.md`

后续更新不会重复下载 heavy 语料，只更新 skill 本体。

如果你希望同事直接双击操作：

- 第一次安装可把仓库根目录中的 `安装skill和语料.bat` 发给他们
- 后续更新可把仓库根目录中的 `更新skill.bat` 发给他们使用

如果只想更新指定 skill，也可以同样带 `-SkillNames`。例如只更新：

- `kingdee-xinghan-heavy`
- `kingdee-xingkong-heavy`

命令示例：

```powershell
powershell -ExecutionPolicy Bypass -Command "& {
  $script = Join-Path $env:TEMP 'update-kingdee-skill.ps1'
  Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Jin080/kingdee-cangqiong-dev-tips/main/scripts/update-skill-from-github.ps1' -OutFile $script
  & powershell -ExecutionPolicy Bypass -File $script -SkillNames 'kingdee-xinghan-heavy','kingdee-xingkong-heavy'
}"
```

## 官方知识 skill 的额外前提

下面 3 个 skill 依赖本地外置语料库：

- `skill/kingdee-cangqiong-heavy/`
- `skill/kingdee-xinghan-heavy/`
- `skill/kingdee-xingkong-heavy/`

默认情况下，第一次安装脚本会自动尝试补齐这些内容。

如果你不走“第一次安装脚本”，而是手工安装，则请确认两件事：

1. 目标机器上已经有对应的帮助中心全量库
2. 每个 skill 的 `references/config.md` 中 `BASE_PATH` 已改成该机器的语料根目录

例如，如果某台机器把语料放在：

```text
E:\AI\kingdee-docs
```

且其下存在：

- `E:\AI\kingdee-docs\苍穹帮助中心全量库`
- `E:\AI\kingdee-docs\星瀚帮助中心全量库`
- `E:\AI\kingdee-docs\星空帮助中心全量库`
- `E:\AI\kingdee-docs\星瀚元数据-index.jsonl`
- `E:\AI\kingdee-docs\星空元数据-index.jsonl`

那么应把这 3 个 skill 的 `BASE_PATH` 都改成：

```text
E:\AI\kingdee-docs
```

如果希望让同事手工指定语料安装目录，并自动回写这 3 个 heavy skill 的 `BASE_PATH`，可以使用：

```powershell
powershell -ExecutionPolicy Bypass -Command "& {
  $script = Join-Path $env:TEMP 'install-kingdee-corpus.ps1'
  Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Jin080/kingdee-cangqiong-dev-tips/main/scripts/install-corpus-from-github.ps1' -OutFile $script
  & powershell -ExecutionPolicy Bypass -File $script -SourceRoot 'D:\已解压的语料包根目录' -CorpusRoot 'E:\AI\kingdee-docs'
}"
```

说明：

- `SourceRoot`：语料包当前所在根目录，目录下应直接包含三套语料目录
- 同时还应直接包含：
  - `星瀚元数据-index.jsonl`
  - `星空元数据-index.jsonl`
- `CorpusRoot`：同事自己想放语料的目标根目录
- 脚本完成后会自动复制三套帮助中心语料目录和两个元数据索引，并把三个 heavy skill 的 `references/config.md` 写成这个 `CorpusRoot`

如果语料已经提前放好，只想回写 `BASE_PATH`，可以省略 `SourceRoot`：

```powershell
powershell -ExecutionPolicy Bypass -Command "& {
  $script = Join-Path $env:TEMP 'install-kingdee-corpus.ps1'
  Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Jin080/kingdee-cangqiong-dev-tips/main/scripts/install-corpus-from-github.ps1' -OutFile $script
  & powershell -ExecutionPolicy Bypass -File $script -CorpusRoot 'E:\AI\kingdee-docs'
}"
```

维护人需注意：

- 仓库本体不直接保存数 GB 语料
- heavy 语料通过当前仓库的 GitHub Release 资产分发
- 发布清单见 `corpus/release-manifest.json`
- 维护说明见 `corpus/README.md`

## 投稿目录规范

普通同事的投稿只允许放到：

```text
contributions/YYYY-MM-DD/
```

示例：

```text
contributions/2026-04-30/f7-parent-child.md
contributions/2026-04-30/save-plugin.md
```

文件名不强制统一格式，只要能看出主题即可。

不要把实际投稿内容放到：

- `skill/`
- `templates/`
- 仓库根目录

`templates/` 只放模板，不放真实投稿。

## 普通同事：如何投稿

普通同事不要求本地 clone 仓库，直接走 GitHub 网页即可。

流程：

1. 打开仓库网页
2. 进入 `templates/contribution-template.md`
3. 复制模板内容
4. 在 `contributions/YYYY-MM-DD/` 下新建一个 `.md`
5. 选择 `Create a new branch for this commit and start a pull request`
6. 提交 PR 到 `develop`

## 维护人：每周整理发布

维护人每周做一次：

1. 查看 `develop` 上本周新增投稿
2. 去重、合并相同问题、删除一次性项目噪音
3. 把可复用结论整理进对应的正式 skill 目录，并同步更新该 skill 的索引
4. 发起 PR 合并到 `main`
5. 通知团队执行更新命令

### 维护人：发布前一键校验

在准备发版前，先在仓库根目录运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-release.ps1
```

这个入口会用临时目录做最小可执行校验，重点覆盖当前发布最容易回归的几项：

1. 指定 `-SkillNames` 时只安装被选中的正式 skill
2. heavy skill 语料安装后，三份 `references/config.md` 会回写到目标 `CorpusRoot`
3. 走更新/重装路径时，本机已改过的 `references/config.md` 会被保留
4. 典型失败场景仍然能给出明确诊断，而不是只报脚本失败

如果你想保留校验现场排查问题，可加：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-release.ps1 -KeepWorkRoot
```

脚本成功时默认自动清理临时目录；失败时会自动保留现场并输出对应路径。

## 为什么不要让普通同事直接改正式 skill

因为投稿文档和正式 skill 不是同一种东西。

投稿文档可以保留：

- 问题背景
- 排查过程
- 项目上下文

正式 skill 必须强调：

- 可检索
- 可复用
- 不堆重复案例
- 不包含太多项目私有噪音

## GitHub 仓库建议配置

请保持这些配置：

- 保护 `main`，禁止直接 push
- 保护 `develop`，禁止直接 push
- 所有改动必须走 PR
- 普通同事投稿 PR 合并到 `develop`
- 维护人整理后再合并到 `main`
- 维护人账号加入 ruleset 的 `Bypass list`

这样最终效果是：

- 普通同事必须 PR
- 维护人可以在每周整理发布时绕过审批合并正式版
