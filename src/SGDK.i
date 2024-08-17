; ------------------------------------------------------------------
; SGDK constants
; TODO: Can the toolchain convert C constants be converted to assembler?
; ------------------------------------------------------------------

SOUND_PAN_CENTER        EQU $C0 ; See SGDK\inc\snd\sound.h #TODO: Is it possible to convert the SoundPanning enum values to assembler?
SOUND_PCM_RATE_8000     EQU 5   ; See SGDK\inc\snd\pcm\snd_pcm.h #TODO: Is it possible to convert the SoundPcmSampleRate enum values to assembler?

Z80_DRIVER_XGM2         EQU 5   ; See SGDK\inc\z80_ctrl.h
