# TODO

- [x] Fix VBCC toolchain build
  - Main issue is -gc-all removing sections marked with KEEP
  - How to suppress hundreds of warning messages: Warning 64: Section libmd.a(vdp_tile.o)(.gnu.lto_.decls.5183536e) was not recognized by target linker script.
    Could use -nowarn=64, but might miss an important section. 

- [ ] Use vasm list symbols in mame debugger. See https://namelessalgorithm.com/genesis/blog/debug/
- [ ] Is there anything in the SGDK md.ld that is required? 
  - Maybe .stab or .stabstr (symbol tables?)

- [ ] When compiling with VBCC, which is the IncLong symbol prefixed with an @ ?
  - Is there a way to remove this prefix?
  - Is there a way to generate a list of exported symbols from test.c?
  - Is there a way to prevent some symbols from being exported?

- [ ] Refactor game.s out of ROM.s, and give it its own CODE, DATA and BSS SECTIONS

- [ ] Audio
  - [ ] Check Z80 init code disassembly in mame matches https://bumbershootsoft.wordpress.com/2018/03/02/the-sega-genesis-startup-code/
  - [ ] Simple PSG audio, to test audio works https://blog.bigevilcorporation.co.uk/2012/09/03/sega-megadrive-10-sound-part-i-the-psg-chip/
  - [ ] Play audio with SGDK XGM music driver with 4 channel sfx

- [ ] Is an .inc file generated when the SGDK libmd.a is built? If so, what is in it?

- [ ] Try debugging with another emulator: Exodus, Mednafem, BlastEm See https://namelessalgorithm.com/genesis/blog/debug/
