# Mega Drive

Sample project. Build a ROM, written in assembly language using the SGDK XGM2 driver to play audio.

The ROM can be built using either the GNU or [VBCC](http://sun.hasenbraten.de/vbcc/) toolchains.

Windows binaries are included for convience.

[SGDK](https://github.com/Stephane-D/SGDK) library and custom tools are distributed under the MIT license (see [lib/license.txt](lib/license.txt) file).
GCC compiler and libgcc are under GNU license (GPL3) and any software build from it (as the SGDK library) is under the GCC runtime library exception license (see [bin/COPYING.RUNTIME](bin/COPYING.RUNTIME) file)

# Building the sample

A vscode tasks.json file is included for convenience. It includes task to build the ROM using either the GNU or VBCC toolchains and to run the ROM in the Mame emulator/debugger.

Python (py) must be available to generate the MAME debugger script to add symbols as comments.

## GNU Toolchain

### Windows

1. Run `build_data.bat` to build the XGM2 data.
2. Run `build_gnu.bat` to build the ROM.

### Other platforms

TODO: Add makefile

## VBCC Toolchain

### Windows

1. Run `build_data.bat` to build the XGM2 data.
2. Run `build_vbcc.bat` to build the ROM.

### Other platforms

TODO: Add makefile

# Rebuilding libmd.a manually

Prebuilt libmd.a (SGDK commit #0377311330ed0d64c2132234e88097accc87ba30 with `-ffunction-sections -fdata-sections` to reduce ROM size) can be found in lib folder.

To rebuild manually:

1. Clone https://github.com/Stephane-D/SGDK
2. Modify SGDK/makelib.gen to add -ffunction-sections -fdata-sections to DEFAULT_FLAGS_LIB (See https://github.com/Stephane-D/SGDK/issues/346)
3. Follow [SGDK Installation](https://github.com/Stephane-D/SGDK/wiki/SGDK-Installation) instructions to build libmd.a: `make -f makelib.gen`
4. Copy SGDK/lib/libmd.a libgcc.a to this repo's lib folder

# What to stick where

If you are writing in assembly language:

Code (instructions) should be in asm `CODE` sections. This will be placed in the ROM following the 68000 exception vector table and Mega Drive ROM header.

```
        SECTION CODE,CODE

        move.w   #$2700,sr
        ...

```

Constant data should be placed in asm `CODE` (or `.rodata`) sections. This will be placed in the ROM with code, or after code and remain in the ROM.

```
        SECTION CODE,CODE
        ...
        lea     Palette(pc),a0  ; can use PC-relative addressing to access nearby data in same section
        ...
        dbra    d0,.paletteLoop
        jmp     main
Palette:
        dc.w $0000 ; Colour 0 - Transparent
        dc.w $0002 ; Colour 1 - Red
        ...
```

or

```        
        SECTION .rodata,CODE
Palette:
        dc.w    $0000 ; Colour 0 - Transparent
        dc.w    $0002 ; Colour 1 - Red
```

"Data" means pre-initialised, non-zero, read-write data. Place this in DATA sections. This will be stored in ROM following code and read-only data and is copied to RAM at startup.

```
        SECTION DATA,DATA
Flags:
        dc.l    $8000001 
```

BSS means uninitialised (zero), read-write data. This takes up no space in the ROM. The Linker will allocate an address for BSS vars in RAM. It is zeroed at startup.

```
        SECTION BSS,BSS
Variables:
        dcb.b   Vars_sizeof
FrameCount:
        ds.l    0
```

# Thanks and credits

- [Stephane Dallongeville](https://github.com/Stephane-D) for the amazing SGDK
- [djh0ffman](https://hoffman.home.blog/links/) and [TTE](https://www.twitch.tv/djh0ffman) for this fun task and dupport
- [Frank  Wille](http://sun.hasenbraten.de/~frank/) for the VBCC toolchain and amazing support
- [Ice Dragon Dee](https://itaku.ee/profile/icedragondee) for the cool music

# References

Toolchain:
- [GNU Binutils](https://www.gnu.org/software/binutils/)
- [VBCC](http://sun.hasenbraten.de/vbcc/)
- [VASM](http://sun.hasenbraten.de/vasm/)
- [VLink](http://sun.hasenbraten.de/vlink/)
- [SGDK](https://github.com/Stephane-D/SGDK)
- [Everything You Never Wanted To Know About Linker Script](https://mcyoung.xyz/2021/06/01/linker-script/) by Miguel Young de la Sota aka [mcyoung](https://mcyoung.xyz/)
- [Using ld The GNU linker](https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_chapter/ld_toc.html), especially Memory Layout section
- [GNU Binutils list](https://sourceware.org/binutils/) and [docs](https://sourceware.org/binutils/docs/)

Mega Drive:
- [Official Sega Genesis Technical Overview](http://xi6.com/files/sega2f.html)
- [Sega, Sega megadrive maintenance manual](https://www.docdroid.net/nJuzlS2/mega-drive-maintenance-manual-pal-g-august-1992-rev-a-pdf)
- [Mega Drive / Genesis Architecture A practical analysis by Rodrigo Copetti](https://www.copetti.org/writings/consoles/mega-drive-genesis/)
- [Big Evil Corporation Megadrive Tutorial](https://blog.bigevilcorporation.co.uk/2012/02/28/sega-megadrive-1-getting-started/)
- [Sega Mega Drive memory map](https://segaretro.org/Sega_Mega_Drive/Memory_map)
- [learning-megadrive repo](https://github.com/sroccaserra/learning-megadrive/blob/master/src/system.asm)

# Emulators

- MAME is good for single stepping through the code
- [Regen](http://aamirm.hacking-cult.org/www/regen.html) *debugger build* e.g. Regen 0.972*D*
