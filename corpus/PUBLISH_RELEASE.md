# heavy 语料 Release 发布步骤

这份说明给维护人使用，用来把本机现有语料整理成 GitHub Release 资产。

## 一、发布前提

本机语料根目录当前约定为：

```text
E:\T1
```

目录下应至少存在：

- `苍穹帮助中心全量库`
- `星瀚帮助中心全量库`
- `星空帮助中心全量库`
- `星瀚元数据-index.jsonl`
- `星空元数据-index.jsonl`

## 二、先本地打包 Release 资产

执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build-corpus-release-assets.ps1
```

如果你想把输出放到指定目录，例如：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build-corpus-release-assets.ps1 -OutputRoot E:\AI\release-assets
```

默认输出目录是：

```text
%TEMP%\kingdee-corpus-release-assets
```

## 三、脚本产物

脚本会生成 5 个文件：

- `cangqiong-help-center.zip`
- `xinghan-help-center.zip`
- `xingkong-help-center.zip`
- `xinghan-metadata-index.jsonl`
- `xingkong-metadata-index.jsonl`

这 5 个文件名必须与：

- `corpus/release-manifest.json`

保持一致。

## 四、创建或更新 GitHub Release

在当前仓库创建一个 tag / Release：

```text
heavy-corpus-v1
```

然后把上面 5 个文件上传为该 Release 的资产。

如果以后语料有新版本，建议：

1. 先更新 Release 资产
2. 再同步更新 `corpus/release-manifest.json` 中的 `release_tag`

例如下一版可以改成：

```json
"release_tag": "heavy-corpus-v2"
```

## 五、发布后同事的实际效果

发布完成后：

1. 同事第一次执行 `安装skill和语料.bat`
2. 脚本会先安装 skill
3. 如果安装集合里包含 heavy skill，则自动从该 Release 下载 5 个资产
4. 语料默认落到：
   - `D:\KingdeeDocs`
   - 若无 `D:` 盘，则自动改为 `C:\Users\<用户名>\KingdeeDocs`
5. 脚本会自动把 `BASE_PATH` 回写到 3 个 heavy skill 的 `references/config.md`

后续同事执行 `更新skill.bat` 时：

- 只更新 skill
- 不重复下载 heavy 语料

## 六、注意事项

- 不要把数 GB 语料直接提交进 Git 仓库
- Release 资产是第一次安装语料的正式入口
- 若你替换了语料内容但没换 Release tag，同事重新安装时会下载同名新资产
- 如果未来需要可回滚的版本管理，建议每次语料更新都升一个新 tag
