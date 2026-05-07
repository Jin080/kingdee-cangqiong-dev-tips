param(
    [string]$SkillRoot,
    [string[]]$SkillNames
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

function Normalize-SkillNames {
    param([string[]]$Names)

    $normalized = @()
    foreach ($name in ($Names | Where-Object { $_ })) {
        foreach ($part in ($name -split ",")) {
            $trimmed = $part.Trim()
            if (-not [string]::IsNullOrWhiteSpace($trimmed)) {
                $normalized += $trimmed
            }
        }
    }

    return $normalized | Select-Object -Unique
}

function Get-SourceSkillDirectories {
    param(
        [string]$SourceRoot,
        [string[]]$SelectedSkillNames
    )

    if (-not (Test-Path -LiteralPath $SourceRoot)) {
        throw "Source skill root not found: $SourceRoot"
    }

    $directories = Get-ChildItem -LiteralPath $SourceRoot -Directory | Where-Object {
        Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md")
    }

    if (-not $directories) {
        throw "No installable skills found under: $SourceRoot"
    }

    $normalizedSkillNames = Normalize-SkillNames -Names $SelectedSkillNames
    if (-not $normalizedSkillNames) {
        return $directories
    }

    $availableNames = $directories.Name
    $missingSkillNames = $normalizedSkillNames | Where-Object { $_ -notin $availableNames }
    if ($missingSkillNames) {
        throw ("Requested skill(s) not found under {0}: {1}" -f $SourceRoot, ($missingSkillNames -join ", "))
    }

    return $directories | Where-Object { $_.Name -in $normalizedSkillNames }
}

function Sync-SkillDirectories {
    param(
        [string]$SourceRoot,
        [string]$ResolvedSkillRoot,
        [string[]]$SelectedSkillNames
    )

    New-Item -ItemType Directory -Force -Path $ResolvedSkillRoot | Out-Null

    $installedSkills = @()

    foreach ($skillDirectory in (Get-SourceSkillDirectories -SourceRoot $SourceRoot -SelectedSkillNames $SelectedSkillNames)) {
        $targetSkill = [System.IO.Path]::GetFullPath((Join-Path $ResolvedSkillRoot $skillDirectory.Name))
        $preservedConfigPath = $null

        if (-not $targetSkill.StartsWith($ResolvedSkillRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to sync outside skill root: $targetSkill"
        }

        $targetConfig = Join-Path $targetSkill "references\config.md"
        if (Test-Path -LiteralPath $targetConfig) {
            $preservedConfigPath = Join-Path $env:TEMP ("codex-skill-config-" + [System.Guid]::NewGuid().ToString("N") + ".md")
            Copy-Item -LiteralPath $targetConfig -Destination $preservedConfigPath -Force
        }

        if (Test-Path -LiteralPath $targetSkill) {
            Remove-Item -Recurse -Force -LiteralPath $targetSkill
        }

        Copy-Item -Recurse -Force -LiteralPath $skillDirectory.FullName -Destination $targetSkill

        if ($preservedConfigPath) {
            $restoredConfig = Join-Path $targetSkill "references\config.md"
            if (Test-Path -LiteralPath $restoredConfig) {
                Copy-Item -LiteralPath $preservedConfigPath -Destination $restoredConfig -Force
                Write-Host "Preserved local config at $restoredConfig"
            }
            Remove-Item -Force -LiteralPath $preservedConfigPath
        }

        $installedSkills += $skillDirectory.Name
        Write-Host "Installed skill to $targetSkill"
    }

    Write-Host ("Installed {0} skill(s): {1}" -f $installedSkills.Count, ($installedSkills -join ", "))
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$sourceSkillRoot = Join-Path $repoRoot "skill"

$resolvedSkillRoot = Get-ResolvedSkillRoot -OverrideRoot $SkillRoot
Sync-SkillDirectories -SourceRoot $sourceSkillRoot -ResolvedSkillRoot $resolvedSkillRoot -SelectedSkillNames $SkillNames
