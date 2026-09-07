@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -NoProfile -Command "$ScriptDir='%~dp0'.TrimEnd('\'); $s=[System.IO.File]::ReadAllText('%~dp0edit_force_registry.ps1',[System.Text.Encoding]::UTF8); Invoke-Expression $s"
