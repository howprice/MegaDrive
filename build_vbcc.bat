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
rem -fastcall uses the Fastcall-ABI which passes arguments in registers rather than the stack, and prefixes function names with a @ e.g. @IncLong
rem Without fastcall, function names are prefixed with an underscore e.g. _IncLong
rem TODO: Set warning level high and warnings as errors
rem TODO: Enable optimization
vc -c -o %BUILD_DIR%\test.o src\test.c || exit /b 1
echo Compilation succeeded

rem list sections and symbols in test.o
rem objdump lists sections, nm lists symbols ("names")
bin\objdump --section-headers %BUILD_DIR%\test.o
bin\nm --numeric-sort %BUILD_DIR%\test.o

rem Assemble .s files to .o files
rem Use tools\vasm\Windows\x64\vasmm68k_mot version 2.0beta. vbcc contains older version vasm 1.9
echo Assembling (with vasm 2.0beta)
set ASM_FLAGS=-Felf -no-opt

tools\vasm\Windows\x64\vasmm68k_mot %ASM_FLAGS% -o %BUILD_DIR%\Vectors.o src\Vectors.s || exit /b 1
bin\objdump --section-headers %BUILD_DIR%\Vectors.o
rem bin\nm --numeric-sort %BUILD_DIR%\Vectors.o

tools\vasm\Windows\x64\vasmm68k_mot %ASM_FLAGS% -o %BUILD_DIR%\RomHeader.o src\RomHeader.s || exit /b 1
bin\objdump --section-headers %BUILD_DIR%\RomHeader.o
rem bin\nm --numeric-sort %BUILD_DIR%\RomHeader.o

tools\vasm\Windows\x64\vasmm68k_mot %ASM_FLAGS% -o %BUILD_DIR%\start.o src\start.s || exit /b 1
bin\objdump --section-headers %BUILD_DIR%\start.o
bin\nm --numeric-sort %BUILD_DIR%\start.o

tools\vasm\Windows\x64\vasmm68k_mot %ASM_FLAGS% -o %BUILD_DIR%\main.o src\main.s || exit /b 1
bin\objdump --section-headers %BUILD_DIR%\main.o
bin\nm --numeric-sort %BUILD_DIR%\main.o

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
vlink -o %BUILD_DIR%\ROM.gen -b rawbin1 -T ROM.ls -M%BUILD_DIR%\ROM.map -gc-all ^
 %BUILD_DIR%/Vectors.o %BUILD_DIR%/RomHeader.o %BUILD_DIR%/start.o %BUILD_DIR%/main.o %BUILD_DIR%/test.o ^
 build_data/sample_data.o build_data/tara.o build_data/soundfx.o ^
 lib\libmd.a lib\libgcc.a || exit /b 1

echo Linking succeeded

rem echo Extracting binary from elf
rem No need to extract binary from elf. vlink can output garbage-collected binary directly.
rem tools\objcopy -O binary %BUILD_DIR%\ROM.elf %BUILD_DIR%\ROM.gen || exit /b 1

echo Build succeeded

exit /b 0
