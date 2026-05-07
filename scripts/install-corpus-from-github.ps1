param(
    [string]$SourceRoot,
    [string]$CorpusRoot,
    [string]$SkillRoot,
    [string]$RepoOwner = "Jin080",
    [string]$RepoName = "kingdee-cangqiong-dev-tips",
    [string]$Branch = "main",
    [string]$ManifestPath = "corpus/release-manifest.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-DefaultCorpusRoot {
    $preferredDrive = "D:\"
    if (Test-Path -LiteralPath $preferredDrive -PathType Container) {
        return [System.IO.Path]::GetFullPath((Join-Path $preferredDrive "KingdeeDocs"))
    }

    return [System.IO.Path]::GetFullPath((Join-Path $env:USERPROFILE "KingdeeDocs"))
}

function Get-ResolvedCorpusRoot {
    param([string]$OverrideRoot)

    if ($OverrideRoot) {
        return [System.IO.Path]::GetFullPath($OverrideRoot)
    }

    return Get-DefaultCorpusRoot
}

function Get-RequiredCorpusNames {
    return @(
        "苍穹帮助中心全量库",
        "星瀚帮助中心全量库",
        "星空帮助中心全量库"
    )
}

function Get-RequiredMetadataIndexNames {
    return @(
        "星瀚元数据-index.jsonl",
        "星空元数据-index.jsonl"
    )
}

function Test-CorpusLayout {
    param([string]$RootPath)

    foreach ($name in (Get-RequiredCorpusNames)) {
        if (-not (Test-Path -LiteralPath (Join-Path $RootPath $name) -PathType Container)) {
            return $false
        }
    }

    foreach ($name in (Get-RequiredMetadataIndexNames)) {
        if (-not (Test-Path -LiteralPath (Join-Path $RootPath $name) -PathType Leaf)) {
            return $false
        }
    }

    return $true
}

function Get-ManifestUrl {
    param(
        [string]$Owner,
        [string]$Name,
        [string]$TargetBranch,
        [string]$RelativePath
    )

    $cacheBust = [System.Guid]::NewGuid().ToString("N")
    return "https://raw.githubusercontent.com/$Owner/$Name/$TargetBranch/$($RelativePath)?cacheBust=$cacheBust"
}

function Get-ReleaseTagApiUrl {
    param(
        [string]$Owner,
        [string]$Name,
        [string]$ReleaseTag
    )

    return "https://api.github.com/repos/$Owner/$Name/releases/tags/$ReleaseTag"
}

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
                Invoke-WebRequest -Headers @{ "User-Agent" = "kingdee-corpus-installer" } -Uri $Url -OutFile $OutFile -TimeoutSec 1800
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

function Stage-ReleaseAssets {
    param(
        [pscustomobject]$Manifest,
        [string]$Owner,
        [string]$Name,
        [string]$InstallRoot,
        [string]$TempDownloadRoot
    )

    $headers = @{
        "Accept" = "application/vnd.github+json"
        "User-Agent" = "kingdee-corpus-installer"
    }

    $release = Invoke-RestMethod -Headers $headers -Uri (Get-ReleaseTagApiUrl -Owner $Owner -Name $Name -ReleaseTag $Manifest.release_tag)

    foreach ($assetSpec in $Manifest.assets) {
        $asset = $release.assets | Where-Object { $_.name -eq $assetSpec.name } | Select-Object -First 1
        if (-not $asset) {
            throw "Release [$($Manifest.release_tag)] is missing asset: $($assetSpec.name)"
        }

        $downloadPath = Join-Path $TempDownloadRoot $assetSpec.name
        Invoke-DownloadFile -Url $asset.browser_download_url -OutFile $downloadPath -Label $assetSpec.name

        if ($assetSpec.kind -eq "zip") {
            $installedTarget = Join-Path $InstallRoot $assetSpec.expanded_name
            if (Test-Path -LiteralPath $installedTarget) {
                Remove-Item -LiteralPath $installedTarget -Recurse -Force
            }

            New-Item -ItemType Directory -Force -Path $InstallRoot | Out-Null
            Expand-Archive -LiteralPath $downloadPath -DestinationPath $InstallRoot -Force

            continue
        }

        if ($assetSpec.kind -eq "file") {
            $targetName = $assetSpec.target_name
            Copy-Item -LiteralPath $downloadPath -Destination (Join-Path $InstallRoot $targetName) -Force
            continue
        }

        throw "Unsupported asset kind in manifest: $($assetSpec.kind)"
    }
}

$resolvedCorpusRoot = Get-ResolvedCorpusRoot -OverrideRoot $CorpusRoot
$tempScript = Join-Path $env:TEMP ("install-corpus-" + [System.Guid]::NewGuid().ToString("N") + ".ps1")
$tempRoot = Join-Path $env:TEMP ("install-corpus-assets-" + [System.Guid]::NewGuid().ToString("N"))
$scriptUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/scripts/install-corpus.ps1?cacheBust=$([System.Guid]::NewGuid().ToString('N'))"
$resolvedSourceRoot = $null

try {
    Invoke-WebRequest -Uri $scriptUrl -OutFile $tempScript
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

    if ($SourceRoot) {
        $resolvedSourceRoot = [System.IO.Path]::GetFullPath($SourceRoot)
    } elseif (-not (Test-CorpusLayout -RootPath $resolvedCorpusRoot)) {
        $manifestUrl = Get-ManifestUrl -Owner $RepoOwner -Name $RepoName -TargetBranch $Branch -RelativePath $ManifestPath
        $manifest = Invoke-RestMethod -Uri $manifestUrl

        $tempDownloadRoot = Join-Path $tempRoot "downloads"
        New-Item -ItemType Directory -Force -Path $tempDownloadRoot | Out-Null

        Stage-ReleaseAssets -Manifest $manifest -Owner $RepoOwner -Name $RepoName -InstallRoot $resolvedCorpusRoot -TempDownloadRoot $tempDownloadRoot
    } else {
        Write-Host "Corpus already exists at $resolvedCorpusRoot, skip release download."
    }

    $arguments = @(
        "-ExecutionPolicy", "Bypass",
        "-File", $tempScript,
        "-CorpusRoot", $resolvedCorpusRoot
    )

    if ($resolvedSourceRoot) {
        $arguments += @("-SourceRoot", $resolvedSourceRoot)
    }

    if ($SkillRoot) {
        $arguments += @("-SkillRoot", $SkillRoot)
    }

    & powershell @arguments

    if ($LASTEXITCODE -ne 0) {
        throw "Corpus install script failed"
    }
}
finally {
    if (Test-Path -LiteralPath $tempScript) {
        Remove-Item -Force -LiteralPath $tempScript
    }
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -Recurse -Force -LiteralPath $tempRoot
    }
}
