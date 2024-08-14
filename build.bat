@echo off

echo Compiling test.c
rem Set VBCC environment variables so can find compiler and assembler executables
set VBCC=tools\vbcc
set PATH=%VBCC%\bin;%PATH%

rem This compiles but does not assemble
rem vbccm68k src\test.c || exit /b 1

REM Compile and assemble but don't link
rem The +config option is not used, so vc looks for custom vc.cfg in current directory.
rem -fastcall passes arguments in registers rather than the stack
vc -c -fastcall -o build\test.o src\test.c || exit /b 1
echo Compilation succeeded

tools\objdump --section-headers build\test.o

echo Assembling ROM.s
tools\vasm\Windows\x64\vasmm68k_mot -Felf -no-opt -o build\ROM.o src\ROM.s || exit /b 1
tools\objdump --section-headers build\ROM.o

rem echo Assembling game.s
rem tools\vasm\Windows\x64\vasmm68k_mot -Felf -no-opt -o build\game.o src\game.s || exit /b 1
rem tools\objdump --section-headers build\game.o

echo Linking
rem The file format of an input object file is determined automatically by the linker. 
rem The default output file format is compiled in (see -v) and may be changed by -b.
rem For target file format rawbin1, The sections and base addresses have to be specified by a linker script (option -T).
rem -M generates a map file
rem TODO: Why is -wfail Unrecognized? I've used it in the past
rem vlink -b rawbin1 -T ROM.ls -o build\ROM.gen -Mbuild\ROM.map build\ROM.o build\test.o || exit /b 1

rem Try linking with GNU linker ld
rem Note: -l surrounds library with lib and .a
rem Note: libmd must be listed *before* libgcc because the the library that needs symbols must be first, then the library that resolves the symbol. See https://stackoverflow.com/a/409470/5425146
tools\ld -o build/ROM.gen -T ROM.ls -Map build/ROM.map build/test.o build/ROM.o -L lib -l md -l gcc || exit /b 1

echo Linking succeeded

echo Build succeeded

exit /b 0
