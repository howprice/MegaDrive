# TODO

- Add instructions for how to use this repo

- To reduce ROM size a little, go through ROM.map file and manually exclude any symbols that are not needed e.g. drv_null, drv_xgm, joy.o

- Try other SGDK gcc options: -fno-web -fno-gcse

- Is there anything in else the SGDK md.ld that is required? 
  - Maybe .stab or .stabstr (symbol tables?)

- Is an .inc file generated when the SGDK libmd.a is built? If so, what is in it?

- Fix vlink Warning 22: Attributes of section .text were changed from rw-- to rwx- in start.o.
- Is there a way to remove the VBCC standard ABI _ prefix? Or is the STDCALL macro the best solution?

# BONUS

- Add symbols to mame debugger. See https://namelessalgorithm.com/genesis/blog/debug/
  - Use vasm list and/or linker map file to generate MAME debugger script

- Add some graphics

- Try debugging with another emulator: Exodus, Mednafem, BlastEm See https://namelessalgorithm.com/genesis/blog/debug/
