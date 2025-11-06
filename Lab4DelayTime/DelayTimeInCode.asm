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

 


SETUP:	;going to bank 1
	    BSF		STATUS,5	
	    BCF		STATUS,6
	    CLRF	PSTRCON
	    CLRF	TRISC
	
	;going to bank 0
	    BCF		STATUS,5
	    BCF		STATUS,6
	    CLRF	T1CON
	    CLRF	SSPCON
	    CLRF	RCSTA
	    CLRF	CCP2CON
	    CLRF	CCP1CON
	    CLRF	PORTC
	    CLK1	EQU 0x20
	    CLK2	EQU 0x21
	    CLK3	EQU 0x22
	    FUDGE	EQU 0x23
	
	    GOTO	MAIN
	
MAIN:	    ;STARTING CODE TO DISPLAY A 5
	    MOVLW	0X35
	    MOVWF	PORTC
	    
	    ;BEGINNING OF .5S DELAY LOOP
	    MOVLW	11
	    MOVWF	CLK3
LOOP3:	    
	    MOVLW	184
	    MOVWF	CLK2
LOOP2:	    
	    MOVLW	81
	    MOVWF	CLK1
LOOP1:	    
	    DECFSZ	CLK1
	    GOTO	LOOP1
	    DECFSZ	CLK2
	    GOTO	LOOP2
	    DECFSZ	CLK3
	    GOTO	LOOP3
	    MOVLW	13
	    MOVWF	FUDGE
EXLOOP:	    
	    DECFSZ	FUDGE
	    GOTO	EXLOOP
	    NOP
	    NOP
	    
	    
	
	    
	    ;STARTING CODE TO DISPLAY A 0
	    MOVLW	0X30
	    MOVWF	PORTC
	    
	    ;BEGINNING OF .5S DELAY LOOP
	    MOVLW	11
	    MOVWF	CLK3
LOOP6:	    
	    MOVLW	184
	    MOVWF	CLK2
LOOP5:	    
	    MOVLW	81
	    MOVWF	CLK1
LOOP4:	    
	    DECFSZ	CLK1
	    GOTO	LOOP4
	    DECFSZ	CLK2
	    GOTO	LOOP5
	    DECFSZ	CLK3
	    GOTO	LOOP6
	    MOVLW	13
	    MOVWF	FUDGE
EXLOOPs:	    
	    DECFSZ	FUDGE
	    GOTO	EXLOOPs
	    
	
	    GOTO	MAIN
END
	




   