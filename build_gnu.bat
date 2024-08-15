@echo off

echo Building with GNU toolchain

rem Don't allow local variables to leak. ENDLOCAL is implicit regardless of how script exits.
setlocal

rem Set the current directory to the location of the batch script, using the %0 parameter
cd "%~dp0"

set BUILD_DIR=%CD%\build_gnu
echo %BUILD_DIR%

echo Compiling test.c

rem Preprocess, compile, and assemble, but don't link
rem Default target for the gcc executable is m68k-elf
rem NOTE: -B bin is essential so gcc knows where to find the assembler and linker
rem NOTE: -fomit-frame-pointer removes the LINK and UNLK from within the function call if it is not required. This is a performance optimization for small functions.
rem NOTE: It is not possible to specify "fastcall" calling convention for 68000, which passes arguments in registers rather than the stack. (vc allows this)
rem TODO: Use other SGDK options? -fuse-linker-plugin -fno-web -fno-gcse -fno-unit-at-a-time 
rem TODO: What is the -MMD option used by SGDK? See https://gcc.gnu.org/onlinedocs/gcc/Preprocessor-Options.html
bin\gcc -c -m68000 -Wall -Wextra -Werror -B bin ^
 -O3 ^
 -fomit-frame-pointer ^
 -ffunction-sections -fdata-sections -ffat-lto-objects -flto ^
 -o %BUILD_DIR%/test.o src/test.c || exit /b 1
echo Compilation succeeded

rem list sections and symbols in test.o
bin\objdump --section-headers %BUILD_DIR%\test.o
rem bin\nm --numeric-sort %BUILD_DIR%\test.o

echo Assembling ROM.s (with vasm)
rem tools\vasm\Windows\x64\vasmm68k_mot is version 2.0beta. vbcc contains vasm 1.9
tools\vasm\Windows\x64\vasmm68k_mot -D__GNUC__ -Felf -no-opt -o %BUILD_DIR%\ROM.o src\ROM.s || exit /b 1

rem list sections and symbols in ROM.o
bin\objdump --section-headers %BUILD_DIR%\ROM.o
rem bin\nm --numeric-sort %BUILD_DIR%\ROM.o

rem TODO: Add game.s
rem echo Assembling game.s
rem tools\vasm\Windows\x64\vasmm68k_mot -Felf -no-opt -o %BUILD_DIR%\game.o src\game.s || exit /b 1
rem bin\objdump --section-headers %BUILD_DIR%\game.o

echo Linking
rem Note: -l surrounds library with lib and .a
rem Note: libmd must be listed *before* libgcc because the the library that needs symbols must be first, then the library that resolves the symbol. See https://stackoverflow.com/a/409470/5425146
rem Need to use --gc-sections to remove unused sections from libmd and libgcc. This reduces the size of the binary significantly. See https://unix.stackexchange.com/a/715901
rem Unfortunately, GNU ld ignores --gc-sections with OUTPUT_FORMAT(binary), so using elf32-m68k as intermediate format. See https://stackoverflow.com/a/48286388/5425146
rem To list formats supported by ld.exe, use ld --help and search for "supported targets" and "supported emulations"
rem Can use --print-gc-sections to see what sections are removed, but it produces a lot of output.
bin\ld --oformat elf32-m68k -o %BUILD_DIR%/ROM.elf -T ROM.ls -Map %BUILD_DIR%/ROM.map %BUILD_DIR%/ROM.o %BUILD_DIR%/test.o data/resources.o -L lib -l md -l gcc --gc-sections || exit /b 1

rem list sections and symbols in ROM.elf
bin\objdump --section-headers %BUILD_DIR%\ROM.elf
rem bin\nm --numeric-sort %BUILD_DIR%\ROM.elf

echo Linking succeeded

echo Extracting binary from elf
bin\objcopy -O binary %BUILD_DIR%/ROM.elf %BUILD_DIR%/ROM.gen || exit /b 1

echo Generated %BUILD_DIR%\ROM.gen
echo Build succeeded

exit /b 0