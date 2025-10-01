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
    CLK2    EQU 0x21
    CLK3    EQU 0x22
    GOTO    MAIN
    
MAIN:
    MOVLW   0X10
    MOVWF   PORTB 
    
     MOVLW   0
    BTFSC   PORTB,0
    CALL    DOSTUFF

    MOVLW   4
    BTFSC   PORTB,1
    CALL    DOSTUFF

    MOVLW   8
    BTFSC   PORTB,2
    CALL    DOSTUFF
    
    MOVLW   12
    BTFSC   PORTB,3
    CALL    DOSTUFF

    
    MOVLW   0X20
    MOVWF   PORTB 
    
     MOVLW   16
    BTFSC   PORTB,0
    CALL    DOSTUFF

    MOVLW   20
    BTFSC   PORTB,1
    CALL    DOSTUFF

    MOVLW   24
    BTFSC   PORTB,2
    CALL    DOSTUFF
    
    MOVLW   28
    BTFSC   PORTB,3
    CALL    DOSTUFF

    
    MOVLW   0X40
    MOVWF   PORTB 
    
     MOVLW   32
    BTFSC   PORTB,0
    CALL    DOSTUFF

    MOVLW   36
    BTFSC   PORTB,1
    CALL    DOSTUFF

    MOVLW   40
    BTFSC   PORTB,2
    CALL    DOSTUFF
    
    MOVLW   44
    BTFSC   PORTB,3
    CALL    DOSTUFF

    
    MOVLW   0X80
    MOVWF   PORTB 
    
    MOVLW   48
    BTFSC   PORTB,0
    CALL    DOSTUFF

    MOVLW   52
    BTFSC   PORTB,1
    CALL    DOSTUFF

    MOVLW   56
    BTFSC   PORTB,2
    CALL    DOSTUFF
    
    MOVLW   60
    BTFSC   PORTB,3
    CALL    DOSTUFF

    GOTO    MAIN
    
    
    DOSTUFF:
    ADDWF   PCL,1
    
    MOVLW   46
    MOVWF   CLK3
    CALL    SIG
    RETURN
    
    MOVLW   52
    MOVWF   CLK3
    CALL    SIG
    RETURN
    
    MOVLW   55
    MOVWF   CLK3
    CALL    SIG
    RETURN
    
    MOVLW   62
    MOVWF   CLK3
    CALL    SIG
    RETURN
    
    MOVLW   71
    MOVWF   CLK3
    CALL    SIG
    RETURN
    
    MOVLW   80
    MOVWF   CLK3
    CALL    SIG
    RETURN
    
    MOVLW   85
    MOVWF   CLK3
    CALL    SIG
    RETURN
    
    MOVLW   97
    MOVWF   CLK3
    CALL    SIG
    RETURN
    
    MOVLW   108
    MOVWF   CLK3
    CALL    SIG
    RETURN
    
    MOVLW   115
    MOVWF   CLK3
    CALL    SIG
    RETURN
    
    MOVLW   129
    MOVWF   CLK3
    CALL    SIG
    RETURN
    
    MOVLW   145
    MOVWF   CLK3
    CALL    SIG
    RETURN
    
    MOVLW   164
    MOVWF   CLK3
    CALL    SIG
    RETURN
    
    MOVLW   174
    MOVWF   CLK3
    CALL    SIG
    RETURN
    
    MOVLW   197
    MOVWF   CLK3
    CALL    SIG
    RETURN
    
    MOVLW   219 
    MOVWF   CLK3
    CALL    SIG
    RETURN
    
    

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
    MOVLW   3
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