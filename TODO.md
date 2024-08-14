# TODO

- [ ] Try to discard unused functions from libmd and libgcc https://unix.stackexchange.com/a/715901
  - libgcc.a is prebuilt and 301 KB. libmd.a is built locally and is 3.64 MB
  
- [ ] Refactor game.s out of ROM.s, and give it its own CODE, DATA and BSS SECTIONS

- [ ] Is there anything in the SGDK md.ld that is required? 
  - Maybe .stab or .stabstr (symbol tables?)

- [ ] Why is the IncLong symbol prefixed with an @ ?
  - Is there a way to remove this prefix?
  - Is there a way to generate a list of exported symbols from test.c?
  - Is there a way to prevent some symbols from being exported?

- [ ] Compile test.c with GCC
  - Link GCC-generated test.o elf object file with ROM.o
- [ ] Use register equates and macros from https://github.com/sroccaserra/learning-megadrive/blob/master/src/system.asm
- [ ] Check Z80 code disassembly in mame matches https://bumbershootsoft.wordpress.com/2018/03/02/the-sega-genesis-startup-code/
- [ ] Simple PSG audio, to test audio works https://blog.bigevilcorporation.co.uk/2012/09/03/sega-megadrive-10-sound-part-i-the-psg-chip/
- [ ] Is an .inc file generated when the SGDK libmd.a is built? If so, what is in it?
- [ ] Play audio with SGDK XGM music driver with 4 channel sfx

- [ ] Try debugging with another emulator: Exodus, Mednafem, BlastEm See https://namelessalgorithm.com/genesis/blog/debug/
- [ ] Use vasm list symbols in mame debugger. See https://namelessalgorithm.com/genesis/blog/debug/
