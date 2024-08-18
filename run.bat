@echo off

REM Check if the build directory argument is provided
if "%1"=="" (
    echo Usage: run.bat [build_directory]
    exit /b 1
)

set BUILD_DIR=%1

REM Check if the second argument is provided and set the DEBUG_OPTION variable
if "%2"=="" (
    set DEBUG_OPTION=
) else (
    set DEBUG_OPTION=-debug
)

if "%3"=="" (
    set DEBUGSCRIPT_OPTION=
) else (
    set DEBUGSCRIPT_OPTION=-debugscript %BUILD_DIR%\%3
)

REM TODO: Try -debugger imgui
REM TODO: -debugger_font_size 11
D:\Emulators\Mame64\mame64.exe genesis -cart %BUILD_DIR%\ROM.gen %DEBUG_OPTION% %DEBUGSCRIPT_OPTION% -window -skip_gameinfo ^
 -cfg_directory D:\Emulators\Mame64\cfg -nvram_directory D:\Emulators\Mame64\nvram -snapshot_directory D:\Emulators\Mame64\snap -comment_directory D:\Emulators\Mame64\comment || exit /b 1
 
exit /b 0
