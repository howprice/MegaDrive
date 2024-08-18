/*
Linker script for building ROM. For use with vlink.

A linker script defines the mapping of input sections and their absolute locations in memory.

See [Using ld The GNU linker](https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_chapter/ld_toc.html), especially Memory Layout section

Example linker script: http://dark-matter.me.uk/files/diagrom.ls by jaycee1980
*/

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

Use KEEP to keep essential sections that may not be referenced and do not want to be discarded 
by --gc-sections. Sections linked in from libmd are free to be discarded if not referenced.

*/
SECTIONS
{
    /* Output read-only .text section at start of rom (address 0) */
    .text : 
    {
        /* Place 68000 exception vector table at the beginning of ROM. */
        KEEP(*(ExceptionVectors))
        ASSERT(. == 256, "Expect exception vectors table to be 256 bytes long");

        /* ROM header */
        KEEP(*(ROM_HEADER))
        ASSERT(. == 512, "Expect header (including exception vectors table) to be 512 bytes long");

        /* --gc-sections requires an entry point to strip unused sections: 'start' symbol or first byte of .text section. */
        /* See https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_chapter/ld_3.html#SEC24 */
        KEEP(*(START))          /* Entry point code */

        KEEP(*(CODE))           /* CODE from other assembly and C files: e.g. main.o, text.o ... */
        *(.text .text.*)        /* .text sections from C libraries (libmd, libgcc) */
        *(.rodata .rodata.*)    /* Read-only data sections from the C libraries */

        /* Add read-only data to the .text section */
        *(.rodata_bin)  /* PCM resource data is in the  .rodata_bin section */
        *(.rodata_binf) /* XGM2 resource data is in the .rodata_binf section */
        
        /* Redundant assert. If the combined output sections directed to a region are too big for the region, the linker will issue an error message. */ 
        /* See https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_chapter/ld_3.html#SEC16 */
        /* ASSERT(. - ORIGIN(rom) <= LENGTH(rom), "ROM overflowed!"); */

        /* Define symbol at end of .text section */
        /* Used to copy succeeding initialised data from ROM to RAM in the runtime. See https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_chapter/ld_3.html#SEC21 */
        /* Not actually used by SGDK */
        _etext = .;
    } >rom
    _stext = SIZEOF (.text); /* Size of output text section. Symbol required by SGDK */

    /* Initialised read/write .data section at RAM address 0xFF0000 */
    /* TODO: Why does SGDK place this at 0xE0FF0000? */
    /* Use AT to set the load address to the end of the .text section */
    /* Initialized data loaded into ROM, must be copied to its real address in RAM during startup. */
    /* See https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_chapter/ld_3.html#SEC21 and VASM manual */
    /* TODO: Why does AT() cause VLINK INTERNAL ERROR: next_pattern(): PHDR  load missing. */
    .data 0xFF0000 : 
    {
        KEEP(*(DATA))      /* DATA sections from assembly files e.g. start.o, main.o */
        *(.data .data.*)   /* .data sections from C e.g. test.o, libmd.a, libgcc.a */

        _romend = .; /* For ROM Header*/
    } >ram AT>rom
    _sdata = SIZEOF (.data); /* Size of output data section. Symbol required by SGDK */

    /* Output .bss section, containing uninitialised data */
    /* Place this after the data section */
    /* TODO: Why does SGDK place this relative to 0xE0FF0000? */
    /* The runtime must zero this section before use (boot code clears all of RAM) */
    .bss 0xFF0000 + SIZEOF (.data) (NOLOAD) : 
    { 
        KEEP(*(BSS))    /* BSS sections from assembly files e.g. ROM.o, GAME.o */
        *(.shbss)       /* From SGDK. Not sure when these occur */
        *(.bss)         /* .bss sections from C libraries (libmd, libgcc) */
        *(.bss.*)       /* .bss sections from C libraries (libmd, libgcc), else vlink Error 112: libmd.a(joy.o) (.text.JOY_update+0x11684): Cannot resolve reference to randomSeedSet, because section .bss.randomSeedSet was not recognized by the linker script. */
        *(COMMON)       /* COMMON sections from C libraries (libmd, libgcc). Should not be required because GCC defaults to -fno-common. See https://blog.thea.codes/the-most-thoroughly-commented-linker-script/ */

        _bend = . ; /* Define symbol at end of .bss section. Required by SGDK. */
    } >ram

    /* Discard LTO garbage sections to silence many many vlink messages e.g. Warning 64: Section libmd.a(types.o)(.gnu.lto_.inline.5f9446b6) was not recognized by target linker script. */
    /* This does not seem to affect the final GCC build i.e. ld/gold LTO */
    .garbage (NOLOAD): { *(.gnu.lto*) *(.comment) *(.debug*) } 
}
