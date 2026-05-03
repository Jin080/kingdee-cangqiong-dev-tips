param(
    [string]$SourceRoot,
    [string]$CorpusRoot,
    [string]$SkillRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-ResolvedSkillRoot {
    param([string]$OverrideRoot)

    if ($OverrideRoot) {
        return [System.IO.Path]::GetFullPath($OverrideRoot)
    }

    if ($env:CODEX_HOME) {
        return [System.IO.Path]::GetFullPath((Join-Path $env:CODEX_HOME "skills"))
    }

    return [System.IO.Path]::GetFullPath((Join-Path $env:USERPROFILE ".codex\skills"))
}

function Get-DefaultCorpusRoot {
    $preferredDrive = "D:\"
    if (Test-Path -LiteralPath $preferredDrive -PathType Container) {
        return [System.IO.Path]::GetFullPath((Join-Path $preferredDrive "KingdeeDocs"))
    }

    return [System.IO.Path]::GetFullPath((Join-Path $env:USERPROFILE "KingdeeDocs"))
}

function Get-ResolvedCorpusRoot {
    param([string]$OverrideRoot)

    if ($OverrideRoot) {
        return [System.IO.Path]::GetFullPath($OverrideRoot)
    }

    return Get-DefaultCorpusRoot
}

function Get-ResolvedSourceRoot {
    param([string]$OverrideRoot)

    if (-not $OverrideRoot) {
        return $null
    }

    return [System.IO.Path]::GetFullPath($OverrideRoot)
}

function Get-RequiredCorpusNames {
    return @(
        "苍穹帮助中心全量库",
        "星瀚帮助中心全量库",
        "星空帮助中心全量库"
    )
}

function Get-RequiredMetadataIndexNames {
    return @(
        "星瀚元数据-index.jsonl",
        "星空元数据-index.jsonl"
    )
}

function Assert-CorpusLayout {
    param(
        [string]$RootPath,
        [string]$Label
    )

    foreach ($name in (Get-RequiredCorpusNames)) {
        $expectedPath = Join-Path $RootPath $name
        if (-not (Test-Path -LiteralPath $expectedPath -PathType Container)) {
            throw "$Label 缺少必需目录: $expectedPath"
        }
    }

    foreach ($name in (Get-RequiredMetadataIndexNames)) {
        $expectedPath = Join-Path $RootPath $name
        if (-not (Test-Path -LiteralPath $expectedPath -PathType Leaf)) {
            throw "$Label 缺少必需文件: $expectedPath"
        }
    }
}

function Sync-CorpusDirectories {
    param(
        [string]$ResolvedSourceRoot,
        [string]$ResolvedCorpusRoot
    )

    if (-not $ResolvedSourceRoot) {
        return
    }

    Assert-CorpusLayout -RootPath $ResolvedSourceRoot -Label "语料源目录"
    New-Item -ItemType Directory -Force -Path $ResolvedCorpusRoot | Out-Null
    Write-Host "Using corpus root: $ResolvedCorpusRoot"

    foreach ($name in (Get-RequiredCorpusNames)) {
        $sourceDir = Join-Path $ResolvedSourceRoot $name
        $targetDir = [System.IO.Path]::GetFullPath((Join-Path $ResolvedCorpusRoot $name))

        if (-not $targetDir.StartsWith($ResolvedCorpusRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to sync outside corpus root: $targetDir"
        }

        if ($sourceDir.TrimEnd('\') -ieq $targetDir.TrimEnd('\')) {
            Write-Host "Source and target are the same, skip copy: $targetDir"
            continue
        }

        if (Test-Path -LiteralPath $targetDir) {
            Remove-Item -Recurse -Force -LiteralPath $targetDir
        }

        Copy-Item -LiteralPath $sourceDir -Destination $ResolvedCorpusRoot -Recurse -Force
        Write-Host "Installed corpus to $targetDir"
    }

    foreach ($name in (Get-RequiredMetadataIndexNames)) {
        $sourceFile = Join-Path $ResolvedSourceRoot $name
        $targetFile = [System.IO.Path]::GetFullPath((Join-Path $ResolvedCorpusRoot $name))

        if (-not $targetFile.StartsWith($ResolvedCorpusRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to sync outside corpus root: $targetFile"
        }

        if ($sourceFile.TrimEnd('\') -ieq $targetFile.TrimEnd('\')) {
            Write-Host "Source and target are the same, skip copy: $targetFile"
            continue
        }

        Copy-Item -LiteralPath $sourceFile -Destination $targetFile -Force
        Write-Host "Installed metadata index to $targetFile"
    }
}

function Set-HeavySkillBasePath {
    param(
        [string]$ResolvedSkillRoot,
        [string]$ResolvedCorpusRoot
    )

    $skillNames = @(
        "kingdee-cangqiong-heavy",
        "kingdee-xinghan-heavy",
        "kingdee-xingkong-heavy"
    )

    foreach ($skillName in $skillNames) {
        $configPath = Join-Path $ResolvedSkillRoot "$skillName\references\config.md"
        if (-not (Test-Path -LiteralPath $configPath)) {
            Write-Warning "Skip config writeback because file not found: $configPath"
            continue
        }

        $content = Get-Content -LiteralPath $configPath -Raw
        $newContent = [regex]::Replace($content, '(?m)^BASE_PATH:\s*.*$', ("BASE_PATH: {0}" -f $ResolvedCorpusRoot))

        if ($newContent -eq $content) {
            throw "Failed to rewrite BASE_PATH in $configPath"
        }

        Set-Content -LiteralPath $configPath -Value $newContent -Encoding UTF8
        Write-Host "Updated BASE_PATH in $configPath"
    }
}

$resolvedSkillRoot = Get-ResolvedSkillRoot -OverrideRoot $SkillRoot
$resolvedCorpusRoot = Get-ResolvedCorpusRoot -OverrideRoot $CorpusRoot
$resolvedSourceRoot = Get-ResolvedSourceRoot -OverrideRoot $SourceRoot

Sync-CorpusDirectories -ResolvedSourceRoot $resolvedSourceRoot -ResolvedCorpusRoot $resolvedCorpusRoot
Assert-CorpusLayout -RootPath $resolvedCorpusRoot -Label "语料安装目录"
Set-HeavySkillBasePath -ResolvedSkillRoot $resolvedSkillRoot -ResolvedCorpusRoot $resolvedCorpusRoot

Write-Host "Corpus root is ready: $resolvedCorpusRoot"
Write-Host "Heavy skill configs were updated under: $resolvedSkillRoot"
