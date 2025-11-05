;Rudy Earnest
;RCET	3375
;Fall 2025
;EEPROM
;GIT link
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
    BSF	    STATUS,5 ;going to bank 3
    BSF	    STATUS,6
    CLRF    INTCON   ;clearing registers
    CLRF    OPTION_REG
    CLRF    ANSEL
    CLRF    ANSELH
    
    
    BCF	    STATUS,5 ;going to bank 2
    BSF	    STATUS,6
    CLRF    CM2CON1
   
    BSF	    STATUS,5 ;going to bank 1
    BCF	    STATUS,6
    CLRF    WPUB
    CLRF    IOCB
    CLRF    TRISB
    BSF	    TRISB,3
    BSF	    TRISB,2
    BSF	    TRISB,1
    BSF	    TRISB,0
    
    BCF	    STATUS,5 ;going to bank 0
    BCF	    STATUS,6
    CLRF    CCP1CON
    CLRF    PORTB
    
MAIN:
    BSF	    PORTB,7
    BSF	    PORTB,6
    BSF	    PORTB,5
    BSF	    PORTB,4
    CLRF    PORTB
    GOTO    MAIN
    END
