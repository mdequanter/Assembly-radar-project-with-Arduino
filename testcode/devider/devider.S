;------------------------
; Assembly Code
;------------------------
#define __SFR_OFFSET 0x00
#include "avr/io.h"
;------------------------
.global HC_SR04_sensor
.global init_serial
.global print_msg


LDI   R27, 20                   ; store MinServoPos
LDI   R19, 0



;===============================================================
;Serial communication:
;------------------------
init_serial:
    CLR   R24
    STS   UCSR0A, R24               ;clear UCSR0A register
    STS   UBRR0H, R24               ;clear UBRR0H register
    LDI   R24, 103                  ;& store in UBRR0L 103 value
    LDI R29, 0
    LDI R30, 2
    LDI R31, 0
    STS   UBRR0L, R24               ;to set baud rate 9600
    LDI   R24, 1<<RXEN0 | 1<<TXEN0  ;enable RXB & TXB
    STS   UCSR0B, R24
    LDI   R24, 1<<UCSZ00 | 1<<UCSZ01;asynch, no parity, 1 stop, 8 bits
    STS   UCSR0C, R24
    RET

;------------------------------------------
print_cr:
    LDI   R18, 0x0A
    STS   UDR0, R18                 ;print newline on serial monitor
    LDI   R18, 0x0D
    STS   UDR0, R18                 ;print carriage return on serial monitor
    CLR   R18
    RET

print_dot:
  LDI   R18, 0x2E
  STS   UDR0, R18
  CLR   R18
  RET

print_pipe:
  LDI   R18, 0x7C
  STS   UDR0, R18
  CLR   R18
  RET


print_comma:
  LDI   R18, 0x2C
  STS   UDR0, R18
  CLR   R18
  RET



;-------------------------------------------------------------------------
print_msg:
    LDI   R23, 48         ;constants used to get ASCII values
    LDI   R24, 7          ;for chars 0-->9 & A-->F
    
    
;--------------------------------------------------------------------
l1: LDS   R17, UCSR0A
    SBRS  R17, UDRE0                ;test data buffer if data can be sent
    RJMP  l1
    ADD   R18, R23                  ;add 48 to byte to get ASCII char 0 to 9
    STS   UDR0, R18                 ;send char in R18 to serial monitor
    CLR   R18
;--------------------------------------------------------------------
ext:RCALL delay_ms
    RET
;------------------------------------------------------------------------
message:
    .ascii "Prog!" ;even number of characters!!!
    .byte 10,13,0  ; 10,13  newline and cariage return.
;------------------------------------------------------------------------

;===============================================================
HC_SR04_sensor:
;--------------
    SBI   DDRB, 1         ;pin PB1 as o/p (Trigger)
    CBI   DDRB, 0         ;pin PB0 as i/p (Echo)
    ;-----------------------------------------------------------
agn:SBI   PORTB, 1
    RCALL delay_timer0
    CBI   PORTB, 1        ;send 10us high pulse to sensor
    ;-----------------------------------------------------------
    RCALL echo_PW         ;compute Echo pulse width count
    ;-----------------------------------------------------------
    RCALL byte2decimal    ;covert & display on MAX7219
    ;-----------------------------------------------------------
    RCALL delay_ms
    RJMP  agn
;===============================================================
echo_PW:
;-------
    LDI   R20, 0b00000000
    STS   TCCR1A, R20     ;Timer 1 normal mode
    LDI   R20, 0b11000101 ;set for rising edge detection &
    STS   TCCR1B, R20     ;prescaler=1024, noise cancellation ON
    ;-----------------------------------------------------------
l1Echo: IN    R21, TIFR1
    SBRS  R21, ICF1
    RJMP  l1Echo              ;loop until rising edge is detected
    ;-----------------------------------------------------------
    LDS   R16, ICR1L      ;store count value at rising edge
    ;-----------------------------------------------------------
    OUT   TIFR1, R21      ;clear flag for falling edge detection
    LDI   R20, 0b10000101
    STS   TCCR1B, R20     ;set for falling edge detection
    ;-----------------------------------------------------------
