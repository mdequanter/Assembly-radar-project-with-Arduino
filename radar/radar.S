;------------------------
; Assembly Code
;------------------------
#define __SFR_OFFSET 0x00
#include "avr/io.h"
;------------------------
.global servo_motor
.global HC_SR04_sensor
.global init_serial


;===============================================================
;Serial communication:
;------------------------
init_serial:
    CLR   R24
    STS   UCSR0A, R24               ;clear UCSR0A register
    STS   UBRR0H, R24               ;clear UBRR0H register
    LDI   R24, 103                  ;& store in UBRR0L 103 value
    STS   UBRR0L, R24               ;to set baud rate 9600
    LDI   R24, 1<<RXEN0 | 1<<TXEN0  ;enable RXB & TXB
    STS   UCSR0B, R24
    LDI   R24, 1<<UCSZ00 | 1<<UCSZ01;asynch, no parity, 1 stop, 8 bits
    STS   UCSR0C, R24
    RET
;-------------------------------------------------------------------------
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


print_cr:
    LDI   R18, 0x0A
    STS   UDR0, R18                 ;print newline on serial monitor
    LDI   R18, 0x0D
    STS   UDR0, R18                 ;print carriage return on serial monitor
    CLR   R18
    RET

    
print_msg:
    LDI   R23, 48         ;constants used to get ASCII values
    
;--------------------------------------------------------------------
l1: LDS   R17, UCSR0A
    SBRS  R17, UDRE0                ;test data buffer if data can be sent
    RJMP  l1
    ADD   R18, R23                  ;add 48 to byte to get ASCII char 0 to 9
    STS   UDR0, R18                 ;send char in R18 to serial monitor
    CLR   R18
;--------------------------------------------------------------------
ext:RCALL delay_20ms
    RET

HC_SR04_sensor:
;--------------
    SBI   DDRB, 1         ;pin PB1 as o/p (Trigger)
    CBI   DDRB, 0         ;pin PB0 as i/p (Echo)
    ;-----------------------------------------------------------
agn:SBI   PORTB, 1
    RCALL delay_timer0
    CBI   PORTB, 1       ;send 10us high pulse to sensor
    ;-----------------------------------------------------------
    RCALL echo_PW         ;compute Echo pulse width count
    ;-----------------------------------------------------------
    RCALL byte2decimal    ;covert & display on MAX7219
    ;-----------------------------------------------------------
    RET
    ;RCALL delay_ms
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





RET


byte2decimal:
;------------
      
  RCALL print_dot


  CPI R28,5
  BRLO printCrash

  CPI R28,10
  BRLO printStop

  CPI R28,20
  BRLO printClose

  CPI R28,40
  BRGE printNone

  CPI R28,20
  BRGE printSafe


printNone:
   LDI   R18,9
   RCALL print_msg
   LDI   R18,0
   RCALL print_msg
   RCALL print_comma
   RET


printSafe:
   LDI   R18,3
   RCALL print_msg
   LDI   R18,0
   RCALL print_msg
   RCALL print_comma
   RET
   
printClose:
   LDI   R18,2
   RCALL print_msg
   LDI   R18,0
   RCALL print_msg
   RCALL print_comma
   RET

printStop:
   LDI   R18,1
   RCALL print_msg
   LDI   R18,0
   RCALL print_msg
   RCALL print_comma
   RET

printCrash:
   LDI   R18,0
   RCALL print_msg
   LDI   R18,5
   RCALL print_msg
   RCALL print_comma


RET
;===============================================================


;===============================================================
servo_motor:
;-----------
    SBI   DDRB, 4         ;pin PB4 o/p for servo control
    LDI   R19, 0
;---------------------------------------------------------------
again:     
    LDI   R25, 1          ;counter for LED control
    LDI   R26, 8        ;counter for # of rotation pos
    LDI   ZL, lo8(rotate_pos)
    LDI   ZH, hi8(rotate_pos)
    ;-----------------------------------------------------------

resetS:
    LDI R19,0

sl1: LPM   R24, Z+         ;load rotation pos
    MOV   R18,R19
    CPI   R19, 8
    BREQ  resetS
    INC   R19
    RCALL print_msg
    RCALL rotate_servo    ;& rotate servo
    RCALL HC_SR04_sensor
    DEC   R26
    BRNE  sl1              ;go back & get another rotate pos
    ;-----------------------------------------------------------
    RJMP  again           ;go back & repeat
;---------------------------------------------------------------
rotate_pos:
.byte 30,60,90,120,150,120,90,60
;===============================================================
rotate_servo:
;------------
    LDI   R20, 5         ;count to give enough cycles of PWM
l2: SBI   PORTB, 4
    RCALL delay_timer0
    CBI   PORTB, 4        ;send msec pulse to rotate servo
    RCALL delay_20ms      ;wait 20ms before re-sending pulse
    DEC   R20
    BRNE  l2              ;go back & repeat PWM signal
    ;-----------------------------------------------------------
bak:RCALL delay_20ms        ;0.2s delay
    RET                   ;& return to main subroutine
;-------------------
red_LED:                  ;subroutine to turn ON red LED
    CBI   PORTB, 1
    CBI   PORTB, 2
    RJMP  bak
;------------------
green_LED:                ;subroutine to turn ON green LED
    CBI   PORTB, 0
    SBI   PORTB, 1
    CBI   PORTB, 2
    RJMP  bak
;------------------
blue_LED:                 ;subroutine to turn ON blue LED
    CBI   PORTB, 0
    CBI   PORTB, 1
    SBI   PORTB, 2
    RJMP  bak
;===============================================================
;delay subroutines
;===============================================================
delay_timer0:             ;delay via Timer0
    ;-----------------------------------------------------------
    CLR   R21
    OUT   TCNT0, R21      ;initialize timer0 with count=0
    MOV   R21, R24
    OUT   OCR0A, R21
    LDI   R21, 0b00001100
    OUT   TCCR0B, R21     ;timer0: CTC mode, prescaler 256
    ;-----------------------------------------------------------
l3: IN    R21, TIFR0      ;get TIFR0 byte & check
    SBRS  R21, OCF0A      ;if OCF0=1, skip next instruction
    RJMP  l3              ;else, loop back & check OCF0 flag
    ;-----------------------------------------------------------
    CLR   R21
    OUT   TCCR0B, R21     ;stop timer0
    ;-----------------------------------------------------------
    LDI   R21, (1<<OCF0A)
    OUT   TIFR0, R21      ;clear OCF0 flag
    RET
;===============================================================
delay_20ms:               ;delay 20ms
    LDI   R21, 255
l4: LDI   R22, 100
l5: LDI   R23, 1
l6: DEC   R23
    BRNE  l6
    DEC   R22
    BRNE  l5
    DEC   R21
    BRNE  l4
    RET
;===============================================================
delay_ms:                 ;delay 0.5s
    LDI   R21, 255
l7 :LDI   R22, 255
l8 :LDI   R23, 41
l9 :DEC   R23
    BRNE  l9
    DEC   R22
    BRNE  l8
    DEC   R21
    BRNE  l7
    RET
