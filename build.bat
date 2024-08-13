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
echo Compilation succeeded

echo Assembling ROM...
tools\vasm\Windows\x64\vasmm68k_mot -Felf -no-opt -o build\ROM.o src\ROM.s || exit /b 1
echo Assembling succeeded

echo Linking...
rem The file format of an input object file is determined automatically by the linker. 
rem The default output file format is compiled in (see -v) and may be changed by -b.
rem TODO: Link ROM object file and C object file
rem For target file format rawbin1, The sections and base addresses have to be specified by a linker script (option -T).
rem TODO: Why is -wfail Unrecognized? I've used it in the past
vlink -b rawbin1 -T ROM.ls -o build\ROM.gen build\ROM.o build\test.o || exit /b 1
echo Linking succeeded

echo Build succeeded

exit /b 0
