@echo off
setlocal

powershell -ExecutionPolicy Bypass -Command "$cacheBust = [guid]::NewGuid().ToString('N'); $script = Join-Path $env:TEMP 'install-kingdee-workstation.ps1'; Invoke-WebRequest -Uri ('https://raw.githubusercontent.com/Jin080/kingdee-cangqiong-dev-tips/main/scripts/install-workstation-from-github.ps1?cacheBust=' + $cacheBust) -OutFile $script; & powershell -ExecutionPolicy Bypass -File $script"

if errorlevel 1 (
  echo Install failed.
  pause
  exit /b 1
)

echo Install completed.
pause
