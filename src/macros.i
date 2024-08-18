
; Standard calling convention for 68000
; - Functions have their arguments pushed onto the stack before a call, last argument first. 
;   This means within the function code, the arguments are sequential in memory in the order of the function signature.
; - Every function trashes a0, a1, d0, and d1. All other registers, including the stack pointer, are preserved and will leave the function the same way they entered it.
; - Return values are passed in d0.
; See https://bumbershootsoft.wordpress.com/2018/03/10/variations-on-the-68000-abi/ for more info
;
; VBCC symbol names for functions using the standard ABI have underscore _ prefix.
; TODO: Is there a way to remove the VBCC standard ABI _ prefix?
;
STDCALL MACRO   ;FunctionName
        IFD __GNUC__
        jsr     \1
                ELSE
        jsr     _\1
                ENDIF
        ENDM

;
; VBCC symbol names for functions using the Fastcall-ABI have the '@'-prefix.
;
FASTCALL MACRO   ;FunctionName
        IFD __GNUC__
        FAIL "FASTCALL not supported by GCC"
        ELSE
        jsr     @\1
        ENDIF
        ENDM
