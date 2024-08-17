# TODO

- Update SGDK rescomp to add labels to WAV .s files to provide the size of each sample
  e.g. snare1_13k_size equ .-snare1_13k
  - Add pull request to SGDK

- Fix VBCC toolchain build (see Frank's latest email)
  - Main issue is -gc-all removing sections marked with KEEP
  - How to suppress hundreds of warning messages: Warning 64: Section libmd.a(vdp_tile.o)(.gnu.lto_.decls.5183536e) was not recognized by target linker script.
    Could use -nowarn=64, but might miss an important section. 

- Go through ROM.map file and manually exclude any symbols that are not needed e.g. drv_null, drv_xgm, joy.o

- Try other SGDK gcc options: -fno-web -fno-gcse

- Is there anything in else the SGDK md.ld that is required? 
  - Maybe .stab or .stabstr (symbol tables?)

- When compiling with VBCC, which is the IncLong symbol prefixed with an @ ?
  - Is there a way to remove this prefix?
  - Is there a way to generate a list of exported symbols from test.c?
  - Is there a way to prevent some symbols from being exported?

- Is an .inc file generated when the SGDK libmd.a is built? If so, what is in it?

- Add simple instructions on how to build new version of libmd.a
  1. Clone SGDK
  2. Modify

# BONUS

- Add symbols to mame debugger. See https://namelessalgorithm.com/genesis/blog/debug/
  - Use vasm list and/or linker map file to generate MAME debugger script

- Add some graphics

- Try debugging with another emulator: Exodus, Mednafem, BlastEm See https://namelessalgorithm.com/genesis/blog/debug/
