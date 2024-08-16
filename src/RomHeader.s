; ------------------------------------------------------------------
; Sega Megadrive ROM header
; ------------------------------------------------------------------

        SECTION ROM_HEADER,DATA

RomHeader:
        dc.b "SEGA GENESIS    "                                 ; Console name
        dc.b "(C)SEGA 1992.SEP"                                 ; Copyrght holder and release date
        dc.b "METAL GEAR XGM2 AUDIO DEMO                      " ; Domestic name
        dc.b "METAL GEAR XGM2 AUDIO DEMO                      " ; International name
        dc.b "GM XXXXXXXX-XX"                                   ; Version number
        dc.w $0000                                              ; Checksum (not read by boot code - don't worry about its value)
        dc.b "J               "                                 ; I/O support
        dc.l $00000000                                          ; Start address of ROM
        dc.l _romend                                            ; End address of ROM. Symbol defined in linker script
        dc.l $00FF0000                                          ; Start address of RAM
        dc.l $00FFFFFF                                          ; End address of RAM
        dc.l $00000000                                          ; SRAM enabled
        dc.l $00000000                                          ; Unused
        dc.l $00000000                                          ; Start address of SRAM
        dc.l $00000000                                          ; End address of SRAM
        dc.l $00000000                                          ; Unused
        dc.l $00000000                                          ; Unused
        dc.b "                                        "         ; Notes (unused)
        dc.b "JUE             "                                 ; Country codes

	PRINTT "ROM header size (bytes):"
	PRINTV *-RomHeader
RomHeader_sizeof:
        ASSERT *-RomHeader==256,"Expect ROM header to be 256 bytes"

