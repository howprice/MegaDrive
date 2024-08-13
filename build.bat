@echo off

echo Compiling C...
rem This compiles but does not assemble
rem vbccm68k src\test.c || exit /b 1

REM Compile and assemble but don't link

rem Set VBCC environment variables so can find compiler and assembler executables
set VBCC=tools\vbcc
set PATH=%VBCC%\bin;%PATH%
rem Don't specify a config file with + option, so looks for vc.cfg in current directory
rem -fastcall passes arguments in registers rather than the stack
vc -c -fastcall -o build\test.o src\test.c || exit /b 1

echo:
echo Compilation succeeded

echo Assembling ROM...
tools\vasm\Windows\x64\vasmm68k_mot -Fbin -no-opt -nosym -L build\ROM.lst -o build\ROM.gen src\ROM.s || exit /b 1

echo:
echo Assembling succeeded

rem TODO: Link ROM and C object file with vlink -belf32m68k

exit /b 0
