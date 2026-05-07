# Kingdee Skill Installer 同事安装说明

这是给同事直接使用的完整安装包目录。

## 先看结论

- 不要只转发单个 `.bat`
- 请把整个 `KingdeeSkillInstaller` 目录，或 `KingdeeSkillInstaller.zip`，完整发给同事
- 第一次安装双击 `安装skill和语料.bat`
- 后续更新双击 `更新skill.bat`

## 目录必须保持完整

至少要包含：

- `安装skill和语料.bat`
- `更新skill.bat`
- `scripts\`
- `skill\`
- `corpus\release-manifest.json`

不要单独复制其中某一个文件出去运行。

## 默认行为

直接双击 `安装skill和语料.bat` 时，会：

1. 安装仓库当前正式版 skill
2. 如果包含 heavy skill，则继续下载 heavy 语料和元数据索引

默认 skill 安装目录通常是：

```text
C:\Users\你的用户名\.codex\skills\
```

heavy 语料默认目录：

- 优先：`D:\KingdeeDocs`
- 如果没有 `D:` 盘：`C:\Users\你的用户名\KingdeeDocs`

## 轻量安装（只装 2 个基础 skill）

如果只是做快速验证，或暂时不想下载 heavy 语料，可以在命令行中运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-workstation-from-github.ps1 -SkillNames kingdee-cangqiong-dev-tips,ai-coding-discipline
```

或者在当前目录下执行：

```cmd
安装skill和语料.bat -SkillNames kingdee-cangqiong-dev-tips,ai-coding-discipline
```

此时会跳过 heavy 语料下载。

## 更新

后续更新直接双击：

```text
更新skill.bat
```

如果只想更新部分 skill，也可以在命令行里追加 `-SkillNames` 参数。

## 说明

这个安装包已经优先使用同目录下的本地内容：

- 优先使用 `scripts\` 下的本地脚本
- 优先使用 `skill\` 下的本地 skill 内容
- heavy 安装时优先使用本地 `corpus\release-manifest.json`

只有这些本地内容缺失时，才会回退到 GitHub。
