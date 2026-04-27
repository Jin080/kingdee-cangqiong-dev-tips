param(
    [string]$SkillRoot,
    [string]$RepoOwner = "Jin080",
    [string]$RepoName = "kingdee-cangqiong-dev-tips",
    [string]$Branch = "main"
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

$zipUrl = "https://github.com/$RepoOwner/$RepoName/archive/refs/heads/$Branch.zip"
$tempRoot = Join-Path $env:TEMP ("codex-skill-install-" + [System.Guid]::NewGuid().ToString("N"))
$zipPath = Join-Path $tempRoot "repo.zip"
$extractRoot = Join-Path $tempRoot "repo"

New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

try {
    Write-Host "Downloading $zipUrl"
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractRoot -Force

    $repoSnapshotRoot = Join-Path $extractRoot "$RepoName-$Branch"
    $sourceSkill = Join-Path $repoSnapshotRoot "skill\kingdee-cangqiong-dev-tips"

    if (-not (Test-Path -LiteralPath $sourceSkill)) {
        throw "Source skill not found in downloaded archive: $sourceSkill"
    }

    $resolvedSkillRoot = Get-ResolvedSkillRoot -OverrideRoot $SkillRoot
    $targetSkill = [System.IO.Path]::GetFullPath((Join-Path $resolvedSkillRoot "kingdee-cangqiong-dev-tips"))

    if (-not $targetSkill.StartsWith($resolvedSkillRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to sync outside skill root: $targetSkill"
    }

    New-Item -ItemType Directory -Force -Path $resolvedSkillRoot | Out-Null

    if (Test-Path -LiteralPath $targetSkill) {
        Remove-Item -Recurse -Force -LiteralPath $targetSkill
    }

    Copy-Item -Recurse -Force -LiteralPath $sourceSkill -Destination $targetSkill
    Write-Host "Installed skill to $targetSkill"
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -Recurse -Force -LiteralPath $tempRoot
    }
}
