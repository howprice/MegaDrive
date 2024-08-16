# TODO

- BUG: XGM2 music plays very slow when Country is set to Europe in Regen emulator
  - Check correct playpack speed on both PAL and NTSC

- Test playing PCM sound effects with XGM2 driver

- Fix VBCC toolchain build
  - Main issue is -gc-all removing sections marked with KEEP
  - How to suppress hundreds of warning messages: Warning 64: Section libmd.a(vdp_tile.o)(.gnu.lto_.decls.5183536e) was not recognized by target linker script.
    Could use -nowarn=64, but might miss an important section. 

- Use vasm list symbols in mame debugger. See https://namelessalgorithm.com/genesis/blog/debug/

- Is there anything in else the SGDK md.ld that is required? 
  - Maybe .stab or .stabstr (symbol tables?)

- When compiling with VBCC, which is the IncLong symbol prefixed with an @ ?
  - Is there a way to remove this prefix?
  - Is there a way to generate a list of exported symbols from test.c?
  - Is there a way to prevent some symbols from being exported?

- Refactor game.s out of ROM.s, and give it its own CODE, DATA and BSS SECTIONS

- Is an .inc file generated when the SGDK libmd.a is built? If so, what is in it?

- Try debugging with another emulator: Exodus, Mednafem, BlastEm See https://namelessalgorithm.com/genesis/blog/debug/
