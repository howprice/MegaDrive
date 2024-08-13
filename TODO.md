# DONE

- [x] Build [simple test ROM](https://github.com/sroccaserra/learning-megadrive) with VASM and run in emulator
- [x] Initialise the system. https://blog.bigevilcorporation.co.uk/2012/03/09/sega-megadrive-3-awaking-the-beast/
- [x] Upload palette to VPD and set background colourhttps://blog.bigevilcorporation.co.uk/2012/03/23/sega-megadrive-4-hello-world/
- [x] Enable vertical blanking interrupt before entering main loop
- [x] Animate background colour in vertical blank interrupt handler https://blog.bigevilcorporation.co.uk/2012/03/23/sega-megadrive-4-hello-world/
- [x] Compile test.c file to M68K machine code with VBCC (vc.exe)
- [x] Test: INCBIN binary test.o into ROM and call IncLong routine
- [x] Link ROM.o and test.o ELF object files and call IncLong (c function) from ROM.s

# TODO

- [ ] Why is the IncLong symbol prefixed with an @ ?
  - Is there a way to remove this prefix?
  - Is there a way to generate a list of exported symbols from test.c?
  - Is there a way to prevent some symbols from being exported?

- [ ] Compile test.c with GCC
  - Link GCC-generated test.o elf object file with ROM.o
- [ ] Use register equates and macros from https://github.com/sroccaserra/learning-megadrive/blob/master/src/system.asm
- [ ] Check Z80 code disassembly in mame matches https://bumbershootsoft.wordpress.com/2018/03/02/the-sega-genesis-startup-code/
- [ ] Simple PSG audio, to test audio works https://blog.bigevilcorporation.co.uk/2012/09/03/sega-megadrive-10-sound-part-i-the-psg-chip/
- [ ] Build simple test ROM with VLINK. Binary should be identical
- [ ] Is an .inc file generated when the SGDK libmd.a is built? If so, what is in it?
- [ ] Play audio with SGDK XGM music driver with 4 channel sfx

- [ ] Try debugging with another emulator: Exodus, Mednafem, BlastEm See https://namelessalgorithm.com/genesis/blog/debug/
- [ ] Use vasm list symbols in mame debugger. See https://namelessalgorithm.com/genesis/blog/debug/
