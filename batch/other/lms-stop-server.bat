@echo off
chcp 65001>nul
setlocal EnableDelayedExpansion
:: Проверяем, запущен ли процесс "LM Studio.exe"
tasklist | findstr /i "LM Studio.exe">nul
if %errorlevel%==0 (
    :: Если процесс запущен, выводим сообщение
    set hasLMS=1
    echo Процесс LM Studio.exe найден ^(hasLMS=!hasLMS!^)
) else (
    :: Если процесс не запущен, выводим сообщение
    set hasLMS=0
    echo Процесс LM Studio.exe не найден ^(hasLMS=!hasLMS!^)
    >nul timeout /t 2 /nobreak
)
if %hasLMS%==1 (
	lms server stop
)
endlocal&exit