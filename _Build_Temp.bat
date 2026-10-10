@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Scripts\_Build.ps1" %*
pause