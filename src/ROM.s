; ******************************************************************
; Sega Megadrive ROM header
; ******************************************************************
        dc.l   $00FFE000       ; Initial SSP
        dc.l   EntryPoint      ; Initial PC
        dc.l   Exception       ; Bus error
        dc.l   Exception       ; Address error
        dc.l   Exception       ; Illegal instruction
        dc.l   Exception       ; Division by zero
        dc.l   Exception       ; CHK exception
        dc.l   Exception       ; TRAPV exception
        dc.l   Exception       ; Privilege violation
        dc.l   Exception       ; TRACE exception
        dc.l   Exception       ; Line-A emulator
        dc.l   Exception       ; Line-F emulator
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Spurious exception
        dc.l   Exception       ; IRQ level 1
        dc.l   Exception       ; IRQ level 2
        dc.l   Exception       ; IRQ level 3
        dc.l   HBlankInterrupt ; IRQ level 4 (horizontal retrace interrupt)
        dc.l   Exception       ; IRQ level 5
        dc.l   VBlankInterrupt ; IRQ level 6 (vertical retrace interrupt)
        dc.l   Exception       ; IRQ level 7
        dc.l   Exception       ; TRAP #00 exception
        dc.l   Exception       ; TRAP #01 exception
        dc.l   Exception       ; TRAP #02 exception
        dc.l   Exception       ; TRAP #03 exception
        dc.l   Exception       ; TRAP #04 exception
        dc.l   Exception       ; TRAP #05 exception
        dc.l   Exception       ; TRAP #06 exception
        dc.l   Exception       ; TRAP #07 exception
        dc.l   Exception       ; TRAP #08 exception
        dc.l   Exception       ; TRAP #09 exception
        dc.l   Exception       ; TRAP #10 exception
        dc.l   Exception       ; TRAP #11 exception
        dc.l   Exception       ; TRAP #12 exception
        dc.l   Exception       ; TRAP #13 exception
        dc.l   Exception       ; TRAP #14 exception
        dc.l   Exception       ; TRAP #15 exception
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        dc.l   Exception       ; Unused (reserved)
        
        dc.b "SEGA GENESIS    "                                 ; Console name
        dc.b "(C)SEGA 1992.SEP"                                 ; Copyrght holder and release date
        dc.b "YOUR GAME HERE                                  " ; Domestic name
        dc.b "YOUR GAME HERE                                  " ; International name
        dc.b "GM XXXXXXXX-XX"                                   ; Version number
        dc.w $0000                                              ; Checksum (not read by boot code - don't worry about its value)
        dc.b "J               "                                 ; I/O support
        dc.l $00000000                                          ; Start address of ROM
        dc.l RomEnd                                             ; End address of ROM
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

EntryPoint:
.loop:
        nop
        nop
        bra.s   .loop
 
HBlankInterrupt:
        rte

VBlankInterrupt:
        rte

Exception:
        rte

RomEnd:    ; Very last line, end of ROM address
        END
