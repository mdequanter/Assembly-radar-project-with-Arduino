;---------------
; Assembly Code
;---------------
#define __SFR_OFFSET 0x00
#include "avr/io.h"
;------------------------
.global start
;------------------------
start:
    LDI   R20, 0xFF
    OUT   DDRB, R20   ;set port B as o/p
    CBI   DDRD, 2     ;set pin PB2 as i/p
;----------------------------------------------------------------
    LDI   R18, 0xFC   ;byte for o/p
    LDI   R19, 0      ;byte to clear port D
agn:SBIS  PIND, 2     ;check pin PB2, skip next instruction if 0
    RJMP  outputByte  ;jump to label if button is pressed
    RJMP  agn         ;go back & check button
;----------------------------------------------------------------
outputByte:
    SBI   PORTB, 4
    RCALL myDelay     
    CBI   PORTB, 4    
    SBI   PORTB, 3
    RCALL myDelay
    CBI   PORTB, 3    
    SBI   PORTB, 2
    RCALL myDelay
    CBI   PORTB, 2    
    RJMP  agn         ;go back & check button
;----------------------------------------------------------------
myDelay:              ;nested loop subroutine (max delay 3.11s)
    LDI   R20, 255    ;outer loop counter 
l1: LDI   R21, 255    ;mid loop counter
l2: LDI   R22, 50    ;inner loop counter to give 0.25s delay
l3: DEC   R22         ;decrement inner loop
    BRNE  l3          ;loop if not zero
    DEC   R21         ;decrement mid loop
    BRNE  l2          ;loop if not zero
    DEC   R20         ;decrement outer loop
    BRNE  l1          ;loop if not zero
    RET               ;return to caller
;----------------------------------------------------------------
