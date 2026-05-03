param(
    [string]$SourceRoot = "E:\T1",
    [string]$OutputRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-ResolvedOutputRoot {
    param([string]$OverrideRoot)

    if ($OverrideRoot) {
        return [System.IO.Path]::GetFullPath($OverrideRoot)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $env:TEMP "kingdee-corpus-release-assets"))
}

function Assert-PathExists {
    param(
        [string]$Path,
        [string]$Label,
        [ValidateSet("Leaf","Container")]
        [string]$PathType
    )

    if (-not (Test-Path -LiteralPath $Path -PathType $PathType)) {
        throw "$Label 不存在: $Path"
    }
}

function New-CleanDirectory {
    param([string]$Path)

    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path $Path | Out-Null
}

function Build-ZipFromDirectory {
    param(
        [string]$SourceDir,
        [string]$ArchivePath
    )

    $stagingRoot = Join-Path ([System.IO.Path]::GetDirectoryName($ArchivePath)) ([System.Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Force -Path $stagingRoot | Out-Null

    try {
        $dirName = Split-Path -Leaf $SourceDir
        $stagedDir = Join-Path $stagingRoot $dirName
        Copy-Item -LiteralPath $SourceDir -Destination $stagingRoot -Recurse -Force

        if (Test-Path -LiteralPath $ArchivePath) {
            Remove-Item -LiteralPath $ArchivePath -Force
        }

        Compress-Archive -LiteralPath $stagedDir -DestinationPath $ArchivePath -CompressionLevel Optimal
        Write-Host "Built archive: $ArchivePath"
    }
    finally {
        if (Test-Path -LiteralPath $stagingRoot) {
            Remove-Item -LiteralPath $stagingRoot -Recurse -Force
        }
    }
}

$resolvedSourceRoot = [System.IO.Path]::GetFullPath($SourceRoot)
$resolvedOutputRoot = Get-ResolvedOutputRoot -OverrideRoot $OutputRoot
New-CleanDirectory -Path $resolvedOutputRoot

$corpusDirectories = @(
    @{ Name = "苍穹帮助中心全量库"; Archive = "cangqiong-help-center.zip" },
    @{ Name = "星瀚帮助中心全量库"; Archive = "xinghan-help-center.zip" },
    @{ Name = "星空帮助中心全量库"; Archive = "xingkong-help-center.zip" }
)

$metadataFiles = @(
    @{ Name = "星瀚元数据-index.jsonl"; Output = "xinghan-metadata-index.jsonl" },
    @{ Name = "星空元数据-index.jsonl"; Output = "xingkong-metadata-index.jsonl" }
)

foreach ($item in $corpusDirectories) {
    $sourceDir = Join-Path $resolvedSourceRoot $item.Name
    Assert-PathExists -Path $sourceDir -Label "帮助中心目录" -PathType Container
    Build-ZipFromDirectory -SourceDir $sourceDir -ArchivePath (Join-Path $resolvedOutputRoot $item.Archive)
}

foreach ($item in $metadataFiles) {
    $sourceFile = Join-Path $resolvedSourceRoot $item.Name
    Assert-PathExists -Path $sourceFile -Label "元数据索引文件" -PathType Leaf

    $targetFile = Join-Path $resolvedOutputRoot $item.Output
    Copy-Item -LiteralPath $sourceFile -Destination $targetFile -Force
    Write-Host "Copied metadata index: $targetFile"
}

Write-Host "Release assets are ready under: $resolvedOutputRoot"
