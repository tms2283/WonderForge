@echo off
setlocal
cd /d "%~dp0.."
where godot >nul 2>nul
if %errorlevel% neq 0 (
  echo Install Godot 4.7.x and add its executable to PATH, or open project.godot in the Godot editor.
  pause
  exit /b 1
)
REM The project default renderer is Compatibility for broad platform support.
REM Creator should be benchmarked with Mobile/Forward+ on suitable GPUs.
godot --path . -- --quality=creator
