param(
    [string]$SkillRoot,
    [string[]]$SkillNames
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$installScript = Join-Path $scriptDir "install-skill.ps1"

function Invoke-Git {
    param([string[]]$Arguments)

    & git -C $repoRoot @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Git command failed: git -C `"$repoRoot`" $($Arguments -join ' ')"
    }
}

if (-not (Test-Path $installScript)) {
    throw "Install script not found: $installScript"
}

Invoke-Git -Arguments @("fetch", "origin", "main")
Invoke-Git -Arguments @("checkout", "main")
Invoke-Git -Arguments @("pull", "--ff-only", "origin", "main")

if ($SkillRoot) {
    $arguments = @("-ExecutionPolicy", "Bypass", "-File", $installScript, "-SkillRoot", $SkillRoot)
} else {
    $arguments = @("-ExecutionPolicy", "Bypass", "-File", $installScript)
}

if ($SkillNames) {
    $arguments += @("-SkillNames", $SkillNames)
}

& powershell @arguments

if ($LASTEXITCODE -ne 0) {
    throw "Install script failed"
}
