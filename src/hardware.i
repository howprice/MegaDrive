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
; Hardware macros
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
