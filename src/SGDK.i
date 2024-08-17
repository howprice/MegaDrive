; ------------------------------------------------------------------
; SGDK constants
; TODO: Can the toolchain convert C constants be converted to assembler?
; ------------------------------------------------------------------

SOUND_PAN_CENTER        EQU $C0 ; See SGDK\inc\snd\sound.h #TODO: Is it possible to convert the SoundPanning enum values to assembler?
SOUND_PCM_RATE_8000     EQU 5   ; See SGDK\inc\snd\pcm\snd_pcm.h #TODO: Is it possible to convert the SoundPcmSampleRate enum values to assembler?

Z80_DRIVER_XGM2         EQU 5   ; See SGDK\inc\z80_ctrl.h

; SoundPCMChannel enum. See sgdk\inc\snd\sound.h
SOUND_PCM_CH_AUTO = -1  ; auto-select
SOUND_PCM_CH1 = 0	; channel 1
SOUND_PCM_CH2 = 2	; channel 2
SOUND_PCM_CH3 = 2	; channel 3
SOUND_PCM_CH4 = 3	; channel 4
