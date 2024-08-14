/*
Linker script for building ROM. For use with vlink.

A linker script defines the mapping of input sections and their absolute locations in memory.

See [Using ld The GNU linker](https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_chapter/ld_toc.html), especially Memory Layout section

Example linker script: http://dark-matter.me.uk/files/diagrom.ls by jaycee1980
*/

OUTPUT_FORMAT(binary) /* Used by GNU linker ld. vlink uses -b option instead */

MEMORY
{
    /* ROM memory region */
    /* I think 4 MiB is correct */
	rom (rx) : ORIGIN = 0x000000, LENGTH = 4M

    /* RAM memory region */
    /* Sega Mega Drive has 64K of RAM at FF0000-FFFFFF */
    /* TODO: Why does SGDK define origin at 0xE0FF0000? */
    ram : ORIGIN = 0xFF0000, LENGTH = 0x010000
}

/*
The SECTIONS block defines the mapping of input sections to output sections, as well as
 their location in memory.
*/
SECTIONS
{
    /* ROM header must come first */
    RomHeader 0x00000000 :
    {
        
        *(ROM_HEADER)
    } >rom

    /* Output .text section at relocation address 0*/
    .text 0x00000000 + SIZEOF (RomHeader) : 
    { 
        *(CODE)                 /* CODE from custom assembly and C files: ROM.o, text.o ... */
        *(.text.* .text)        /* .text sections from C libraries (libmd, libgcc) */
        *(.rodata .rodata.*)    /* Read-only data sections from the C libraries */

        /* Define symbol at end of .text section */
        /* Can be used to copy succeeding data from ROM to RAM. See https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_chapter/ld_3.html#SEC21 */
        /* Not actually used by SGDK */
        _etext = .;

        /* Redundant assert. If the combined output sections directed to a region are too big for the region, the linker will issue an error message. */ 
        /* See https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_chapter/ld_3.html#SEC16 */
        /* ASSERT(. - ORIGIN(rom) <= LENGTH(rom), "ROM overflowed!"); */
    } >rom
    _stext = SIZEOF (.text); /* Size of output text section. Symbol required by SGDK */

    /* Initialised read/write .data section at RAM address 0xFF0000 */
    /* TODO: Why does SGDK place this at 0xE0FF0000? */
    /* Use AT to set the load address to the end of the .text section */
    /* Initialized data loaded into ROM, must be copied to its real address in RAM during startup. */
    /* See https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_chapter/ld_3.html#SEC21 and VASM manual */
    /* TODO: Why does AT() cause VLINK INTERNAL ERROR: next_pattern(): PHDR  load missing. */
    .data 0xFF0000 : 
    AT( ADDR (.text) + SIZEOF (.text) )
    {
        *(DATA)        /* DATA sections from assembly files e.g. ROM.o, GAME.o */
        *(.data)       /* .data sections from C libraries (libmd, libgcc) */
    } >ram
    _sdata = SIZEOF (.data); /* Size of output data section. Symbol required by SGDK */

    /* Output .bss section, containing uninitialised data */
    /* Place this after the data section */
    /* TODO: Why does SGDK place this relative to 0xE0FF0000? */
    /* The runtime must zero this section before use (boot code clears all of RAM) */
    .bss 0xFF0000 + SIZEOF (.data) : 
    { 
        *(BSS)      /* BSS sections from assembly files e.g. ROM.o, GAME.o */
        *(.bss)     /* .bss sections from C libraries (libmd, libgcc) */

        _bend = . ; /* Define symbol at end of .bss section. Required by SGDK. */
    } >ram

    /* libmd/SGDK expects the main symbol. We won't be using this */
    /* TODO: Try to remove this if can link at function level */
    main = .; 
}
