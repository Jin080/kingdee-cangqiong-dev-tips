@echo off
setlocal

powershell -ExecutionPolicy Bypass -Command "$script = Join-Path $env:TEMP 'update-kingdee-skills.ps1'; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Jin080/kingdee-cangqiong-dev-tips/main/scripts/update-skill-from-github.ps1' -OutFile $script; & powershell -ExecutionPolicy Bypass -File $script"

if errorlevel 1 (
  echo Update failed.
  pause
  exit /b 1
)

echo Update completed.
pause
