@echo off
REM TODO: Try -debugger imgui
REM TODO: -debugger_font_size 11
D:\Emulators\Mame64\mame64.exe genesis -cart build\ROM.gen -cfg_directory D:\Emulators\Mame64\cfg -nvram_directory D:\Emulators\Mame64\nvram -window -debug || exit /b 1
exit /b 0
