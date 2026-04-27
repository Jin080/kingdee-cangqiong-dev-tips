param(
    [string]$SkillRoot,
    [string]$RepoOwner = "Jin080",
    [string]$RepoName = "kingdee-cangqiong-dev-tips",
    [string]$Branch = "main"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$installScript = Join-Path $scriptDir "install-skill-from-github.ps1"

if (-not (Test-Path -LiteralPath $installScript)) {
    $installScriptUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/scripts/install-skill-from-github.ps1"
    Invoke-WebRequest -Uri $installScriptUrl -OutFile $installScript
}

if (-not (Test-Path -LiteralPath $installScript)) {
    throw "Install script not found: $installScript"
}

$arguments = @(
    "-ExecutionPolicy", "Bypass",
    "-File", $installScript,
    "-RepoOwner", $RepoOwner,
    "-RepoName", $RepoName,
    "-Branch", $Branch
)

if ($SkillRoot) {
    $arguments += @("-SkillRoot", $SkillRoot)
}

& powershell @arguments

if ($LASTEXITCODE -ne 0) {
    throw "Update script failed"
}
