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
#include <pic16f883.inc>
PSECT resetVect,class=CODE,delta=2
    GOTO SETUP

PSECT isrVect,class=CODE,delta=2
    GOTO INTERUPT
  
PSECT code,class=CODE,delta=2
ADRESH_SAVE EQU 0x20
CLK1	    EQU 0x21
CLK2	    EQU 0x22	
PCL_ADD	    EQU 0X23	    
 
 
INTERUPT:
    CLRF    PIR1
    BSF	    PORTC,0
    MOVF    ADRESH,0
    MOVWF   ADRESH_SAVE
    Call    CONVERSION
    MOVWF   CLK2
    LOOP2:
    MOVLW   0X02
    MOVWF   CLK1
    LOOP1:
    DECFSZ  CLK1
    GOTO    LOOP1
    DECFSZ  CLK2
    GOTO    LOOP2
    BCF	    PORTC,0
    CLRF    PCL_ADD
    RETFIE
    
CONVERSION:
    BTFSC   ADRESH_SAVE,7
    CALL    BIT7
    BTFSC   ADRESH_SAVE,6
    CALL    BIT6
    BTFSC   ADRESH_SAVE,5
    CALL    BIT5
    BTFSC   ADRESH_SAVE,4
    CALL    BIT4
    BTFSC   ADRESH_SAVE,3
    CALL    BIT3
    GOTO    LOOKUP
BIT7:
    MOVLW   32
    ADDWF   PCL_ADD
    RETURN
BIT6:
    MOVLW   16
    ADDWF   PCL_ADD
    RETURN
BIT5:
    MOVLW   8
    ADDWF   PCL_ADD
    RETURN
BIT4:
    MOVLW   4
    ADDWF   PCL_ADD
    RETURN
BIT3:    
    MOVLW   2
    ADDWF   PCL_ADD
    RETURN
 
    
LOOKUP:
    MOVF    PCL_ADD,0
    ADDWF   PCL,1
    MOVLW   55
    RETURN
    MOVLW   63
    RETURN
    MOVLW   71
    RETURN
    MOVLW   79
    RETURN
    MOVLW   87
    RETURN
    MOVLW   95
    RETURN
    MOVLW   103
    RETURN
    MOVLW   111
    RETURN
    MOVLW   119
    RETURN
    MOVLW   127
    RETURN
    MOVLW   135
    RETURN
    MOVLW   143
    RETURN
    MOVLW   151
    RETURN
    MOVLW   159
    RETURN
    MOVLW   167
    RETURN
    MOVLW   175
    RETURN
    MOVLW   183
    RETURN
    MOVLW   191
    RETURN
    MOVLW   199
    RETURN
    MOVLW   207
    RETURN
    MOVLW   215
    RETURN
    MOVLW   223
    RETURN
    MOVLW   225
    RETURN
    MOVLW   227
    RETURN
    MOVLW   229
    RETURN
    MOVLW   231
    RETURN
SETUP:
    BCF	    STATUS,5
    BCF	    STATUS,6
    MOVLW   0x41
    MOVWF   ADCON0
    CLRF    PORTA
    CLRF    PORTC
    CLRF    PORTB
    
    BSF	    STATUS,5
    CLRF    ADCON1
    CLRF    INTCON
    CLRF    TRISA
    BSF	    TRISA,0
    CLRF    TRISC
    BSF	    PIE1,1
    
    BSF	    STATUS,6
    CLRF    ANSEL
    BSF	    ANSEL,0
    
    BCF	    STATUS,5
    BCF	    STATUS,6
    BSF	    INTCON,7
    BSF	    INTCON,6
    MOVLW   0x26
    MOVWF   T2CON
    
    GOTO    MAIN
    
MAIN:
    BSF	    ADCON0,1
    BSF	    ADCON0,0
    BCF	    PORTC,0
    GOTO    MAIN
    END