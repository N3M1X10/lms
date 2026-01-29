@echo off
chcp 65001>nul

:ask
cls&setlocal EnableDelayedExpansion

set timestamp=[90m[!time!][0m
set "mnclr=[0m"
set "mnclr2=[90m"
title %~nx0

echo [93m[ [96mLMS [36mall in one [94m- simple CLI shortcut for LM Studio [93m][0m&echo.

echo [93m# Functions[90m
echo !mnclr!1 - Start Server.                ^| !mnclr2!It starts the LMS and his local server[0m
echo !mnclr!2 - Stop Server.                 ^| !mnclr2!Local server will be stopped if the LMS is running[0m
echo.
echo !mnclr!3 - Load only one model.         ^| !mnclr2!One model by your choice will be loaded[0m
echo !mnclr!4 - Unload All Models.           ^| !mnclr2!All Model will be unloaded if LMS is running[0m
echo.
echo !mnclr!c - Open chat with loaded model. ^| !mnclr2!Open cli-chat with loaded model or choose to load one before start chatting there[0m
echo.
echo !mnclr!5 - Stop entire LMS.             ^| !mnclr2!It will unload all models, stop the local server and kill LMS tasks[0m
echo !mnclr!s - Status.                      ^| !mnclr2!Show the status of LMS and his server[0m
echo.
echo !mnclr!h - Show more notes              ^| !mnclr2!
echo !mnclr!x - Close this batch file        ^| !mnclr2!

echo.&set /p option=[93m%~nx0[90m_enter^>[0m

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

if "%option:~0,1%"=="c" goto :lms-chat
if "%option:~0,1%"=="s" (cls&goto lms-status)
if "%option:~0,1%"=="h" goto :batch-help
if "%option:~0,1%"=="x" goto :end

:: selection error
endlocal
cls&echo.&echo [93mWrong enter^! Please retry^!
pause&cls&goto :ask

:: Functions



:lms-start-server
echo [93m[ LMS start server ][0m
echo.&echo !timestamp! [93mlms server start[90m
if "!server_port!" neq "" (
    echo Selected server port: !server_port!
    lms server start -p !server_port!
) else (
    lms server start
)
goto endfunc



:lms-stop-server
echo [93m[ LMS stop server ][0m
call :check-lms
if %hasLMS%==1 (
    echo.&echo !timestamp! [93mlms server stop[90m
    lms server stop
)
goto endfunc



:lms-load-one-model
echo [93m[ LMS load only one model ][0m

:: -s check (start local server)
echo %option% | findstr /c:"-s">nul && (
    :: -p check (manually set port)
    echo %option% | findstr /c:"-p">nul && (
        :: enter value
        :port_selection
        echo !timestamp! [93mManually Select the port[90m
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
echo !timestamp! [93mUnloading all models[90m
lms unload --all
echo !timestamp! [93mLoading model...[90m
lms load
goto endfunc



:lms-unload-all-models
echo [93m[ LMS unload all models  ][0m
call :check-lms
if %hasLMS%==1 (
    echo.&echo !timestamp! [93mlms unload --all[90m
    lms unload --all
)
goto endfunc



:lms-status
echo [36m[ [93mLMS status [36m][0m
set exaf=0
call :check-lms
if %hasLMS%==1 (
    echo.&echo !timestamp! [93mlms server status[90m
    lms server status

    echo.&echo !timestamp! [93mlms loaded models[90m
    lms ps
)
echo.
echo [90mNo action was taken[0m
goto endfunc



:lms-stop-all
echo [91m[ [93mLMS Stop All [91m][0m
call :check-lms
if %hasLMS%==1 (
    echo.&echo !timestamp! [93mlms server stop[90m
	lms server stop

    echo.&echo !timestamp! [93mlms unload --all[90m
	lms unload --all

    echo.&echo !timestamp! [93mtaskkill "!process_name!"[90m
	taskkill /f /im "!process_name!" /t
)
goto endfunc

:lms-chat
cls&echo [92m[ [93mLMS chat [92m][0m
echo.&echo [36m[[93mi[36m] [90mUse `Ctrl+C` to return main menu[0m
call lms chat
endlocal&goto ask
rem goto endfunc


:batch-help
cls
echo [92m[ [93m- - - Help Page - - - [92m][0m
echo.
echo [100;30m[ # Tips ][40;36m
echo 1. Your first symbol in the Enter - are the function selection
echo 2. This script supports flags. You can enter them right after the function number. It's case-sensitive, but spaces are not needed
echo.
echo [100;30m[ # Flags ][40;36m
echo [93m1. Any command[36m
echo - Use [-x] if need exit right after the function
echo.
echo [93m2. Start Server[36m
echo - Use [-p] with "1" if need to manually set the local server port
echo.
echo [93m3. Load only one model[36m
echo - Use [-s] with "3" if need to start local server in addition
echo   - Use [-p] with "3" if need to manually set the local server port when using [-s]
echo.
echo [100;30m[ # Footer ][40;36m
echo [96mThis batch script is in process of developing. Please share your impressions and usage and leave feedback on Github.
echo [36mhttps://github.com/N3M1X10/lms[0m
:: supress the exaf function
set exaf=0
goto endfunc


:: end of a function
:endfunc
echo.&echo !timestamp! [36mFunction has complete[90m
if !exaf!==1 (
    endlocal & exit/b
) else (
    endlocal & pause & goto :ask
)


:check-lms
set "process_name=LM Studio.exe"
:: Checking whether process is running
tasklist | findstr /i "!process_name!">nul
if %errorlevel%==0 (
    echo.
    set hasLMS=1
    echo !timestamp! [93mProcess !process_name! has found[0m
) else (
    echo.
    set hasLMS=0
    echo !timestamp! [93mProcess !process_name! [91mnot found[0m
    echo [90mNo action was taken[0m
)
exit /b


:: eof
:end
endlocal&exit/b

:: Source: https://github.com/N3M1X10/lms
