@echo off
title Start tracker in background
cd /d "%~dp0"

set "PYW="
if exist "C:\Python314\pythonw.exe" set "PYW=C:\Python314\pythonw.exe"
if not defined PYW if exist "C:\Python313\pythonw.exe" set "PYW=C:\Python313\pythonw.exe"
if not defined PYW if exist "C:\Python312\pythonw.exe" set "PYW=C:\Python312\pythonw.exe"
if not defined PYW if exist "C:\Python311\pythonw.exe" set "PYW=C:\Python311\pythonw.exe"
if not defined PYW if exist "%LOCALAPPDATA%\Programs\Python\Python314\pythonw.exe" set "PYW=%LOCALAPPDATA%\Programs\Python\Python314\pythonw.exe"
if not defined PYW if exist "%LOCALAPPDATA%\Programs\Python\Python313\pythonw.exe" set "PYW=%LOCALAPPDATA%\Programs\Python\Python313\pythonw.exe"
if not defined PYW if exist "%LOCALAPPDATA%\Programs\Python\Python312\pythonw.exe" set "PYW=%LOCALAPPDATA%\Programs\Python\Python312\pythonw.exe"

if not defined PYW (
  echo pythonw.exe not found.
  pause
  exit /b 1
)

REM Clear leftover stop signal
del STOP_TRACKER >nul 2>&1

REM Launch detached - no console window
start "" /b "%PYW%" mouse_tracker.py

echo Tracker started in background using:
echo   %PYW%
echo.
echo Check Task Manager - Details for pythonw.exe to confirm.
echo This window will close in 3 seconds. The tracker keeps running.
timeout /t 3 >nul
exit
