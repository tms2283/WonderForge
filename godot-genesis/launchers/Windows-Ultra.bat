@echo off
setlocal
cd /d "%~dp0.."
where godot >nul 2>nul
if %errorlevel% neq 0 (
  echo Godot 4.7.x not found on PATH. Open this project in Godot and enable Forward+ on a supported GPU.
  pause
  exit /b 1
)
REM Ultra quality is experimental until real gaming-PC visual/performance validation.
godot --rendering-method forward_plus --path . -- --quality=ultra
