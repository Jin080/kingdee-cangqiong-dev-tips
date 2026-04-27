@echo off
setlocal

set "SCRIPT_URL=https://raw.githubusercontent.com/Jin080/kingdee-cangqiong-dev-tips/main/scripts/update-skill-from-github.ps1"
set "SCRIPT_PATH=%TEMP%\update-kingdee-skill.ps1"

echo Downloading latest update script...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Invoke-WebRequest -Uri '%SCRIPT_URL%' -OutFile '%SCRIPT_PATH%' -UseBasicParsing } catch { Write-Error $_; exit 1 }"
if errorlevel 1 goto :fail

echo Running skill update...
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%"
if errorlevel 1 goto :fail

echo.
echo Skill update completed.
pause
exit /b 0

:fail
echo.
echo Skill update failed.
pause
exit /b 1
