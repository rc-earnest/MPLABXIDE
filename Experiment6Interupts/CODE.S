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
    GOTO INTERUPT
  
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
    CLRF    WPUB	;clearing registers
    CLRF    IOCB
    BSF	    IOCB,0
    BSF	    IOCB,1
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
    MOVLW   0x88
    MOVWF   INTCON
    BCF	    INTCON,0
    
    
    CLK1    EQU 0X20
    CLK2    EQU 0x21
    CLK3    EQU 0x22
    WSAVE   EQU 0x23
    SSAVE   EQU 0x24
    CLK1SAVE EQU 0x25
    CLK2SAVE EQU 0x26
    CLK3SAVE EQU 0x27
    DSAVE   EQU	 0x28
    GOTO    MAIN
    
MAIN:
    MOVLW   0x31
    MOVWF   PORTC
    GOTO    MAIN
    
    
INTERUPT:
    MOVWF   WSAVE
    MOVF    STATUS,0
    MOVWF   SSAVE
    BCF	    STATUS,5
    BCF	    STATUS,6
    BTFSC   PORTB,0
    CALL    SEVEN
    BTFSC   PORTB,1
    CALL    SIX
    MOVF    SSAVE,0
    MOVWF   STATUS
    MOVF    WSAVE,0
    BCF	    INTCON,0
    BSF	    INTCON,7
    RETFIE
    
SEVEN:
    
    MOVF    CLK1,0
    MOVWF   CLK1SAVE
    MOVF    CLK3,0
    MOVWF   CLK3SAVE
    MOVF    CLK2,0
    MOVWF   CLK2SAVE
    MOVLW   0x37
    MOVWF   PORTC
    CALL    DELAY
    MOVF    CLK1SAVE,0
    MOVWF   CLK1
    MOVF    CLK2SAVE,0
    MOVWF   CLK2
    MOVF    CLK3SAVE,0
    MOVWF   CLK3
    MOVF    DSAVE,0
    MOVWF   PORTC
    RETURN
    
SIX:
    BSF	    STATUS,5
    BCF	    STATUS,6
    BCF	    IOCB,1
    BCF	    STATUS,5
    BCF	    STATUS,6
    BCF	    INTCON,0
    BSF	    INTCON,7
    MOVLW   0x36
    MOVWF   DSAVE
    MOVWF   PORTC
    CALL    DELAY
    BSF	    STATUS,5
    BCF	    STATUS,6
    BSF	    IOCB,1
    BCF	    STATUS,5
    BCF	    STATUS,6
    RETURN
    
    
DELAY:
    MOVLW	11
    MOVWF	CLK3
LOOP3:	    
    MOVLW	237
    MOVWF	CLK2
LOOP2:	    
    MOVLW	255
    MOVWF	CLK1
LOOP1:	    
    DECFSZ	CLK1
    GOTO	LOOP1
    DECFSZ	CLK2
    GOTO	LOOP2
    DECFSZ	CLK3
    GOTO	LOOP3
    RETURN
    END