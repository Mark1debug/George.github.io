@echo off
title Create desktop shortcut
cd /d "%~dp0"
chcp 65001 >nul 2>&1

set "HTML=%~dp0study-state-tracker.html"
set "DESKTOP=%USERPROFILE%\Desktop"
set "SHORTCUT=%DESKTOP%\学习状态记录.lnk"

echo Creating desktop shortcut...
echo Target HTML : %HTML%
echo Shortcut    : %SHORTCUT%
echo.

REM Use PowerShell to locate msedge.exe and build a clean app-mode shortcut.
REM If Edge is missing, fall back to opening the .html with the default browser.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='SilentlyContinue'; $edge = (Get-Command msedge.exe).Source; if (-not $edge) { foreach ($p in @('C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe','C:\Program Files\Microsoft\Edge\Application\msedge.exe')) { if (Test-Path $p) { $edge=$p; break } } } ; $html='%HTML%'; $url = 'file:///' + ($html -replace '\\','/') -replace ' ','%%20'; $WS = New-Object -ComObject WScript.Shell; $S = $WS.CreateShortcut('%SHORTCUT%'); if ($edge) { $S.TargetPath = $edge; $S.Arguments = '--app=' + [char]34 + $url + [char]34; Write-Host 'Mode: Edge app window' } else { $S.TargetPath = $html; Write-Host 'Mode: default browser (Edge not found)' } ; $S.WorkingDirectory = '%~dp0'; $S.IconLocation = '%SystemRoot%\System32\imageres.dll,109'; $S.Save()"

echo.
if exist "%SHORTCUT%" (
  echo Done. Look for "学习状态记录" on your desktop.
) else (
  echo ERROR: could not create shortcut. Try right-clicking study-state-tracker.html
  echo and choosing "Send to ^> Desktop ^(create shortcut^)" manually.
)
echo.
pause
