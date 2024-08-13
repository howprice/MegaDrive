# TODO

- [x] Build [simple test ROM](https://github.com/sroccaserra/learning-megadrive) with VASM and run in emulator
- [x] Initialise the system. https://blog.bigevilcorporation.co.uk/2012/03/09/sega-megadrive-3-awaking-the-beast/
- [x] Upload palette to VPD and set background colourhttps://blog.bigevilcorporation.co.uk/2012/03/23/sega-megadrive-4-hello-world/
- [ ] Animate background colour in main loop (or vertical blank interrupt), so can tell application is alive https://blog.bigevilcorporation.co.uk/2012/03/23/sega-megadrive-4-hello-world/
- [ ] Use register equates and macros from https://github.com/sroccaserra/learning-megadrive/blob/master/src/system.asm
- [ ] Check Z80 code disassembly in mame matches https://bumbershootsoft.wordpress.com/2018/03/02/the-sega-genesis-startup-code/
- [ ] Simple PSG audio, to test audio works https://blog.bigevilcorporation.co.uk/2012/09/03/sega-megadrive-10-sound-part-i-the-psg-chip/
- [ ] Build simple test ROM with VLINK. Binary should be identical
- [ ] Is an .inc file generated when the SGDK libmd.a is built? If so, what is in it?
- [ ] Compile simple .c file with GCC and link with VLINK. May need a linker script.
- [ ] Play audio with SGDK XGM music driver with 4 channel sfx

- [ ] Try debugging with another emulator: Exodus, Mednafem, BlastEm See https://namelessalgorithm.com/genesis/blog/debug/
- [ ] Use vasm list symbols in mame debugger. See https://namelessalgorithm.com/genesis/blog/debug/
