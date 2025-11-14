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
ADC_SAVE    EQU	0x20
ADC_COUNTER EQU 0x21
SEND_DATA   EQU 0x22

PSECT resetVect,class=CODE,delta=2
   GOTO    SETUP

PSECT isrVect,class=CODE,delta=2
  RETFIE
   ; GOTO    ISR_VECT
  
PSECT code,class=CODE,delta=2
SETUP:
    ;Bank 3
    BSF	    STATUS,5
    BSF	    STATUS,6
    CLRF    ANSEL
    BSF	    ANSEL,0
    BSF	    ANSEL,1
    BSF	    ANSEL,2
    CLRF    ANSELH
    
    ;Bank 2
    BCF	    STATUS,5
    BSF	    STATUS,6
    
    
    ;Bank 1
    BSF	    STATUS,5
    BCF	    STATUS,6
    MOVLW   9
    MOVWF   SSPADD
    MOVLW   0xFF
    MOVWF   TRISC
    CLRF    ADCON1
    
    ;Bank 0
    BCF	    STATUS,5
    BCF	    STATUS,6
    BSF	    SSPCON,3
    BCF	    SSPCON,2
    BCF	    SSPCON,1
    BCF	    SSPCON,0
    BSF	    SSPCON,5
    CLRF    ADCON0
    BSF	    ADCON0,6
    BSF	    ADCON0,0
    BSF	    ADCON0,2
    BSF	    ADCON0,3
    
    GOTO MAIN
    
MAIN:
    BCF	    STATUS,5
    BCF	    STATUS,6
    BSF	    ADCON0,1
    BTFSC   ADCON0,1
    GOTO    $-1
    INCF    ADC_COUNTER
    MOVF    ADRESH,0
    MOVWF   ADC_SAVE
    MOVF    ADC_COUNTER,0
    XORLW   0x01
    BTFSC   STATUS,2
    CALL    ADC0
    MOVF    ADC_COUNTER,0
    XORLW   0x02
    BTFSC   STATUS,2
    CALL    ADC1
    MOVF    ADC_COUNTER,0
    XORLW   0x03
    BTFSC   STATUS,2
    CALL    ADC2
    
    BSF	    STATUS,5
    BCF	    STATUS,6
    BSF	    SSPCON2,0
    BTFSC   SSPCON2,0
    GOTO    $-1
    BCF	    STATUS,5
    BCF	    STATUS,6
    MOVLW   0x20
    MOVWF   SSPBUF
    BSF	    STATUS,5
    BCF	    STATUS,6
    BTFSC   SSPSTAT,2
    GOTO    $-1
    BTFSC   SSPCON2,7
    GOTO    $-1
    BCF	    STATUS,5
    BCF	    STATUS,6
    MOVF    SEND_DATA,0
    MOVWF   SSPBUF
    BSF	    STATUS,5
    BCF	    STATUS,6
    BTFSC   SSPSTAT,2
    GOTO    $-1
    BTFSC   SSPCON2,7
    GOTO    $-1
    BSF	    SSPCON2,2
    BTFSC   SSPCON2,2
    GOTO    $-1
    GOTO    MAIN
    
    
    
ADC0:
    BCF	    STATUS,0
    RRF	    ADC_SAVE,1
    BCF	    STATUS,0
    RRF	    ADC_SAVE,1
    BCF	    STATUS,0
    RRF	    ADC_SAVE,1
    MOVLW   0x20
    IORWF   ADC_SAVE,0
    MOVWF   SEND_DATA
    BCF	    ADCON0,3
    BSF	    ADCON0,2
    RETURN
    
ADC1:
    BCF	    STATUS,0
    RRF	    ADC_SAVE,1
    BCF	    STATUS,0
    RRF	    ADC_SAVE,1
    BCF	    STATUS,0
    RRF	    ADC_SAVE,1
    MOVLW   0x40
    IORWF   ADC_SAVE,0
    MOVWF   SEND_DATA
    BCF	    ADCON0,2
    BSF	    ADCON0,3
    RETURN
    
ADC2:
    BCF	    STATUS,0
    RRF	    ADC_SAVE,1
    BCF	    STATUS,0
    RRF	    ADC_SAVE,1
    BCF	    STATUS,0
    RRF	    ADC_SAVE,1
    MOVLW   0x80
    IORWF   ADC_SAVE,0
    MOVWF   SEND_DATA
    BSF	    ADCON0,2
    BSF	    ADCON0,3
    CLRF    ADC_COUNTER
    RETURN
    
    END