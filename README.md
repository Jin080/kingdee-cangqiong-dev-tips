# kingdee-cangqiong-dev-tips

团队协作维护的金蝶苍穹 / BOS 开发 skill 仓库。

这个仓库把“原始经验沉淀”和“正式发布版 skill”分开管理：

- `skill/kingdee-cangqiong-dev-tips/`：正式发布版 skill
- `contributions/`：同事提交的原始增量经验

## 分支说明

- `main`：稳定发布分支，普通使用者只从这里更新
- `develop`：收集和整理分支，团队贡献先合并到这里
- `feature/<name>-<topic>`：个人临时工作分支

`develop` 和 `feature/*` 的区别：

- `develop` 是团队共享收集分支
- `feature/*` 是某个人本次提交经验时的个人工作分支

不要直接在 `develop` 上长期写内容。每次提交都从 `develop` 拉出一个 `feature/*` 分支，再提 PR 回 `develop`。

## 普通使用者：首次安装

建议把仓库 clone 到固定目录：

```powershell
git clone https://github.com/Jin080/kingdee-cangqiong-dev-tips.git "$env:USERPROFILE\.codex-skill-hub"
cd "$env:USERPROFILE\.codex-skill-hub"
powershell -ExecutionPolicy Bypass -File .\scripts\install-skill.ps1
```

## 普通使用者：一行更新

```powershell
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.codex-skill-hub\scripts\update-skill.ps1"
```

说明：

- `git pull` 只会更新仓库目录
- 不会自动把 skill 同步到 Codex skills 目录
- 真正负责“拉取 + 同步”的是 `update-skill.ps1`

## 自定义 skill 目录

脚本按下面优先级解析目标目录：

1. `-SkillRoot`
2. `CODEX_HOME\skills`
3. `%USERPROFILE%\.codex\skills`

示例：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-skill.ps1 -SkillRoot "D:\Codex\skills"
```

## 团队成员：如何提交经验

先切到 `develop`，然后从它创建个人分支：

```powershell
git clone https://github.com/Jin080/kingdee-cangqiong-dev-tips.git
cd kingdee-cangqiong-dev-tips
git checkout develop
git pull origin develop
git checkout -b feature/zhangsan-f7-parent-child
```

复制模板并填写内容：

```powershell
Copy-Item .\templates\contribution-template.md .\contributions\2026-04\2026-04-25-zhangsan-f7-parent-child.md
```

提交并推送：

```powershell
git add .\contributions\2026-04\2026-04-25-zhangsan-f7-parent-child.md
git commit -m "docs: add F7 parent-child communication notes"
git push -u origin feature/zhangsan-f7-parent-child
```

然后在 GitHub 发起 PR：

- 来源分支：`feature/zhangsan-f7-parent-child`
- 目标分支：`develop`

## 维护人：每周发布流程

1. 查看本周进入 `develop` 的贡献
2. 去重、合并同类项、删除一次性上下文
3. 把可复用结论整理进 `skill/kingdee-cangqiong-dev-tips/`
4. 从 `develop` 合并到 `main`
5. 打发布 tag，例如 `v2026.04.25`

## 为什么不要直接改发布版 skill

因为“这次我是怎么解决的”和“下次别人如何快速解决类似问题”不是同一种文档。

贡献记录允许保留上下文；正式 skill 必须保持：

- 可检索
- 可复用
- 不堆重复案例
- 不包含太多项目私有噪音

## GitHub 仓库建议配置

请在仓库设置页手工配置：

- 保护 `main`，禁止直接 push
- 保护 `develop`，禁止直接 push
- 所有改动必须走 PR
- `main` 至少 1 个审批后才能合并
- `develop` 建议也要求维护人审核
