@echo off
setlocal

set "PS_SCRIPT=%TEMP%\update-kingdee-skill-standalone.ps1"

> "%PS_SCRIPT%" echo $ErrorActionPreference = 'Stop'
>> "%PS_SCRIPT%" echo $repoOwner = 'Jin080'
>> "%PS_SCRIPT%" echo $repoName = 'kingdee-cangqiong-dev-tips'
>> "%PS_SCRIPT%" echo $branch = 'main'
>> "%PS_SCRIPT%" echo $zipUrl = "https://github.com/$repoOwner/$repoName/archive/refs/heads/$branch.zip"
>> "%PS_SCRIPT%" echo $tempRoot = Join-Path $env:TEMP ("codex-skill-update-" + [System.Guid]::NewGuid().ToString^("N"^)^)
>> "%PS_SCRIPT%" echo $zipPath = Join-Path $tempRoot 'repo.zip'
>> "%PS_SCRIPT%" echo $extractRoot = Join-Path $tempRoot 'repo'
>> "%PS_SCRIPT%" echo New-Item -ItemType Directory -Force -Path $tempRoot ^| Out-Null
>> "%PS_SCRIPT%" echo Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
>> "%PS_SCRIPT%" echo Expand-Archive -LiteralPath $zipPath -DestinationPath $extractRoot -Force
>> "%PS_SCRIPT%" echo $sourceSkill = Join-Path $extractRoot "$repoName-$branch\skill\kingdee-cangqiong-dev-tips"
>> "%PS_SCRIPT%" echo $skillRoot = if ^($env:CODEX_HOME^) { Join-Path $env:CODEX_HOME 'skills' } else { Join-Path $env:USERPROFILE '.codex\skills' }
>> "%PS_SCRIPT%" echo $targetSkill = Join-Path $skillRoot 'kingdee-cangqiong-dev-tips'
>> "%PS_SCRIPT%" echo New-Item -ItemType Directory -Force -Path $skillRoot ^| Out-Null
>> "%PS_SCRIPT%" echo if ^(Test-Path -LiteralPath $targetSkill^) { Remove-Item -Recurse -Force -LiteralPath $targetSkill }
>> "%PS_SCRIPT%" echo Copy-Item -Recurse -Force -LiteralPath $sourceSkill -Destination $targetSkill
>> "%PS_SCRIPT%" echo Remove-Item -Recurse -Force -LiteralPath $tempRoot
>> "%PS_SCRIPT%" echo Write-Host ^("Installed skill to " + $targetSkill^)

echo Running skill update...
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
if errorlevel 1 goto :fail

del /f /q "%PS_SCRIPT%" >nul 2>nul
echo.
echo Skill update completed.
pause
exit /b 0

:fail
echo.
echo Skill update failed.
pause
exit /b 1
