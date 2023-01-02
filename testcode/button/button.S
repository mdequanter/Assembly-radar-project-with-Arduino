;------------------------------------------
; Assembly Code: RGB LED ON/OFF via Buttons
; LED connected to pin D12
; Button connected to D2

;------------------------------------------
#define __SFR_OFFSET 0x00
#include "avr/io.h"
;------------------------
.global start
.global btnLED
;=============================================================================
start:
    SBI   DDRB, 4             ;set PB4 (pin D12 as o/p - red LED)
    CBI   DDRD, 2             ;clear PD2 (pin D02 as i/p - red button)
    RET                       ;return to setup()
;-----------------------------------------------------------------------------
btnLED:
    SBIS  PIND, 2             ;skip next statement if red button not pressed
    RJMP  redledON            ;jump to label redledON
    RJMP  btnLED              ;return to label btnLED
;-----------------------------------------------------------------------------
redledON:
    LDI   R21, 2             ;initial value of counter R21
redagain:    
    SBI   PORTB, 4            ;turn ON red LED
    RCALL myDelay             ;call subroutine myDelay
    CBI   PORTB, 4            ;turn OFF red LED
    RCALL myDelay             ;call subroutine myDelay
    SUBI  R21, 1              ;decrement counter by 1
    BRNE  redagain            ;loop if counter not zero
    RJMP  btnLED              ;return to label btnLED
;-----------------------------------------------------------------------------
.equ  delayVal, 5000         ;equate delayVal with initial count value
;--------------------         ;for inner loop
myDelay:
    LDI   R20, 90             ;initial count value for outer loop
outerLoop:
    LDI   R30, lo8(delayVal)  ;low byte of delayVal in R30
    LDI   R31, hi8(delayVal)  ;high byte of delayVal in R31
innerLoop:
    SBIW  R30, 1              ;subtract 1 from 16-bit value in R31, R30
    BRNE  innerLoop           ;jump if countVal not equal to 0
    ;--------------
    SUBI  R20, 1              ;subtract 1 from R20
    BRNE  outerLoop           ;jump if R20 not equal to 0
;=============================================================================
