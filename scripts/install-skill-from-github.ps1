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

function Get-SourceSkillDirectories {
    param([string]$SourceRoot)

    if (-not (Test-Path -LiteralPath $SourceRoot)) {
        throw "Source skill root not found: $SourceRoot"
    }

    $directories = Get-ChildItem -LiteralPath $SourceRoot -Directory | Where-Object {
        Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md")
    }

    if (-not $directories) {
        throw "No installable skills found under: $SourceRoot"
    }

    return $directories
}

function Sync-SkillDirectories {
    param(
        [string]$SourceRoot,
        [string]$ResolvedSkillRoot
    )

    New-Item -ItemType Directory -Force -Path $ResolvedSkillRoot | Out-Null

    $installedSkills = @()

    foreach ($skillDirectory in (Get-SourceSkillDirectories -SourceRoot $SourceRoot)) {
        $targetSkill = [System.IO.Path]::GetFullPath((Join-Path $ResolvedSkillRoot $skillDirectory.Name))

        if (-not $targetSkill.StartsWith($ResolvedSkillRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to sync outside skill root: $targetSkill"
        }

        if (Test-Path -LiteralPath $targetSkill) {
            Remove-Item -Recurse -Force -LiteralPath $targetSkill
        }

        Copy-Item -Recurse -Force -LiteralPath $skillDirectory.FullName -Destination $targetSkill
        $installedSkills += $skillDirectory.Name
        Write-Host "Installed skill to $targetSkill"
    }

    Write-Host ("Installed {0} skill(s): {1}" -f $installedSkills.Count, ($installedSkills -join ", "))
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
    $sourceSkillRoot = Join-Path $repoSnapshotRoot "skill"

    $resolvedSkillRoot = Get-ResolvedSkillRoot -OverrideRoot $SkillRoot
    Sync-SkillDirectories -SourceRoot $sourceSkillRoot -ResolvedSkillRoot $resolvedSkillRoot
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -Recurse -Force -LiteralPath $tempRoot
    }
}
