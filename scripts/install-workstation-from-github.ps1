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
    Invoke-WebRequest -Uri ("https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/scripts/install-skill-from-github.ps1?cacheBust=$([System.Guid]::NewGuid().ToString('N'))") -OutFile $tempInstallSkillScript
    $installSkillScript = $tempInstallSkillScript
}

if (-not (Test-Path -LiteralPath $installCorpusScript)) {
    $tempInstallCorpusScript = Join-Path $env:TEMP ("install-corpus-from-github-" + [System.Guid]::NewGuid().ToString("N") + ".ps1")
    Invoke-WebRequest -Uri ("https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/scripts/install-corpus-from-github.ps1?cacheBust=$([System.Guid]::NewGuid().ToString('N'))") -OutFile $tempInstallCorpusScript
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
        $skillArguments += @("-SkillNames", $SkillNames)
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
