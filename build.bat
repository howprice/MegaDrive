@echo off
echo Assembling...
tools\vasm\Windows\x64\vasmm68k_mot -Fbin -no-opt -nosym -L build\ROM.lst -o build\ROM.gen src\ROM.s || exit /b 1

echo:
echo Assembling successful

exit /b 0
