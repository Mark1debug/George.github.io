@echo off
title Mouse Tracker - Study State
cd /d "%~dp0"
chcp 65001 >nul 2>&1
echo Starting mouse tracker (visible window for debugging)...
echo (Close this window to stop, or use stop_tracker.bat.)
echo.
del STOP_TRACKER >nul 2>&1
python mouse_tracker.py
echo.
echo Tracker exited. Press any key to close.
pause >nul
