param(
    [string]$SkillRoot,
    [string[]]$SkillNames,
    [string]$CorpusRoot,
    [string]$RepoOwner = "Jin080",
    [string]$RepoName = "kingdee-cangqiong-dev-tips",
    [string]$Branch = "main",
    [string]$ManifestPath = "corpus/release-manifest.json"
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
                Invoke-WebRequest -Headers @{ "User-Agent" = "kingdee-skill-installer" } -Uri $Url -OutFile $OutFile -TimeoutSec 600
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

function Should-InstallHeavyCorpus {
    param([string[]]$SelectedSkillNames)

    $normalizedSkillNames = Normalize-SkillNames -Names $SelectedSkillNames
    if (-not $normalizedSkillNames) {
        return $true
    }

    $heavySkillNames = @(
        "kingdee-cangqiong-heavy",
        "kingdee-xinghan-heavy",
        "kingdee-xingkong-heavy"
    )

    return [bool]($normalizedSkillNames | Where-Object { $_ -in $heavySkillNames })
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$installSkillScript = Join-Path $scriptDir "install-skill-from-github.ps1"
$installCorpusScript = Join-Path $scriptDir "install-corpus-from-github.ps1"
$tempInstallSkillScript = $null
$tempInstallCorpusScript = $null

if (-not (Test-Path -LiteralPath $installSkillScript)) {
    $tempInstallSkillScript = Join-Path $env:TEMP ("install-skill-from-github-" + [System.Guid]::NewGuid().ToString("N") + ".ps1")
    Invoke-DownloadFile -Url ("https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/scripts/install-skill-from-github.ps1?cacheBust=$([System.Guid]::NewGuid().ToString('N'))") -OutFile $tempInstallSkillScript -Label "install-skill-from-github.ps1"
    $installSkillScript = $tempInstallSkillScript
}

if (-not (Test-Path -LiteralPath $installCorpusScript)) {
    $tempInstallCorpusScript = Join-Path $env:TEMP ("install-corpus-from-github-" + [System.Guid]::NewGuid().ToString("N") + ".ps1")
    Invoke-DownloadFile -Url ("https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/scripts/install-corpus-from-github.ps1?cacheBust=$([System.Guid]::NewGuid().ToString('N'))") -OutFile $tempInstallCorpusScript -Label "install-corpus-from-github.ps1"
    $installCorpusScript = $tempInstallCorpusScript
}

try {
    $skillArguments = @(
        "-ExecutionPolicy", "Bypass",
        "-File", $installSkillScript,
        "-RepoOwner", $RepoOwner,
        "-RepoName", $RepoName,
        "-Branch", $Branch
    )

    if ($SkillRoot) {
        $skillArguments += @("-SkillRoot", $SkillRoot)
    }

    if ($SkillNames) {
        $skillArguments += @("-SkillNames", ($SkillNames -join ","))
    }

    & powershell @skillArguments

    if ($LASTEXITCODE -ne 0) {
        throw "Skill install step failed"
    }

    if (Should-InstallHeavyCorpus -SelectedSkillNames $SkillNames) {
        $corpusArguments = @(
            "-ExecutionPolicy", "Bypass",
            "-File", $installCorpusScript,
            "-RepoOwner", $RepoOwner,
            "-RepoName", $RepoName,
            "-Branch", $Branch,
            "-ManifestPath", $ManifestPath
        )

        if ($SkillRoot) {
            $corpusArguments += @("-SkillRoot", $SkillRoot)
        }

        if ($CorpusRoot) {
            $corpusArguments += @("-CorpusRoot", $CorpusRoot)
        }

        & powershell @corpusArguments

        if ($LASTEXITCODE -ne 0) {
            throw "Corpus install step failed"
        }
    } else {
        Write-Host "Selected skills do not require heavy corpus download. Skip corpus install."
    }
}
finally {
    if ($tempInstallSkillScript -and (Test-Path -LiteralPath $tempInstallSkillScript)) {
        Remove-Item -Force -LiteralPath $tempInstallSkillScript
    }

    if ($tempInstallCorpusScript -and (Test-Path -LiteralPath $tempInstallCorpusScript)) {
        Remove-Item -Force -LiteralPath $tempInstallCorpusScript
    }
}
