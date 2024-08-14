; ------------------------------------------------------------------
; Hardware equates
; ------------------------------------------------------------------

PALETTE_COLOUR_COUNT    EQU     16
PALETTE_SIZE_LONGWORDS  EQU     PALETTE_COLOUR_COUNT/2

VDP_DATA_PORT           EQU     $C00000
VDP_CONTROL_PORT        EQU     $C00004

RAM_ADDRESS             EQU     $FF0000
RAM_SIZE_BYTES          EQU     $10000

; ------------------------------------------------------------------
; Handy macros
; ------------------------------------------------------------------

; \1 register number 0-23 (5 bits)
; \2 data (8 bits)
SET_VDP_REG     MACRO
                move.w    #$8000!((\1)<<8)!((\2)&$FF),VDP_CONTROL_PORT  ; TODO: (\1)&$1F ?
                ENDM

; Set CRAM write address 0x00-0x7F (128 bytes = 4 palettes of 16 colours at 1 word per colour)
; \1 address (6 bits)
SET_CRAM_WRITE_ADDRESS  MACRO
                        move.l    #($C0<<24)!((\1)<<16),VDP_CONTROL_PORT
                        ENDM

; ------------------------------------------------------------------
; Variables
; ------------------------------------------------------------------

                RSRESET
FrameIndex:     RS.L            1
Vars_sizeof:    RS.W            1

        SECTION ROM_HEADER,DATA

; ------------------------------------------------------------------
; Sega Megadrive ROM header
; ------------------------------------------------------------------
RomHeader:
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
        dc.b "MEGADRIVE DEMO                                  " ; Domestic name
        dc.b "MEGADRIVE DEMO                                  " ; International name
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

;	PRINTT "ROM header size (bytes):"
;	PRINTV *-RomHeader
        ASSERT *-RomHeader==512,"Expect ROM header to be 512 bytes"

;---------------------------------------------------------------------------------------------

        SECTION CODE,CODE

EntryPoint:
        move.w  #$2700,sr       ; supervisor mode, disable interrupts

        ; Branch straight to main if this is a soft reset
        tst.w   $A10008         ; #TODO: Should this be a word or longword test?
        bne     Main
        tst.w   $A1000C
        bne     Main

        ; Clear all RAM. FF0000-FFFFFF (64 KiB)
        ; n.b. Do not move this into subroutine because the stack will also be cleared!
        ; Taks care: This is responsibe for clearing BSS too, so systems should initialise their own BSS vars.
        moveq   #0,d0           ; Clear val and starting address
        movea.l d0,a0           ; Zero from address 0 backwards with pre-decrement
        move.l  #(RAM_SIZE_BYTES/4)-1,d1     ; Longword count, -1 for dbra
.clear:
        move.l  d0,-(a0)
        dbra    d1,.clear

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
        ; Write a palette to the VDP
        ; CRAM (Colour RAM) is 128 bytes = 4 palettes of 16 colours at 1 word per colour

        SET_VDP_REG     15,$02  ; Set autoincrement to increment by 1 word (2 bytes). This number is added automatically after ram access.

        ; Set CRAM address 0 for palette zero
        SET_CRAM_WRITE_ADDRESS  $0000

        lea     Palette,a0
        move.l  #PALETTE_SIZE_LONGWORDS-1,d0 ; copy 2 colours (1 longword) at a time, -1 for dbra
.paletteLoop:
        move.l  (a0)+,VDP_DATA_PORT     ; note autoincrement is set to 2
        dbra    d0,.paletteLoop

        ; Register 7 is the background colour. Bits 5:4 palette index, bits 3:0 colour index
        SET_VDP_REG     7,$08  ; Set background colour to palette 0, colour 8

        lea     Variables,a5

        ; Enable vertical blanking interrupt
        move.w   #$2000,sr      ; enable interrupts at CPU level. Vertical interrupt is 68000 level 6
        SET_VDP_REG     1,$64   ; Enable V interrupt at system level

.mainLoop: 
        bra.s   .mainLoop
        
HBlankInterrupt:
        rte

