param(
    [string]$SkillRoot,
    [string[]]$SkillNames,
    [string]$RepoOwner = "Jin080",
    [string]$RepoName = "kingdee-cangqiong-dev-tips",
    [string]$Branch = "main"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$installScript = Join-Path $scriptDir "install-skill-from-github.ps1"
$tempInstallScript = $null

if (-not (Test-Path -LiteralPath $installScript)) {
    $tempInstallScript = Join-Path $env:TEMP ("install-skill-from-github-" + [System.Guid]::NewGuid().ToString("N") + ".ps1")
    $cacheBust = [System.Guid]::NewGuid().ToString("N")
    $installScriptUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/scripts/install-skill-from-github.ps1?cacheBust=$cacheBust"
    Invoke-WebRequest -Uri $installScriptUrl -OutFile $tempInstallScript
    $installScript = $tempInstallScript
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

if ($SkillNames) {
    $arguments += @("-SkillNames", $SkillNames)
}

& powershell @arguments

if ($LASTEXITCODE -ne 0) {
    throw "Update script failed"
}

if ($tempInstallScript -and (Test-Path -LiteralPath $tempInstallScript)) {
    Remove-Item -Force -LiteralPath $tempInstallScript
}
