; ------------------------------------------------------------------
; Application specific code
; ------------------------------------------------------------------

        INCLUDE "hardware.i"
        INCLUDE "SGDK.i"

; ------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------

USE_SGDK_RANDOM EQU 1

; From soundfx.h (generate by rescomp)
; TODO: Modify rescomp to add these labels to the generated .s file
hat1_13k_size   = 9216
snare1_13k_size = 8960
cri_13k_size    = 7936

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
        ; TODO: Play periodically or on button press maybe
        ; XGM2_playPCM(snare1_13k, sizeof(snare1_13k), SOUND_PCM_CH1)
        move.l  #SOUND_PCM_CH1,-(a7)    ; const SoundPCMChannel channel
        move.l  #snare1_13k_size,-(a7)  ; const u32 len
        move.l  #snare1_13k,-(a7)       ; const u8* sample
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
        ; Increment frame index
        lea     FrameIndex(a5),a0

        ; call C function from our custom tools.c file
        IFD __GNUC__
        ; GCC calling conventinons
        ; - Functions have their arguments pushed onto the stack before a call, last argument first. (This means within the functions, the arguments are sequential in memory in the order of the function signature.)
        ; - Every function trashes a0, a1, d0, and d1. All other registers, including the stack pointer, are preserved and will leave the function the same way they entered it.
        ; - Return values are passed in d0.
        ; See https://bumbershootsoft.wordpress.com/2018/03/10/variations-on-the-68000-abi/ for more info
        move.l  a0,-(a7)        ; push arg: frame index pointer
        jsr     IncLong         ; call C function from our custom tools.c file
        addq.l  #4,a7           ; restore stack
        lea     FrameIndex(a5),a0       ; a0 may have been trashed by the C function

        ELSE ; VBCC
        jsr     @IncLong        ; TODO: Try to configure VBCC to strip @ prefix

        ENDIF

        move.l  (a0),d0         ; frame index

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
        rte

Exception::
        rte

;---------------------------------------------------------------------------------------------
; Initialised data section
;---------------------------------------------------------------------------------------------
        SECTION DATA,DATA

        dc.l   $11111111

;---------------------------------------------------------------------------------------------
; Uninitialised data section
;---------------------------------------------------------------------------------------------
        SECTION BSS,BSS

; n.b. Can't use fixed (ORG) address for variables, because have to co-exist in RAM with rw data
; from other modules (e.g. test.s and libmd.a) in the final linked image 
Variables:
        dcb.b   Vars_sizeof