l2Echo: IN    R21, TIFR1
    SBRS  R21, ICF1
    RJMP  l2Echo              ;loop until falling edge is detected
    ;-----------------------------------------------------------
    LDS   R28, ICR1L      ;store count value at falling edge
    ;-----------------------------------------------------------
    SUB   R28, R16        ;count diff R28 = R28 - R16
    OUT   TIFR1, R21      ;clear flag for next sensor reading
    RET
;==============================================================

rServ:
      LDI R19, 0
      LDI R27, 0
      LDI R29, 0
      LDI R30, 2  ; starting from 20 degrees
      LDI R31, 0
      RET


secCounter:
      INC R19
      RJMP skip27


       

byte2decimal:
;------------

CPI R27,100
BRPL secCounter

skip27:

CPI R19,45    ;  100 + 65 degrees
BRPL rServ


; Increment the counter
inc r31
inc R27




; Check if we need to carry over to the next digit
cpi r31, 10
brne skip_carry_r31
ldi r31, 0
inc r30

skip_carry_r31:
cpi r30, 10
brne skip_carry_r30
ldi r30, 0
inc r29

skip_carry_r30:


MOV R18 , R29
RCALL print_msg
MOV R18 , R30
RCALL print_msg
MOV R18 , R31
RCALL print_msg
RCALL print_comma
      

tmin: CPI R28, 10
      BRGE t20
      MOV R18 , R28
      RCALL print_msg
      RCALL print_dot
      RJMP endp

t20:  CPI R28, 20
      BRGE t30
      LDI R18 , 1
      RCALL print_msg
      SUBI  R28, 10
      MOV R18, R28
      RCALL print_msg
      RCALL print_dot
      RJMP endp
      
t30:  CPI R28, 30
      BRGE t40
      LDI R18 , 2
      RCALL print_msg
      SUBI  R28, 20
      MOV R18, R28
      RCALL print_msg
      RCALL print_dot
      RJMP endp

t40:  CPI R28, 40
      BRGE t50
      LDI R18 , 3
      RCALL print_msg
      SUBI  R28, 30
      MOV R18, R28
      RCALL print_msg
      RCALL print_dot
      RJMP endp

t50:  CPI R28, 50
      BRGE endp
      LDI R18 , 4
      RCALL print_msg
      SUBI  R28, 40
      MOV R18, R28
      RCALL print_msg
      RCALL print_dot
      RJMP endp

      

endp:
    ;RCALL delay_sec
    RET
;===============================================================
;delay subroutines
;===============================================================
delay_timer0:             ;10 usec delay via Timer 0
;------------
    CLR   R20
    OUT   TCNT0, R20      ;initialize timer0 with count=0
    LDI   R20, 20
    OUT   OCR0A, R20      ;OCR0 = 20
    LDI   R20, 0b00001010
    OUT   TCCR0B, R20     ;timer0: CTC mode, prescaler 8
    ;-----------------------------------------------------------
l0: IN    R20, TIFR0      ;get TIFR0 byte & check
    SBRS  R20, OCF0A      ;if OCF0=1, skip next instruction
    RJMP  l0              ;else, loop back & check OCF0 flag
    ;-----------------------------------------------------------
    CLR   R20
    OUT   TCCR0B, R20     ;stop timer0
    ;-----------------------------------------------------------
    LDI   R20, (1<<OCF0A)
    OUT   TIFR0, R20      ;clear OCF0 flag
    RET
;===============================================================
delay_ms:
;--------
    LDI   R21, 50
l6: LDI   R22, 50
l7: LDI   R23, 2
l8: DEC   R23
    BRNE  l8
    DEC   R22
    BRNE  l7
    DEC   R21
    BRNE  l6
    RET
;------------------------------------------------------------------------
delay_sec:                          ;3s delay
    LDI   R20, 255
l4Delay_Sec: LDI   R21, 255
l5Delay_Sec: LDI   R22, 255
l6Delay_Sec: DEC   R22
    BRNE  l6Delay_Sec
    DEC   R21
    BRNE  l5Delay_Sec
    DEC   R20
    BRNE  l4Delay_Sec
    RET
