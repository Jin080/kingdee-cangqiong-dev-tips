# kingdee-cangqiong-dev-tips

团队协作维护的金蝶苍穹 / BOS 开发 skill 仓库。

这个仓库把“正式发布版 skill”和“团队投稿内容”分开管理：

- `skill/kingdee-cangqiong-dev-tips/`：正式发布版 skill，普通同事本地只使用这个目录中的内容
- `contributions/`：同事提交的原始经验，维护人每周整理
- `templates/`：投稿模板
- `scripts/`：安装和更新正式版 skill 的脚本
- `贡献审核与整合规则.md`：维护人审核投稿和整合正式 skill 的仓库级规则，不属于 skill 本体

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

执行下面命令即可从 GitHub 下载 `main` 分支中的正式 skill，并安装到本机 Codex skills 目录：

```powershell
powershell -ExecutionPolicy Bypass -Command "& {
  $script = Join-Path $env:TEMP 'install-kingdee-skill.ps1'
  Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Jin080/kingdee-cangqiong-dev-tips/main/scripts/install-skill-from-github.ps1' -OutFile $script
  & powershell -ExecutionPolicy Bypass -File $script
}"
```

默认安装到：

```text
C:\Users\你的用户名\.codex\skills\kingdee-cangqiong-dev-tips
```

## 普通同事：后续更新正式 skill

维护人发布正式版后，普通同事只需要执行一条更新命令：

```powershell
powershell -ExecutionPolicy Bypass -Command "& {
  $script = Join-Path $env:TEMP 'update-kingdee-skill.ps1'
  Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Jin080/kingdee-cangqiong-dev-tips/main/scripts/update-skill-from-github.ps1' -OutFile $script
  & powershell -ExecutionPolicy Bypass -File $script
}"
```

这个更新流程只会同步：

- `skill/kingdee-cangqiong-dev-tips/`

不会把下面这些目录安装到 Codex skills 目录：

- `contributions/`
- `templates/`
- `README.md`

## 投稿目录规范

普通同事的投稿只允许放到：

```text
contributions/YYYY-MM/
```

示例：

```text
contributions/2026-04/2026-04-27-zhangsan-f7-parent-child.md
contributions/2026-04/2026-04-27-lisi-save-plugin.md
```

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
4. 在 `contributions/YYYY-MM/` 下新建一个 `.md`
5. 选择 `Create a new branch for this commit and start a pull request`
6. 提交 PR 到 `develop`

## 维护人：每周整理发布

维护人每周做一次：

1. 查看 `develop` 上本周新增投稿
2. 去重、合并相同问题、删除一次性项目噪音
3. 把可复用结论整理进 `skill/kingdee-cangqiong-dev-tips/`
4. 发起 PR 合并到 `main`
5. 通知团队执行更新命令

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
