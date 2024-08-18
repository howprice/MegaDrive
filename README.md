# Mega Drive

Sample project. Build a ROM, written in assembly language using the SGDK XGM2 driver to play audio.

# Rebuilding libmd.a manually

Prebuilt libmd.a can be found in lib folder. To rebuild manually:

1. Clone https://github.com/Stephane-D/SGDK
2. Modify SGDK/makelib.gen to add -ffunction-sections -fdata-sections to DEFAULT_FLAGS_LIB (See https://github.com/Stephane-D/SGDK/issues/346)
3. Follow [SGDK Installation](https://github.com/Stephane-D/SGDK/wiki/SGDK-Installation) instructions to build libmd.a: `make -f makelib.gen`
4. Copy SGDK/lib/libmd.a libgcc.a to this repo lib folder

# Emulators

- MAME is good for single stepping through the code
- [Regen](http://aamirm.hacking-cult.org/www/regen.html) *debugger build* e.g. Regen 0.972*D*

# Tools

- [objdump](https://web.mit.edu/gnu/doc/html/binutils_5.html) - Display information from object files. Windows exe in SGDK

# References

Toolchain:
- [Everything You Never Wanted To Know About Linker Script](https://mcyoung.xyz/2021/06/01/linker-script/)
- [Using ld The GNU linker](https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_chapter/ld_toc.html), especially Memory Layout section
- Latest [GNU Binutils list](https://sourceware.org/binutils/) [docs](https://sourceware.org/binutils/docs/)

Mega Drive:
- [Big Evil Corporation Megadrive Tutorial](https://blog.bigevilcorporation.co.uk/2012/02/28/sega-megadrive-1-getting-started/)
- [Sega Mega Drive memory map](https://segaretro.org/Sega_Mega_Drive/Memory_map)
- [Official Sega Genesis Technical Overview](http://xi6.com/files/sega2f.html)
- Handy register equates and macros in [learning-megadrive repo](https://github.com/sroccaserra/learning-megadrive/blob/master/src/system.asm)
