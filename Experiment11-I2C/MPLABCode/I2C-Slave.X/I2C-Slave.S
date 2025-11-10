;Rudy Earnest
;RCET 3375
;Fall 2025
;PIC	EEPROM
;github 
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
SSP_SAVE    EQU 0x20

PSECT resetVect,class=CODE,delta=2
   GOTO    SETUP

PSECT isrVect,class=CODE,delta=2
   GOTO    ISR_VECT
  
PSECT code,class=CODE,delta=2
SETUP:
    ;Bank 3
    BSF	    STATUS,5
    BSF	    STATUS,6
    CLRF    ANSEL
    CLRF    ANSELH
    
    ;Bank 2
    BCF	    STATUS,5
    BSF	    STATUS,6
    
    
    ;Bank 1
    BSF	    STATUS,5
    BCF	    STATUS,6
    CLRF    TRISB
    MOVLW   0xFF
    MOVWF   TRISC
    MOVLW   0x20
    MOVWF   SSPADD
    BCF	    SSPSTAT,7
    BSF	    PIE1,3
    
    ;Bank 0
    BCF	    STATUS,5
    BCF	    STATUS,6
    CLRF    PORTB
    
    BCF	    SSPCON,3
    BSF	    SSPCON,2
    BSF	    SSPCON,1
    BCF	    SSPCON,0
    
    BSF	    SSPCON,5
    
    BCF	    PIR1,3
    BSF	    INTCON,6
    BSF	    INTCON,7
    
    GOTO    MAIN
    
MAIN:
    GOTO    MAIN
    
    
ISR_VECT:
    BCF	    STATUS,5
    BCF	    STATUS,6
    BSF	    PORTB,0
    BTFSC   PIR1,3
    GOTO    ADDR
    GOTO    END_ISR
    
ADDR:
    MOVF    SSPBUF,0
    BCF	    PIR1,3
    BTFSC   SSPBUF,0
    GOTO    READ
    GOTO    WRITE
    GOTO    END_ISR
    
READ:
    MOVLW   0xAA
    BCF	    STATUS,5
    BCF	    STATUS,6
    MOVWF   SSPBUF
    GOTO    END_ISR
    
WRITE:
    MOVWF   SSP_SAVE
    BSF	    STATUS,5
    BCF	    STATUS,6
    BTFSC   SSPSTAT,4
    GOTO    END_ISR
    BCF	    SSPCON2,5
    BSF	    SSPCON2,4
    GOTO    END_ISR
    
    
END_ISR:
    BCF	    PORTB,0
    RETFIE
    END