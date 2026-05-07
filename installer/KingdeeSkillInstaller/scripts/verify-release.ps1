param(
    [string]$WorkRoot,
    [switch]$KeepWorkRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Section {
    param([string]$Title)

    Write-Host ""
    Write-Host ("=== {0} ===" -f $Title) -ForegroundColor Cyan
}

function Write-Pass {
    param([string]$Message)

    Write-Host ("[PASS] {0}" -f $Message) -ForegroundColor Green
}

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Assert-Exists {
    param(
        [string]$Path,
        [string]$Message,
        [ValidateSet("Any", "Leaf", "Container")]
        [string]$PathType = "Any"
    )

    $exists = switch ($PathType) {
        "Leaf" { Test-Path -LiteralPath $Path -PathType Leaf }
        "Container" { Test-Path -LiteralPath $Path -PathType Container }
        default { Test-Path -LiteralPath $Path }
    }

    if (-not $exists) {
        throw $Message
    }
}

function Assert-ContentContains {
    param(
        [string]$Content,
        [string]$Expected,
        [string]$Message
    )

    if ($Content -notlike ("*{0}*" -f $Expected)) {
        throw $Message
    }
}

function Assert-RegexMatch {
    param(
        [string]$Content,
        [string]$Pattern,
        [string]$Message
    )

    if (-not [regex]::IsMatch($Content, $Pattern)) {
        throw $Message
    }
}

function Assert-SetEquals {
    param(
        [string[]]$Actual,
        [string[]]$Expected,
        [string]$Label
    )

    $actualSorted = @($Actual | Sort-Object)
    $expectedSorted = @($Expected | Sort-Object)
    $diff = Compare-Object -ReferenceObject $expectedSorted -DifferenceObject $actualSorted
    if ($diff) {
        throw ("{0} mismatch. Expected [{1}], actual [{2}]" -f $Label, ($expectedSorted -join ", "), ($actualSorted -join ", "))
    }
}

function Invoke-PowerShellScript {
    param(
        [string]$ScriptPath,
        [string[]]$Arguments,
        [switch]$ExpectFailure
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $ScriptPath @Arguments 2>&1
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    $exitCode = $LASTEXITCODE
    $text = (($output | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine).Trim()

    if ($ExpectFailure) {
        if ($exitCode -eq 0) {
            throw ("Expected failure but script succeeded: {0} {1}" -f $ScriptPath, ($Arguments -join " "))
        }

        return [pscustomobject]@{
            ExitCode = $exitCode
            Output = $text
        }
    }

    if ($exitCode -ne 0) {
        throw ("Script failed: {0}`nArguments: {1}`nOutput:`n{2}" -f $ScriptPath, ($Arguments -join " "), $text)
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output = $text
    }
}

function New-FakeCorpusSource {
    param([string]$RootPath)

    New-Item -ItemType Directory -Force -Path $RootPath | Out-Null

    foreach ($name in @(
        "苍穹帮助中心全量库",
        "星瀚帮助中心全量库",
        "星空帮助中心全量库"
    )) {
        $dir = Join-Path $RootPath $name
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Set-Content -LiteralPath (Join-Path $dir "README.txt") -Value ("seed::{0}" -f $name) -Encoding UTF8
    }

    Set-Content -LiteralPath (Join-Path $RootPath "星瀚元数据-index.jsonl") -Value '{"kind":"xinghan"}' -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $RootPath "星空元数据-index.jsonl") -Value '{"kind":"xingkong"}' -Encoding UTF8
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir

$installSkillScript = Join-Path $scriptDir "install-skill.ps1"
$installCorpusScript = Join-Path $scriptDir "install-corpus.ps1"
$updateSkillScript = Join-Path $scriptDir "update-skill.ps1"
$installSkillFromGitHubScript = Join-Path $scriptDir "install-skill-from-github.ps1"
$installWorkstationFromGitHubScript = Join-Path $scriptDir "install-workstation-from-github.ps1"
$updateSkillFromGitHubScript = Join-Path $scriptDir "update-skill-from-github.ps1"
$installCorpusFromGitHubScript = Join-Path $scriptDir "install-corpus-from-github.ps1"

foreach ($requiredScript in @(
    $installSkillScript,
    $installCorpusScript,
    $updateSkillScript,
    $installSkillFromGitHubScript,
    $installWorkstationFromGitHubScript,
    $updateSkillFromGitHubScript,
    $installCorpusFromGitHubScript
)) {
    Assert-Exists -Path $requiredScript -PathType Leaf -Message ("Required script not found: {0}" -f $requiredScript)
}

if (-not $WorkRoot) {
    $WorkRoot = Join-Path $env:TEMP ("kingdee-release-verify-" + [System.Guid]::NewGuid().ToString("N"))
}

$WorkRoot = [System.IO.Path]::GetFullPath($WorkRoot)
$verificationSucceeded = $false

try {
    New-Item -ItemType Directory -Force -Path $WorkRoot | Out-Null

    Write-Section "verify wrapper forwarding for selective install/update"
    $installWorkstationContent = Get-Content -LiteralPath $installWorkstationFromGitHubScript -Raw
    $updateSkillFromGitHubContent = Get-Content -LiteralPath $updateSkillFromGitHubScript -Raw
    $updateSkillContent = Get-Content -LiteralPath $updateSkillScript -Raw

    Assert-RegexMatch -Content $installWorkstationContent -Pattern '\$skillArguments\s*\+=\s*@\("-SkillNames",\s*\(\$SkillNames\s*-join\s*","\)\)' -Message "install-workstation-from-github.ps1 no longer forwards multiple -SkillNames safely"
    Assert-RegexMatch -Content $updateSkillFromGitHubContent -Pattern '\$arguments\s*\+=\s*@\("-SkillNames",\s*\(\$SkillNames\s*-join\s*","\)\)' -Message "update-skill-from-github.ps1 no longer forwards multiple -SkillNames safely"
    Assert-RegexMatch -Content $updateSkillContent -Pattern '\$arguments\s*\+=\s*@\("-SkillNames",\s*\(\$SkillNames\s*-join\s*","\)\)' -Message "update-skill.ps1 no longer forwards multiple -SkillNames safely"
    Write-Pass "Wrapper scripts keep multi-skill forwarding intact"

    Write-Section "verify selective skill install"
    $selectiveSkillRoot = Join-Path $WorkRoot "selective-install\skills"
    Invoke-PowerShellScript -ScriptPath $installSkillScript -Arguments @(
        "-SkillRoot", $selectiveSkillRoot,
        "-SkillNames", "kingdee-cangqiong-dev-tips,ai-coding-discipline"
    ) | Out-Null

    $installedSelectiveSkills = Get-ChildItem -LiteralPath $selectiveSkillRoot -Directory | Select-Object -ExpandProperty Name
    Assert-SetEquals -Actual $installedSelectiveSkills -Expected @(
        "kingdee-cangqiong-dev-tips",
        "ai-coding-discipline"
    ) -Label "Selective install result"
    Write-Pass "Selective install only synced requested skills"

    Write-Section "verify heavy corpus install and config writeback"
    $heavySkillRoot = Join-Path $WorkRoot "heavy-install\skills"
    $corpusSourceRoot = Join-Path $WorkRoot "heavy-install\source"
    $corpusTargetRoot = Join-Path $WorkRoot "heavy-install\corpus"

    Invoke-PowerShellScript -ScriptPath $installSkillScript -Arguments @(
        "-SkillRoot", $heavySkillRoot,
        "-SkillNames", "kingdee-cangqiong-heavy,kingdee-xinghan-heavy,kingdee-xingkong-heavy"
    ) | Out-Null

    New-FakeCorpusSource -RootPath $corpusSourceRoot

    Invoke-PowerShellScript -ScriptPath $installCorpusScript -Arguments @(
        "-SourceRoot", $corpusSourceRoot,
        "-CorpusRoot", $corpusTargetRoot,
        "-SkillRoot", $heavySkillRoot
    ) | Out-Null

    foreach ($name in @(
        "苍穹帮助中心全量库",
        "星瀚帮助中心全量库",
        "星空帮助中心全量库"
    )) {
        $dir = Join-Path $corpusTargetRoot $name
        Assert-Exists -Path $dir -PathType Container -Message ("Installed corpus directory missing: {0}" -f $dir)
        Assert-Exists -Path (Join-Path $dir "README.txt") -PathType Leaf -Message ("Installed corpus seed file missing: {0}" -f $dir)
    }

    foreach ($name in @("星瀚元数据-index.jsonl", "星空元数据-index.jsonl")) {
        $file = Join-Path $corpusTargetRoot $name
        Assert-Exists -Path $file -PathType Leaf -Message ("Installed metadata index missing: {0}" -f $file)
    }

    foreach ($skillName in @(
        "kingdee-cangqiong-heavy",
        "kingdee-xinghan-heavy",
        "kingdee-xingkong-heavy"
    )) {
        $configPath = Join-Path $heavySkillRoot (Join-Path $skillName "references\config.md")
        Assert-Exists -Path $configPath -PathType Leaf -Message ("Config file missing after corpus install: {0}" -f $configPath)
        $content = Get-Content -LiteralPath $configPath -Raw
        Assert-True -Condition ([bool]([regex]::IsMatch($content, "(?m)^BASE_PATH:\s*{0}$" -f [regex]::Escape($corpusTargetRoot)))) -Message ("BASE_PATH was not rewritten to corpus root in {0}" -f $configPath)
    }
    Write-Pass "Heavy corpus files were staged and three heavy skill configs were rewritten"

    Write-Section "verify local config survives update-style reinstall"
    $preserveSkillRoot = Join-Path $WorkRoot "preserve-config\skills"
    $preserveMarker = "# VERIFY_LOCAL_OVERRIDE"
    $customBasePath = Join-Path $WorkRoot "custom-local-corpus"

    Invoke-PowerShellScript -ScriptPath $installSkillScript -Arguments @(
        "-SkillRoot", $preserveSkillRoot,
        "-SkillNames", "kingdee-xinghan-heavy"
    ) | Out-Null

    $preservedConfigPath = Join-Path $preserveSkillRoot "kingdee-xinghan-heavy\references\config.md"
    $preservedConfigContent = Get-Content -LiteralPath $preservedConfigPath -Raw
    $preservedConfigContent = [regex]::Replace($preservedConfigContent, '(?m)^BASE_PATH:\s*.*$', ("BASE_PATH: {0}" -f $customBasePath))
    if ($preservedConfigContent -notlike ("*{0}*" -f $preserveMarker)) {
        $preservedConfigContent = $preservedConfigContent.TrimEnd() + "`r`n`r`n" + $preserveMarker + "`r`n"
    }
    Set-Content -LiteralPath $preservedConfigPath -Value $preservedConfigContent -Encoding UTF8

    Invoke-PowerShellScript -ScriptPath $installSkillScript -Arguments @(
        "-SkillRoot", $preserveSkillRoot,
        "-SkillNames", "kingdee-xinghan-heavy"
    ) | Out-Null

    $reinstalledConfigContent = Get-Content -LiteralPath $preservedConfigPath -Raw
    Assert-ContentContains -Content $reinstalledConfigContent -Expected ("BASE_PATH: {0}" -f $customBasePath) -Message "Update-style reinstall did not preserve local BASE_PATH"
    Assert-ContentContains -Content $reinstalledConfigContent -Expected $preserveMarker -Message "Update-style reinstall did not preserve local config content"
    Write-Pass "Local config.md content is preserved across reinstall/update path"

    Write-Section "verify failure diagnostics stay actionable"
    $missingSkillFailure = Invoke-PowerShellScript -ScriptPath $installSkillScript -Arguments @(
        "-SkillRoot", (Join-Path $WorkRoot "failure-cases\skills"),
        "-SkillNames", "not-a-real-skill"
    ) -ExpectFailure
    Assert-ContentContains -Content $missingSkillFailure.Output -Expected "Requested skill(s) not found under" -Message "Missing-skill failure did not explain the root cause"
    Assert-ContentContains -Content $missingSkillFailure.Output -Expected "not-a-real-skill" -Message "Missing-skill failure did not include the requested skill name"

    $badCorpusSource = Join-Path $WorkRoot "failure-cases\bad-corpus-source"
    New-Item -ItemType Directory -Force -Path $badCorpusSource | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $badCorpusSource "苍穹帮助中心全量库") | Out-Null

    $badCorpusFailure = Invoke-PowerShellScript -ScriptPath $installCorpusScript -Arguments @(
        "-SourceRoot", $badCorpusSource,
        "-CorpusRoot", (Join-Path $WorkRoot "failure-cases\corpus-target"),
        "-SkillRoot", $heavySkillRoot
    ) -ExpectFailure
    Assert-True -Condition (
        ($badCorpusFailure.Output -like "*语料源目录 缺少必需目录:*") -or
        ($badCorpusFailure.Output -like "*语料源目录 缺少必需文件:*")
    ) -Message "Bad corpus layout failure did not report which required path is missing"
    Write-Pass "Expected failures expose clear diagnostics"

    $verificationSucceeded = $true
    Write-Host ""
    Write-Host ("Release verification passed. Workspace: {0}" -f $WorkRoot) -ForegroundColor Green
}
catch {
    Write-Error ("Release verification failed: {0}" -f $_.Exception.Message)
    if (Test-Path -LiteralPath $WorkRoot) {
        Write-Host ("Verification artifacts kept at: {0}" -f $WorkRoot) -ForegroundColor Yellow
    }
    throw
}
finally {
    if ($verificationSucceeded) {
        if ($KeepWorkRoot) {
            Write-Host ("Verification artifacts kept at: {0}" -f $WorkRoot) -ForegroundColor Yellow
        }
        elseif (Test-Path -LiteralPath $WorkRoot) {
            Remove-Item -Recurse -Force -LiteralPath $WorkRoot
        }
    }
}
