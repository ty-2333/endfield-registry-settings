@echo off
cd /d "%~dp0"

REM Quick force: Fullscreen, 1920x1080, 60fps
powershell -ExecutionPolicy Bypass -NoProfile -Command "$Display='Fullscreen'; $Resolution='1920x1080'; $FPS='60'; $Quality='Unchanged'; $Language='Unchanged'; $AutoHDR='Unchanged'; $s=[System.IO.File]::ReadAllText('%~dp0set_game_settings.ps1',[System.Text.Encoding]::UTF8); Invoke-Expression $s"
