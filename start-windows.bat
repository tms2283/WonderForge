@echo off
setlocal
cd /d "%~dp0"
where py >nul 2>nul
if %errorlevel%==0 goto runpy
where python >nul 2>nul
if %errorlevel%==0 goto runpython
echo Python 3 is required. Install Python 3 first, then rerun this launcher.
pause
exit /b 1
:runpy
start "" cmd /c "timeout /t 2 /nobreak >nul ^& start http://127.0.0.1:8765/"
py -3 server.py
exit /b %errorlevel%
:runpython
start "" cmd /c "timeout /t 2 /nobreak >nul ^& start http://127.0.0.1:8765/"
python server.py
exit /b %errorlevel%
