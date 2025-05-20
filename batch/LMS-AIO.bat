@echo off
chcp 65001>nul
set title=LM Studio - CLI Service
title %title%

:ask
setlocal EnableDelayedExpansion
echo [0m&echo %title%&echo.
echo Functions:
echo 1 - Start Server.         It starts the LMS and his local server
echo 2 - Stop Server.          Local server will be stopped if the LMS is running
echo 3 - Load only one model.  One model by your choice will be loaded
echo 4 - Unload All Models.    All Model will be unloaded if LMS is running
echo 5 - Stop entire LMS.      It will unload all models, stop the local server and kill LMS tasks
echo s - Status.               Show the status of LMS and his server
echo h - Show more notes       
echo x - Close this batch file 

echo.&set /p option=Enter: 

:: supported flags check 
::exit right after function
echo %option% | findstr /c:"-x">nul && (set exaf=1)

:: options check
if "%option:~0,1%"=="1" (
    :: -p check
    echo %option% | findstr /c:"-p">nul && (
        :: enter value
        :port_selection
        set /p server_port=Enter port: 
        :: is this a num? check
        set /a "num=0" && set /a "num=!server_port!"
        if !num! equ 0 echo That's not a number &goto port_selection
        cls&goto lms-start-server
    )
    cls&goto lms-start-server
)
if "%option:~0,1%"=="2" (cls&goto lms-stop-server)
if "%option:~0,1%"=="3" (cls&goto lms-load-one-model)
if "%option:~0,1%"=="4" (cls&goto lms-unload-all-models)
if "%option:~0,1%"=="5" (cls&goto lms-stop-all)

if "%option:~0,1%"=="s" (cls&goto lms-status)
if "%option:~0,1%"=="h" goto :batch-help
if "%option:~0,1%"=="x" goto :end

:: selection error
endlocal
cls&echo.&echo [93mWrong enter^! Please retry^!
pause&cls&goto :ask

:: Functions

:lms-start-server
echo.&echo [!time!] lms server start
if "!server_port!" neq "" (
    echo Selected server port: !server_port!
    lms server start -p !server_port!
) else (
    lms server start
)
goto endfunc


:lms-stop-server
echo LMS Stop Server
:: Checking whether the "LM Studio.exe" process is running
tasklist | findstr /i "LM Studio.exe">nul
if %errorlevel%==0 (
    echo.
    set hasLMS=1
    echo [!time!] Process LM Studio.exe has found
) else (
    echo.
    set hasLMS=0
    echo [!time!] Process LM Studio.exe not found
    echo No action was taken
)
if %hasLMS%==1 (
    echo.&echo [!time!] lms server stop
    lms server stop
)
goto endfunc


:lms-load-one-model
:: -s check (start local server)
echo %option% | findstr /c:"-s">nul && (
    :: -p check (manually set port)
    echo %option% | findstr /c:"-p">nul && (
        :: enter value
        :port_selection
        echo [!time!] Manually Select the port
        set /p server_port=Enter port: 
        :: is this a num? check
        set /a "num=0" && set /a "num=!server_port!"
        if !num! equ 0 echo That's not a number &goto port_selection
        cls
    )
    :: start server
    if "!server_port!" neq "" (
        echo Selected server port: !server_port!
        lms server start -p !server_port!
    ) else (
        lms server start
    )
)

:: unload all models and load only one model
cls
echo [!time!] Unloading all models
lms unload --all
echo [!time!] Loading model
lms load

goto endfunc


:lms-unload-all-models
echo LMS Unload All Models 
:: Checking whether the "LM Studio.exe" process is running
tasklist | findstr /i "LM Studio.exe">nul
if %errorlevel%==0 (
    echo.
    set hasLMS=1
    echo [!time!] Process LM Studio.exe has found
) else (
    echo.
    set hasLMS=0
    echo [!time!] Process LM Studio.exe not found
    echo No action was taken
)
if %hasLMS%==1 (
    echo [!time!] lms unload --all
    lms unload --all
)
goto endfunc


:lms-status
echo LMS Status
set exaf=0
:: Checking whether the "LM Studio.exe" process is running
tasklist | findstr /i "LM Studio.exe">nul
if %errorlevel%==0 (
    echo.&echo [!time!] Process LM Studio.exe has found
    echo.&echo [!time!] lms server status
    lms server status
    echo.&echo [!time!] lms loaded models
    lms ps
) else (
    echo.
    echo [!time!] Process LM Studio.exe not found
    echo LM Studio currently not running
)
echo.
echo No action was taken
goto endfunc


:lms-stop-all
echo LMS Stop All
:: Checking whether the "LM Studio.exe" process is running
set process_name=LM Studio.exe
tasklist | findstr /i "!process_name!">nul
if %errorlevel%==0 (
    echo.
    set hasLMS=1
    echo [!time!] Process LM Studio.exe has found
) else (
    echo.
    set hasLMS=0
    echo [!time!] Process LM Studio.exe not found
    echo No action was taken
)
if %hasLMS%==1 (
    echo [!time!] lms server stop
	lms server stop

    echo [!time!] lms unload --all
	lms unload --all

	>nul timeout /t 1 /nobreak

    echo [!time!] taskkill "!process_name!"
	taskkill /f /im "!process_name!" /t
)
goto endfunc

:batch-help
cls
echo [101;93m[ Help Page ][0m
echo.
echo 1. Your first symbol in the Enter - are the function selection
echo 2. This script supports flags. You can enter them right after the function number. It's case-sensitive, but spaces are not needed
echo.
echo Flags:
echo.
echo [93mAny command:[0m
echo Use [-x] if need exit right after the function
echo.
echo [93m1. Start Server:[0m
echo Use [-p] with "1" if need to manually set the local server port
echo.
echo [93m3. Load only one model:[0m
echo Use [-s] with "3" if need to start local server in addition
echo Use [-p] with "3" if need to manually set the local server port when using [-s]
echo.
echo [96mThis batch script is in process of developing. Please share your impressions and usage and leave feedback on Github.
echo [36mhttps://github.com/N3M1X10/lms[0m

:: block the exaf function
set exaf=0
goto endfunc


:: end of a function
:endfunc
echo.&echo [!time!] Function has complete
if !exaf!==1 (endlocal&exit/b)
endlocal&pause&cls&goto :ask


:: eof
:end
endlocal&exit/b

:: Source: https://github.com/N3M1X10/lms