VBlankInterrupt:
        ; Cycle background colour through palette 0
        lea     FrameIndex(a5),a0
        move.l  (a0),d0
        lsr.w   #4,d0           ; cycle every 16 frames
        andi.w  #$f,d0          ; 16 colours per palette, palette 0
        ori.w   #$8700,d0       ; set register 7, background colour
        move.w  d0,VDP_CONTROL_PORT
        IF 1
        jsr     @IncLong         ; can't use bsr, because symbol not defined yet
        ELSE
        addq.l  #1,(a0)
        ENDIF
        rte

Exception:
        rte

;---------------------------------------------------------------------------------------------
; TEST: Calling a function from libmd causes the linker to pull in the each transient dependency
; from the library, increasing the ROM size. This is a test to see how much it increases by.
;       jsr     random         ; Increasees ROM size by 854C0 bytes
        jsr     XGM_loadDriver ; Increasees ROM size by 85590 bytes

;---------------------------------------------------------------------------------------------
; Z80 machine code from https://blog.bigevilcorporation.co.uk/2012/03/09/sega-megadrive-3-awaking-the-beast/
; TODO: This doesn't look right in the MAME disassembly. What is it doing?
; Looks like it is originally from here, with explaination: https://bumbershootsoft.wordpress.com/2018/03/02/the-sega-genesis-startup-code/
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
        dc.b $04 ; 0: Mode set register 1. Bit 4: IE1 Horizontal interrupt enable (68000 LV 4). Bit 2 must be set, Bit 1: M3 HV. counter stop 1=disable. Others zero
        dc.b $44 ; 1: Mode set register 2. Bit 6: Display enable. display on, DMA off, V28 mode (28 cells vertically), + bit 2
        dc.b $30 ; 2: Pattern table for Scroll Plane A at 0xC000 (bits 3-5)
        dc.b $40 ; 3: Pattern table for Window Plane at 0x10000 (bits 1-5)
        dc.b $05 ; 4: Pattern table for Scroll Plane B at 0xA000 (bits 0-2)
        dc.b $70 ; 5: Sprite table at 0xE000 (bits 0-6)
        dc.b $00 ; 6: Unused
        dc.b $00 ; 7: Background colour - bits 0-3 = colour, bits 4-5 = palette
        dc.b $00 ; 8: Unused
        dc.b $00 ; 9: Unused
        dc.b $00 ; 10: Frequency of Horiz. interrupt in Rasters (number of lines travelled by the beam)
        dc.b $00 ; 11: Mode set register 3. Disable external interrupts on, V/H scrolling on
        dc.b $81 ; 12: Mode set register 4. Shadows and highlights off, interlace off, H40 mode (40 cells horizontally)
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

; Palette is 16 colours at 1 word per colour = 32 bytes
; Three bits per channel: Binary: 0 0 0 0  B2 B1 B0 0  G2 G1 G0 0  R2 R1 R0 0
; Least significant bit of each channel is unused
Palette:
        dc.w $0000 ; Colour 0 - Transparent
        dc.w $000E ; Colour 1 - Red
        dc.w $00E0 ; Colour 2 - Green
        dc.w $0E00 ; Colour 3 - Blue
        dc.w $0000 ; Colour 4 - Black
        dc.w $0EEE ; Colour 5 - White
        dc.w $00EE ; Colour 6 - Yellow
        dc.w $008E ; Colour 7 - Orange
        dc.w $0E0E ; Colour 8 - Pink
        dc.w $0808 ; Colour 9 - Purple
        dc.w $0444 ; Colour A - Dark grey
        dc.w $0888 ; Colour B - Light grey
        dc.w $0EE0 ; Colour C - Turquoise
        dc.w $000A ; Colour D - Maroon
        dc.w $0600 ; Colour E - Navy blue
        dc.w $0060 ; Colour F - Dark green

;---------------------------------------------------------------------------------------------

RomEnd:    ; Very last line, end of ROM address
; TODO: Assert that ROM does not exceed maximum size

;---------------------------------------------------------------------------------------------
; Initialised data section
        SECTION DATA,DATA

        dc.l   $11111111

;---------------------------------------------------------------------------------------------
; Uninitialisd data section
        SECTION BSS,BSS

; n.b. Can't use fixed (ORG) address for variables, because have to co-exist in RAM with rw data
; from other modules (e.g. test.s and libmd.a) in the final linked image 
Variables:
        dcb.b   Vars_sizeof
;---------------------------------------------------------------------------------------------

        END
