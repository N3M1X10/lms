@echo off
chcp 65001>nul
setlocal
lms load
if %errorlevel% neq 0 (pause)
>nul timeout /t 2 /nobreak
endlocal&exit
