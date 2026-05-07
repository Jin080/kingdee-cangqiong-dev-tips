@echo off
setlocal

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference = 'Stop'; $script = Join-Path $env:TEMP 'update-kingdee-skills.ps1'; $url = 'https://raw.githubusercontent.com/Jin080/kingdee-cangqiong-dev-tips/main/scripts/update-skill-from-github.ps1?cacheBust=' + [guid]::NewGuid().ToString('N'); try { for ($i = 1; $i -le 3; $i++) { try { if (Get-Command curl.exe -ErrorAction SilentlyContinue) { & curl.exe -L --fail --retry 3 --retry-delay 2 --connect-timeout 30 --output $script $url; if ($LASTEXITCODE -ne 0) { throw ('curl exited with code ' + $LASTEXITCODE) } } else { Invoke-WebRequest -Headers @{ 'User-Agent' = 'kingdee-bat-bootstrap' } -Uri $url -OutFile $script -TimeoutSec 600 }; if (-not (Test-Path -LiteralPath $script -PathType Leaf)) { throw ('Download did not produce file: ' + $script) }; break } catch { if (Test-Path -LiteralPath $script) { Remove-Item -LiteralPath $script -Force }; if ($i -ge 3) { throw }; Start-Sleep -Seconds (2 * $i) } }; & powershell -NoProfile -ExecutionPolicy Bypass -File $script; exit $LASTEXITCODE } finally { if (Test-Path -LiteralPath $script) { Remove-Item -LiteralPath $script -Force } }"

if errorlevel 1 (
  echo Update failed.
  pause
  exit /b 1
)

echo Update completed.
pause
