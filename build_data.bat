@echo off

rem Set the current directory to the location of the batch script, using the %0 parameter
cd "%~dp0"

if not exist build_data (
	mkdir build_data
	echo Created build_data directory
)

rem Convert resources to .s files (Standard Syntax)
java -jar bin\rescomp.jar data\sample_data.res build_data\sample_data.s || exit /b 1
java -jar bin\rescomp.jar data\tara.res build_data\tara.s || exit /b 1

rem Assemble resources.s to object file with GNU assembler. 
rem Can't use vasmm68k_mot because rescomp generates assembly in Standard syntax rather than Motorola syntax
set FLAGS=-c -m68000 -Wall -Wextra -Werror -B bin

bin\gcc %FLAGS% -o build_data\sample_data.o build_data\sample_data.s || exit /b 1
bin\objdump --section-headers build_data\sample_data.o
bin\nm --numeric-sort build_data\sample_data.o

bin\gcc %FLAGS% -o build_data\tara.o build_data\tara.s || exit /b 1
bin\objdump --section-headers build_data\tara.o
bin\nm --numeric-sort build_data\tara.o

echo Data build succeeded
exit /b 0
