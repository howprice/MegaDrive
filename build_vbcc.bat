@echo off

echo Building with VBCC toolchain

rem Don't allow local variables to leak. ENDLOCAL is implicit regardless of how script exits.
setlocal

rem Set the current directory to the location of the batch script, using the %0 parameter
cd "%~dp0"

set BUILD_DIR=%CD%\build_vbcc
echo %BUILD_DIR%

rem Set VBCC environment variables so can find compiler and assembler executables
set VBCC=tools\vbcc
set PATH=%VBCC%\bin;%PATH%

echo Compiling test.c

rem Don't do this. This compiles but does not assemble
rem vbccm68k src\test.c || exit /b 1

rem Preprocess, compile, and assemble, but don't link
rem The +config option is not used, so vc looks for custom vc.cfg in current directory.
rem -fastcall passes arguments in registers rather than the stack
rem TODO: Set warning level high and warnings as errors
rem TODO: Enable optimization
vc -c -fastcall -o %BUILD_DIR%\test.o src\test.c || exit /b 1
echo Compilation succeeded

rem list sections and symbols in test.o
bin\objdump --section-headers %BUILD_DIR%\test.o
bin\nm %BUILD_DIR%\test.o

echo Assembling ROM.s
tools\vasm\Windows\x64\vasmm68k_mot -Felf -no-opt -o %BUILD_DIR%\ROM.o src\ROM.s || exit /b 1

rem list sections and symbols in ROM.o
bin\objdump --section-headers %BUILD_DIR%\ROM.o
bin\nm %BUILD_DIR%\ROM.o

rem TODO: Add game.s
rem echo Assembling game.s
rem tools\vasm\Windows\x64\vasmm68k_mot -Felf -no-opt -o %BUILD_DIR%\game.o src\game.s || exit /b 1
rem bin\objdump --section-headers %BUILD_DIR%\game.o

echo Linking
rem The file format of an input object file is determined automatically by the linker. 
rem The default output file format is compiled in to vlink (see -v) and may be changed by -b.
rem For target file format rawbin1, the sections and base addresses have to be specified by a linker script (option -T).
rem Note: libmd must be listed *before* libgcc because the the library that needs symbols must be first, then the library that resolves the symbol. See https://stackoverflow.com/a/409470/5425146
rem Note: -l surrounds library with lib and .lib, but our libs have the .a suffix, so specify explicitly
rem -M generates a map file
rem -gc-all Section garbage collection. Starting from the executable’s entry point, determine all referenced sections and delete the unreferenced ones.
rem NOTE: vlink seems to be able to garbage collect when outputting binary (unlike ld)
rem TODO: Why is -wfail Unrecognized? I've used it in the past
vlink -o %BUILD_DIR%\ROM.gen -b rawbin1 -T ROM.ls -M%BUILD_DIR%\ROM.map %BUILD_DIR%\ROM.o %BUILD_DIR%\test.o lib\libmd.a lib\libgcc.a -gc-all || exit /b 1

echo Linking succeeded

rem echo Extracting binary from elf
rem tools\objcopy -O binary %BUILD_DIR%\ROM.elf %BUILD_DIR%\ROM.gen || exit /b 1

echo Build succeeded

exit /b 0
