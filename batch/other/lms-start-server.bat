@echo off
chcp 65001>nul
setlocal
lms server start
>nul timeout /t 1 /nobreak
endlocal&exit
