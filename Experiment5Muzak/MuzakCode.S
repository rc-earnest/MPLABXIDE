; PIC16F883 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = XT             ; Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.
#include <xc.inc>

PSECT resetVect,class=CODE,delta=2
    GOTO SETUP

PSECT isrVect,class=CODE,delta=2
    RETFIE
  
PSECT code,class=CODE,delta=2

 
SETUP:
    ;going to bank 3
    BSF	    STATUS,5	
    BSF	    STATUS,6
    CLRF    INTCON	
    CLRF    OPTION_REG
    CLRF    ANSELH
    CLRF    ANSEL
    MOVLW   0x0F
    MOVWF   TRISB
    
    ;going to bank 2
    BCF	    STATUS,5	
    BSF	    STATUS,6
    CLRF    CM2CON1
    CLRF    CM1CON0
    CLRF    CM2CON0
    
    ;going to bank 1
    BSF	    STATUS,5	
    BCF	    STATUS,6
    CLRF    PCON
    CLRF    WPUB	
    CLRF    IOCB
    CLRF    PSTRCON
    CLRF    TRISC
    MOVLW   0XFF
    MOVWF   TRISA
    
    ;going to bank 0
    BCF	    STATUS,5
    BCF	    STATUS,6
    CLRF    T1CON
    CLRF    SSPCON
    CLRF    RCSTA
    CLRF    CCP2CON
    CLRF    CCP1CON
    CLRF    PORTC
    CLRF    PORTB
    CLRF    PORTA
    
    CLK1    EQU 0X20
    CLK2    EQU	0x21
    CLK3    EQU 0x23
    BSF	    PORTA,0
    MOVLW   0X20
    MOVWF   PORTB 
    GOTO    MAIN
    
MAIN:
    
    BCF	    STATUS,5
    BCF	    STATUS,6
    
     ;Start of checking row with 123A
    MOVLW   0x10
    MOVWF   PORTB
    
    MOVLW   0
    BTFSC   PORTB,2
    CALL    DOSTUFF

    MOVLW   3
    BTFSC   PORTB,1
    CALL    DOSTUFF

    MOVLW   6
    BTFSC   PORTB,0
    CALL    DOSTUFF
    
    MOVLW   9
    BTFSC   PORTB,3
    CALL    DOSTUFF
    
    ;Start of checking row with 456B
    MOVLW   0x20
    MOVWF   PORTB
    
    MOVLW   12
    BTFSC   PORTB,2
    CALL    DOSTUFF

    MOVLW   15
    BTFSC   PORTB,1
    CALL    DOSTUFF

    MOVLW   18
    BTFSC   PORTB,0
    CALL    DOSTUFF
    
    MOVLW   21
    BTFSC   PORTB,3
    CALL    DOSTUFF
    
    ;Start of checking row with 789C
    MOVLW   0x40
    MOVWF   PORTB
    
    MOVLW   24
    BTFSC   PORTB,2
    CALL    DOSTUFF

    MOVLW   27
    BTFSC   PORTB,1
    CALL    DOSTUFF

    MOVLW   30
    BTFSC   PORTB,0
    CALL    DOSTUFF
    
    MOVLW   33
    BTFSC   PORTB,3
    CALL    DOSTUFF
    
    ;Start of checking row with *0#D
    MOVLW   0x80
    MOVWF   PORTB
    
    MOVLW   36
    BTFSC   PORTB,0
    CALL    DOSTUFF

    MOVLW   39
    BTFSC   PORTB,1
    CALL    DOSTUFF

    MOVLW   42
    BTFSC   PORTB,2
    CALL    DOSTUFF
    
    MOVLW   45
    BTFSC   PORTB,3
    CALL    DOSTUFF
    
    GOTO    MAIN
    
DOSTUFF:
    ADDWF   PCL,1
    
    MOVLW   0x35
    MOVWF   CLK3
    CALL    SIG
    
    MOVLW   0x3B
    MOVWF   CLK3
    CALL    SIG
    
    MOVLW   0x3F
    MOVWF   CLK3
    CALL    SIG
    
    MOVLW   0x47
    MOVWF   CLK3
    CALL    SIG
    
    MOVLW   0x4F
    MOVWF   CLK3
    CALL    SIG
    
    MOVLW   0x59
    MOVWF   CLK3
    CALL    SIG
    
    MOVLW   0x5E
    MOVWF   CLK3
    CALL    SIG
    
    MOVLW   0x6A
    MOVWF   CLK3
    CALL    SIG
    
    MOVLW   0x77
    MOVWF   CLK3
    CALL    SIG
    
    MOVLW   0x7E
    MOVWF   CLK3
    CALL    SIG
    
    MOVLW   0x8E
    MOVWF   CLK3
    CALL    SIG
    
    MOVLW   0x9F
    MOVWF   CLK3
    CALL    SIG
    
    MOVLW   0xB2
    MOVWF   CLK3
    CALL    SIG
    
    MOVLW   0xBD
    MOVWF   CLK3
    CALL    SIG
    
    MOVLW   0xD4
    MOVWF   CLK3
    CALL    SIG
    
    MOVLW   0xEE
    MOVWF   CLK3
    CALL    SIG
    
    

SIG:
    MOVLW   0X01
    XORWF   PORTA,0
    MOVWF   PORTC
    CALL    DELAY
    RETURN
    
    
DELAY:
;BEGINNING OF DELAY LOOP
LOOP3:	    
    MOVLW   1
    MOVWF   CLK2
LOOP2:	    
    MOVLW   1
    MOVWF   CLK1
LOOP1:	    
    DECFSZ  CLK1
    GOTO    LOOP1
    DECFSZ  CLK2
    GOTO    LOOP2
    DECFSZ  CLK3
    GOTO    LOOP3    
    RETURN
	   
    END
