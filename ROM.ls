/*
Linker script for building ROM. For use with vlink.

A linker script defines the mapping of input sections and their absolute locations in memory.

Example linker script: http://dark-matter.me.uk/files/diagrom.ls by jaycee1980
*/

MEMORY
{
	ROM (rx) : ORIGIN = 0x000000, LENGTH = 512K
}

/*
The SECTIONS block defines the mapping of input sections to output sections, as well as
 their location in memory.
*/
SECTIONS
{
    /* Add a section containing the code from ROM.o */
    .ROM : { ROM.o(CODE) } >ROM

    /* Add a section containing the code from test.o */
    .test : { test.o(CODE) } >ROM

    ASSERT(. - ORIGIN(ROM) <= LENGTH(ROM), "ROM overflowed!");
}
