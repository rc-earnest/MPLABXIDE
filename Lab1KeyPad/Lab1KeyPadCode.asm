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

  
PSECT code,class=CODE,delta=2

 
SETUP:
    ;going to bank 3
    BSF	    STATUS,5	
    BSF	    STATUS,6
    CLRF    INTCON	
    CLRF    OPTION_REG
    CLRF    ANSELH
    MOVLW   0x0F
    MOVWF   TRISB
    
    ;going to bank 2
    BCF	    STATUS,5	
    BSF	    STATUS,6
    CLRF    CM2CON1
   
    ;going to bank 1
    BSF	    STATUS,5	
    BCF	    STATUS,6
    CLRF    WPUB	
    CLRF    IOCB
    CLRF    PSTRCON
    CLRF    TRISC
    
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
    
    GOTO    MAIN
    
MAIN:
    BCF	    STATUS,5
    BCF	    STATUS,6
    ;Start of checking row with 789C
    MOVLW   0x40
    MOVWF   PORTB
    
    MOVLW   0x39
    BTFSC   PORTB,2
    GOTO    DOSTUFF

    MOVLW   0x38
    BTFSC   PORTB,1
    GOTO    DOSTUFF

    MOVLW   0x37
    BTFSC   PORTB,0
    GOTO    DOSTUFF
    
    MOVLW   0x43
    BTFSC   PORTB,3
    GOTO    DOSTUFF
    
    ;Start of checking row with 456B
    MOVLW   0x20
    MOVWF   PORTB
    
    MOVLW   0x36
    BTFSC   PORTB,2
    GOTO    DOSTUFF

    MOVLW   0x35
    BTFSC   PORTB,1
    GOTO    DOSTUFF

    MOVLW   0x34
    BTFSC   PORTB,0
    GOTO    DOSTUFF
    
    MOVLW   0x42
    BTFSC   PORTB,3
    GOTO    DOSTUFF
    
    ;Start of checking row with 123A
    MOVLW   0x10
    MOVWF   PORTB
    
    MOVLW   0x33
    BTFSC   PORTB,2
    GOTO    DOSTUFF

    MOVLW   0x32
    BTFSC   PORTB,1
    GOTO    DOSTUFF

    MOVLW   0x31
    BTFSC   PORTB,0
    GOTO    DOSTUFF
    
    MOVLW   0x41
    BTFSC   PORTB,3
    GOTO    DOSTUFF
    
    ;Start of checking row with *0#D
    MOVLW   0x80
    MOVWF   PORTB
    
    MOVLW   0x2A
    BTFSC   PORTB,0
    GOTO    DOSTUFF

    MOVLW   0x30
    BTFSC   PORTB,1
    GOTO    DOSTUFF

    MOVLW   0x23
    BTFSC   PORTB,2
    GOTO    DOSTUFF
    
    MOVLW   0x44
    BTFSC   PORTB,3
    GOTO    DOSTUFF
    
    
    MOVLW   0x7F
    GOTO    DOSTUFF
    
    
DOSTUFF:
    MOVWF   PORTC
    GOTO    MAIN
    
 END
