@echo off

rem Set the current directory to the location of the batch script, using the %0 parameter
cd "%~dp0"

rem generate resources.s file
java -jar ..\bin\rescomp.jar resources.res || exit /b 1

rem assemble resources.s to object file with gnu assembler. 
rem Can't use vasmm68k_mot because rescomp generates assembly in Standard syntax rather than Motorola syntax
..\bin\gcc -c -m68000 -Wall -Wextra -Werror -B ..\bin -o resources.o resources.s || exit /b 1

..\bin\objdump --section-headers resources.o

..\bin\nm --numeric-sort resources.o

exit /b 0
