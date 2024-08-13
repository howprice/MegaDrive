# DONE

- [x] Build [simple test ROM](https://github.com/sroccaserra/learning-megadrive) with VASM and run in emulator
- [x] Initialise the system. https://blog.bigevilcorporation.co.uk/2012/03/09/sega-megadrive-3-awaking-the-beast/
- [x] Upload palette to VPD and set background colourhttps://blog.bigevilcorporation.co.uk/2012/03/23/sega-megadrive-4-hello-world/
- [x] Enable vertical blanking interrupt before entering main loop
- [x] Animate background colour in vertical blank interrupt handler https://blog.bigevilcorporation.co.uk/2012/03/23/sega-megadrive-4-hello-world/
- [x] Compile test.c file to M68K machine code with VBCC (vc.exe)

# TODO

- [ ] Test: INCBIN binary test.b into ROM and call Inc routine
- [ ] Link (vbcc-compiled) test.o into ROM with VLINK
  - Modify vc.cfg assembler output format from -Fbin to -Felf
  - Modify ROM to build as elf
  - Add linker script to layout final ROM binary image
- [ ] Compile .c file with GCC
- [ ] Use register equates and macros from https://github.com/sroccaserra/learning-megadrive/blob/master/src/system.asm
- [ ] Check Z80 code disassembly in mame matches https://bumbershootsoft.wordpress.com/2018/03/02/the-sega-genesis-startup-code/
- [ ] Simple PSG audio, to test audio works https://blog.bigevilcorporation.co.uk/2012/09/03/sega-megadrive-10-sound-part-i-the-psg-chip/
- [ ] Build simple test ROM with VLINK. Binary should be identical
- [ ] Is an .inc file generated when the SGDK libmd.a is built? If so, what is in it?
- [ ] Play audio with SGDK XGM music driver with 4 channel sfx

- [ ] Try debugging with another emulator: Exodus, Mednafem, BlastEm See https://namelessalgorithm.com/genesis/blog/debug/
- [ ] Use vasm list symbols in mame debugger. See https://namelessalgorithm.com/genesis/blog/debug/
