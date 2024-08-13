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

;---------------------------------------------------------------------------------------------

EntryPoint:
        move.w  #$2700,sr       ; supervisor mode, disable interrupts

        ; Branch straight to main if this is a soft reset
        tst.w   $A10008         ; #TODO: Should this be a word or longword test?
        bne     Main
        tst.w   $A1000C
        bne     Main

        ; Clear RAM. 64 KiB of general purpose 68000 RAM at address FF0000-FFFFFF
        moveq   #0,d0           ; Clear val and starting address         ; TEST: TODO: Change back to 0
        movea.l d0,a0           ; Zero from address 0 backwards with pre-decrement
        move.l #$4000-1,d1      ; Clearing 64k's worth of longwords (minus 1, for dbra loop
.clear:
        move.l d0,-(a0)
        dbra d1,.clear

        ; Set TMSS Trade Mark Security Signature on second revision hardware
        move.b  $A10001,d0      ; Move Megadrive hardware version to d0
        andi.b  #$0F,d0         ; The version is stored in last four bits, so mask it with 0F
        beq     .skip           ; If version is equal to 0, skip TMSS signature
        move.l  #'SEGA',$A14000 ; Move the string "SEGA" to 0xA14000
.skip:

        ; Init Z80
        move.w  #$0100,$A11100  ; Request access to the Z80 bus, by writing 0x0100 into the BUSREQ port
        move.w  #$0100,$A11200  ; Hold the Z80 in a reset state, by writing 0x0100 into the RESET port
.wait:
        btst    #0,$A11100      ; Test bit 0 of A11100 to see if the 68k has access to the Z80 bus yet
        bne     .wait

        ; write Z80 program to its RAM
        ; The Z80 has 8 KiB of RAM at address 0xA00000
        move.l  #Z80InitData,a0 ; Load address of data into a0
        move.l  #$A00000,a1     ; Copy Z80 RAM address to a1
        move.l  #Z80_INIT_DATA_SIZE_BYTES-1,d0         ; -1 for dbra
.copyZ80:
        move.b  (a0)+,(a1)+
        dbra    d0,.copyZ80
        
        move.w  #$0000,$A11200  ; Release reset state
        move.w  #$0000,$A11100  ; Release control of bus
        
        ; Init PSG
        ; TODO: Which audio chip is this?
        move.l  #PSGInitData,a0
        move.l  #PSG_INIT_DATA_SIZE_BYTES-1,d0       ; -1 for dbra
.copyPSG:
        move.b  (a0)+,$C00011    ; Copy data to PSG RAM
        dbra    d0,.copyPSG
 
        ; TODO: What about initialising the other audio chip?

        ; Init VDP
        move.l  #VDPRegInitData,a0
        move.w  #VDP_REG_DATA_SIZE_BYTES-1,d0;
        move.l  #$00008000,d1   ; 'Set register 0' command (and clear the rest of d1 ready)
.copyVDP:
        move.b  (a0)+,d1        ; Move register value to lower byte of d1
        move.w  d1,$C00004      ; Write command and value to VDP control port
        add.w   #$100,d1        ; Increment register #
        dbra    d0,.copyVDP

        ; Init controller ports
        ; Set IN I/O direction, interrupts off, on all ports
        move.b  #$00,$A10009 ; Controller port 1 CTRL
        move.b  #$00,$A1000B ; Controller port 2 CTRL
        move.b  #$00,$A1000D ; EXP port CTRL

        ; Deliberate fallthrough to Main
Main:
        ; TODO: Do something interesting!
        bra.s   Main
 
HBlankInterrupt:
        rte

VBlankInterrupt:
        rte

Exception:
        rte

;---------------------------------------------------------------------------------------------
; Z80 machine code from https://blog.bigevilcorporation.co.uk/2012/03/09/sega-megadrive-3-awaking-the-beast/
; TODO: This doesn't look right in the MAME disassembly. What is it doing?
;
Z80InitData:
        dc.w $af01, $d91f
        dc.w $1127, $0021
        dc.w $2600, $f977
        dc.w $edb0, $dde1
        dc.w $fde1, $ed47
        dc.w $ed4f, $d1e1
        dc.w $f108, $d9c1
        dc.w $d1e1, $f1f9
        dc.w $f3ed, $5636
        dc.w $e9e9, $8104
        dc.w $8f01
Z80_INIT_DATA_SIZE_BYTES EQU *-Z80InitData

; From https://blog.bigevilcorporation.co.uk/2012/03/09/sega-megadrive-3-awaking-the-beast/
; TODO: What is this?
PSGInitData:
        dc.w $9fbf, $dfff
PSG_INIT_DATA_SIZE_BYTES EQU *-PSGInitData

; From https://blog.bigevilcorporation.co.uk/2012/03/09/sega-megadrive-3-awaking-the-beast/
VDPRegInitData:
        dc.b $20 ; 0: Horiz. interrupt on, plus bit 2 (unknown, but docs say it needs to be on)
        dc.b $74 ; 1: Vert. interrupt on, display on, DMA on, V28 mode (28 cells vertically), + bit 2
        dc.b $30 ; 2: Pattern table for Scroll Plane A at 0xC000 (bits 3-5)
        dc.b $40 ; 3: Pattern table for Window Plane at 0x10000 (bits 1-5)
        dc.b $05 ; 4: Pattern table for Scroll Plane B at 0xA000 (bits 0-2)
        dc.b $70 ; 5: Sprite table at 0xE000 (bits 0-6)
        dc.b $00 ; 6: Unused
        dc.b $00 ; 7: Background colour - bits 0-3 = colour, bits 4-5 = palette
        dc.b $00 ; 8: Unused
        dc.b $00 ; 9: Unused
        dc.b $00 ; 10: Frequency of Horiz. interrupt in Rasters (number of lines travelled by the beam)
        dc.b $08 ; 11: External interrupts on, V/H scrolling on
        dc.b $81 ; 12: Shadows and highlights off, interlace off, H40 mode (40 cells horizontally)
        dc.b $34 ; 13: Horiz. scroll table at 0xD000 (bits 0-5)
        dc.b $00 ; 14: Unused
        dc.b $00 ; 15: Autoincrement off
        dc.b $01 ; 16: Vert. scroll 32, Horiz. scroll 64
        dc.b $00 ; 17: Window Plane X pos 0 left (pos in bits 0-4, left/right in bit 7)
        dc.b $00 ; 18: Window Plane Y pos 0 up (pos in bits 0-4, up/down in bit 7)
        dc.b $00 ; 19: DMA length lo byte
        dc.b $00 ; 20: DMA length hi byte
        dc.b $00 ; 21: DMA source address lo byte
        dc.b $00 ; 22: DMA source address mid byte
        dc.b $00 ; 23: DMA source address hi byte, memory-to-VRAM mode (bits 6-7)
VDP_REG_DATA_SIZE_BYTES EQU *-VDPRegInitData

;---------------------------------------------------------------------------------------------

RomEnd:    ; Very last line, end of ROM address
        END
