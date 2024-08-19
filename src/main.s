; ------------------------------------------------------------------
; Application specific code
; ------------------------------------------------------------------

        INCLUDE "macros.i"
        INCLUDE "hardware.i"
        INCLUDE "SGDK.i"

; ------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------

USE_SGDK_RANDOM EQU 1

; ------------------------------------------------------------------
; Variable data structure definition
; ------------------------------------------------------------------

                RSRESET
FrameIndex:     RS.L            1
Vars_sizeof:    RS.W            1

; ------------------------------------------------------------------

        SECTION CODE,CODE

; n.b. Use double colon to make the label externally visible to the linker (see VASM docs)
main::
        ; when calling a C function, all args are longwords and are pushed in reverse order to C function signature

        ; Z80_loadDriver(Z80_DRIVER_XGM2, true);
        move.l  #1,-(a7)                ; push arg: bool waitReady #TODO: Why do we have to push a longword for a bool value?
        move.l  #Z80_DRIVER_XGM2,-(a7)  ; push arg: const u16 driver
        jsr     Z80_loadDriver          ; void Z80_loadDriver(const u16 driver, const bool waitReady);
        addq.l  #2*4,a7                 ; restore stack

        ; Workaround for SGDK bug: https://github.com/Stephane-D/SGDK/issues/345
        ; Need to manually call XGM2_setMusicTempo after loading the driver (even though it is called internally)
        ; XGM2_setMusicTempo(60);
        move.l  #60,-(a7)               ; push arg: u16 value
        jsr     XGM2_setMusicTempo      ; void XGM2_setMusicTempo(const u16 value);
        addq.l  #4,a7                   ; restore stack

        ; play track
        ; XGM2_play(tara_xgm2)
        move.l  #tara_xgm2,-(a7)        ; const u8* song
        jsr     XGM2_play               ; XGM2_play(const u8 *song);
        addq.l  #1*4,a7                 ; restore stack

        ; If necessary, multiple tracks can be played with XGM2_load(const u8 *song) and XGM2_playTrack(const u16 track)

        ; Play sound effect
        ; XGM2_playPCM(snare1_13k, sizeof(snare1_13k), SOUND_PCM_CH1)
        move.l  #SOUND_PCM_CH1,-(a7)    ; const SoundPCMChannel channel
        move.l  #cri_13k_size,-(a7)     ; const u32 len. Symbol exported from sample_data.o and resolved by linker
        move.l  #cri_13k,-(a7)          ; const u8* sample. Symbol exported from sample_data.o and resolved by linker
        jsr     XGM2_playPCM            ; void XGM2_playPCM(const u8 *sample, const u32 len, const SoundPCMChannel channel);
        adda.l  #3*4,a7                 ; restore stack

        lea     Variables,a5            ; Application variables bases address in A5 throughout

        ; Enable vertical blanking interrupt
        move.w   #$2000,sr      ; enable interrupts at CPU level. Vertical interrupt is 68000 level 6
        SET_VDP_REG     1,$64   ; Enable V interrupt at system level

.mainLoop: 
        bra.s   .mainLoop
        
;---------------------------------------------------------------------------------------------
; n.b. Use double colon to make the label externally visible to the linker (see VASM docs)
HBlankInterrupt::
        rte

;---------------------------------------------------------------------------------------------
; n.b. Use double colon to make the label externally visible to the linker (see VASM docs)
VBlankInterrupt::

        movem.l d0-d1/a0-a1,-(a7)       ; save registers

        ; Increment frame index
        lea     FrameIndex(a5),a0

        ; call C function from our custom tools.c file
        ; See STDCALL macro comments
        move.l  a0,-(a7)                ; push arg: frame index pointer
        STDCALL IncLong                 ; call C function from our custom tools.c file
        addq.l  #4,a7                   ; restore stack
        lea     FrameIndex(a5),a0       ; a0 may have been trashed by the C function
        move.l  (a0),d0                 ; frame index

        IF USE_SGDK_RANDOM ; cycle using random() C func from libmd.a
        ; change BG colour every 16 frames
        andi.w  #$f,d0
        bne.s   .skip

        ; Cycle background colour through palette 0
        jsr     random          ; Call SGDK function (tools.c). Returns random number in D0. Symbol resolved by linker
        
        ELSE ; cycle using frame index
        lsr.w   #4,d0           ; cycle every 16 frames
        
        ENDIF

        andi.w  #$f,d0          ; 16 colours per palette, palette 0
        ori.w   #$8700,d0       ; set register 7, background colour
        move.w  d0,VDP_CONTROL_PORT
.skip        

        movem.l (a7)+,d0-d1/a0-a1       ; restore registers
        rte

Exception::
        rte

;---------------------------------------------------------------------------------------------
; Constant read-only data can live in the CODE section
; This will be placed in the ROM and remain in the ROM
;---------------------------------------------------------------------------------------------
ConstantData::
        dc.l   $11111111

;---------------------------------------------------------------------------------------------
; Initialised read/write data section
; This will be placed in the ROM and copied into RAM at startup
;---------------------------------------------------------------------------------------------
        SECTION DATA,DATA
MainTestData::
        dc.l   $22222222

;---------------------------------------------------------------------------------------------
; Uninitialised read/write data section
; This takes up no space in the rom. Linker will allocate space for this in RAM. It will be 
; zeroed out at startup.
;---------------------------------------------------------------------------------------------
        SECTION BSS,BSS

; n.b. Can't use fixed (ORG) address for variables, because have to co-exist in RAM with rw data
; from other modules (e.g. test.s and libmd.a) in the final linked image.
; Use :: to make this an externally visible symbol, so can see its address in the linker map file.
Variables::
        dcb.b   Vars_sizeof
