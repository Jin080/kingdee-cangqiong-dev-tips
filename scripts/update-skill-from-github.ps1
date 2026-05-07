param(
    [string]$SkillRoot,
    [string[]]$SkillNames,
    [string]$RepoOwner = "Jin080",
    [string]$RepoName = "kingdee-cangqiong-dev-tips",
    [string]$Branch = "main"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-DownloadFile {
    param(
        [string]$Url,
        [string]$OutFile,
        [string]$Label,
        [int]$MaxAttempts = 3
    )

    $attempt = 1
    while ($attempt -le $MaxAttempts) {
        try {
            Write-Host ("Downloading {0} (attempt {1}/{2})" -f $Label, $attempt, $MaxAttempts)

            if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
                & curl.exe -L --fail --retry 3 --retry-delay 2 --connect-timeout 30 --output $OutFile $Url
                if ($LASTEXITCODE -ne 0) {
                    throw "curl exited with code $LASTEXITCODE"
                }
            } else {
                Invoke-WebRequest -Headers @{ "User-Agent" = "kingdee-skill-updater" } -Uri $Url -OutFile $OutFile -TimeoutSec 600
            }

            if (-not (Test-Path -LiteralPath $OutFile -PathType Leaf)) {
                throw "Download did not produce file: $OutFile"
            }

            return
        }
        catch {
            if (Test-Path -LiteralPath $OutFile) {
                Remove-Item -LiteralPath $OutFile -Force
            }

            if ($attempt -ge $MaxAttempts) {
                throw ("Failed to download {0}: {1}" -f $Label, $_.Exception.Message)
            }

            Start-Sleep -Seconds (2 * $attempt)
            $attempt++
        }
    }
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$installScript = Join-Path $scriptDir "install-skill-from-github.ps1"
$tempInstallScript = $null

if (-not (Test-Path -LiteralPath $installScript)) {
    $tempInstallScript = Join-Path $env:TEMP ("install-skill-from-github-" + [System.Guid]::NewGuid().ToString("N") + ".ps1")
    $cacheBust = [System.Guid]::NewGuid().ToString("N")
    $installScriptUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/scripts/install-skill-from-github.ps1?cacheBust=$cacheBust"
    Invoke-DownloadFile -Url $installScriptUrl -OutFile $tempInstallScript -Label "install-skill-from-github.ps1"
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
    $arguments += @("-SkillNames", ($SkillNames -join ","))
}

& powershell @arguments

if ($LASTEXITCODE -ne 0) {
    throw "Update script failed"
}

if ($tempInstallScript -and (Test-Path -LiteralPath $tempInstallScript)) {
    Remove-Item -Force -LiteralPath $tempInstallScript
}
