
; PIC16F883 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = XT             ; Oscillator Selection bits 
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit
  CONFIG  MCLRE = ON            ; RE3/MCLR pin function select bit
  CONFIG  CP = OFF              ; Code Protection bit 
  CONFIG  CPD = OFF             ; Data Code Protection bit 
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits5
  CONFIG  IESO = OFF            ; Internal External Switchover bit
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits

// config statements should precede project file includes.
#include <xc.inc>

PSECT resetVect,class=CODE,delta=2
    GOTO SETUP

  
PSECT code,class=CODE,delta=2

 
SETUP:
    BSF	    STATUS,5	;going to bank 3
    BSF	    STATUS,6
    CLRF    INTCON	;clearing registers
    CLRF    OPTION_REG
    CLRF    ANSELH
    MOVLW   0xFF
    MOVWF   TRISB
    
    
    BCF	    STATUS,5	;going to bank 2
    BSF	    STATUS,6
    CLRF    CM2CON1
   
    BSF	    STATUS,5	;going to bank 1
    BCF	    STATUS,6
    MOVLW   0xFF
    MOVWF   WPUB	;clearing registers
    CLRF    IOCB
    CLRF    PSTRCON
    CLRF    TRISC
    

   
    BCF	    STATUS,5	;going to bank 0
    BCF	    STATUS,6
    CLRF    T1CON
    CLRF    SSPCON
    CLRF    RCSTA
    CLRF    CCP2CON
    CLRF    CCP1CON
    CLRF    PORTC
    CLRF    PORTB	;clearing portB
    

MAIN:
    ;Moves address goint to PORTC then checks PORTB
    MOVLW   0x37
    BTFSC   PORTB,7
    GOTO    DOSTUFF
    
    MOVLW   0x36
    BTFSC   PORTB,6
    GOTO    DOSTUFF
    
    MOVLW   0x35
    BTFSC   PORTB,5
    GOTO    DOSTUFF
    
    MOVLW   0x34
    BTFSC   PORTB,4
    GOTO    DOSTUFF
 
    
    MOVLW   0x33
    BTFSC   PORTB,3
    GOTO    DOSTUFF
    
    MOVLW   0x32
    BTFSC   PORTB,2
    GOTO    DOSTUFF
    
    MOVLW   0x31
    BTFSC   PORTB,1
    GOTO    DOSTUFF
    
    MOVLW   0x30
    BTFSC   PORTB,0
    GOTO    DOSTUFF
    
    GOTO    DOSTUFF

    
DOSTUFF:
    MOVWF   PORTC
    GOTO    MAIN
END