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

SAVE_RX	    EQU 0X20
PCL_ADD	    EQU 0x21
CONTROL	    EQU 0X22
ADCRESULT   EQU 0X23
ENABLEPULSE EQU 0X24
TIMER_SAVE  EQU 0X25
PW	    EQU 0X26
PERIOD	    EQU 0X27
PS	    EQU 0X28
  
PSECT resetVect,class=CODE,delta=2
    GOTO SETUP

PSECT isrVect,class=CODE,delta=2
    GOTO INTERRUPT
  
PSECT code,class=CODE,delta=2
 ;Registers for doing stuff
 
 ;Setup Registers and stuff
 SETUP:    
      ;BANK1
    BSF	    STATUS,5
    BCF	    STATUS,6
    ;Setup transmit
    MOVLW   0x2E
    MOVWF   TXSTA
    ;Enable pin 1 input
    MOVLW   0x01
    MOVWF   TRISA
    ;CLR TRISB
    CLRF    TRISB
    ;Enable Specific int flags
    MOVLW   0x22
    MOVWF   PIE1
    MOVLW   25
    MOVWF   SPBRGH
    MOVWF   SPBRG
    MOVLW   0X64
    MOVWF   PR2
    CLRF    ADCON1
    CLRF    PCON
    MOVLW   0X00
    MOVWF   WPUB
    MOVLW   0X00
    MOVWF   IOCB
    CLRF    PSTRCON
    
    ;BANK2
    BCF	    STATUS,5
    BSF	    STATUS,6
    CLRF    CM1CON0
    CLRF    CM2CON0
    CLRF    CM2CON1
    
    
    ;BANK3
    BSF	    STATUS,5
    BSF	    STATUS,6
    ;Set up baud rate
    MOVLW   0x01
    MOVWF   BAUDCTL
    
    ;BANK0
    BCF	    STATUS,5
    BCF	    STATUS,6
    ;Setup Recive
    MOVLW   0x90
    MOVWF   RCSTA
    ;CLR Ports
    CLRF    PORTA
    CLRF    PORTB
    CLRF    PORTC
    MOVLW   0X04
    MOVWF   T2CON
    MOVLW   0X41
    MOVWF   ADCON0
    CLRF    CCP1CON
    CLRF    CCP2CON
    CLRF    SSPCON
    CLRF    T1CON
    MOVLW   0XC8
    MOVWF   PERIOD
    ;ENABLE INTERRUPTS
    CLRF    PIR1
    MOVLW   0xC0
    MOVWF   INTCON
    GOTO    MAIN
    
MAIN:
    BSF	    ADCON0,1
    BSF	    ADCON0,0
TEST:
    MOVF    SAVE_RX,0
    BTFSC   ADCON0,1
    GOTO    TEST
    MOVF    ADRESH,0
    MOVWF   ADCRESULT
    GOTO    MAIN
    
    
INTERRUPT:
    BTFSC   PIR1,5
    GOTO    RX
    BCF	    PIR1,1
    BTFSC   ENABLEPULSE, 0    ;Test to see if enabel (PW)
    GOTO    WaitPW
    BTFSC   ENABLEPULSE, 1    ;Test to see if enable (PS)
    GOTO    WaitPS
    MOVLW   0x01	
    MOVWF   ENABLEPULSE	    ;Enable PW
    CLRF    ADCRESULT
    BTFSC   SAVE_RX,0
    CALL    PLUS0
    BTFSC   SAVE_RX,1
    CALL    PLUS1
    BTFSC   SAVE_RX,2
    CALL    PLUS2
    BTFSC   SAVE_RX,3
    CALL    PLUS3
    BTFSC   SAVE_RX,4
    CALL    PLUS4
    MOVF    ADCRESULT, 0	    ;Load value for Table
    BCF	    PIR1, 1
    GOTO    LookUpTable	  
  
    RETFIE		    ;Should never reach here but Safety
    
PLUS0:
    MOVLW 0x03
    ADDWF ADCRESULT,1
    RETURN
    
PLUS1:
    MOVLW 0x06
    ADDWF ADCRESULT,1
    RETURN
    
PLUS2:
    MOVLW 0x0C
    ADDWF ADCRESULT,1
    RETURN
    
PLUS3:
    MOVLW 0x18
    ADDWF ADCRESULT,1
    RETURN
    
PLUS4:
    MOVLW 0x30
    ADDWF ADCRESULT,1
    RETURN
    
WaitPW:
    BSF PORTB, 0
    DECFSZ PW		    ;Wait for its alloted time
    RETFIE
    MOVLW 0x02
    MOVWF ENABLEPULSE	    ;Enable PS
    RETFIE
    
WaitPS:
    BCF PORTB, 0
    DECFSZ PS
    RETFIE
    CLRF ENABLEPULSE
    CLRF PORTB
    RETFIE
    
LookUpTable:
    CLRF ADCRESULT
    ADDWF PCL, 1
    MOVLW 0x05
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x06
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x07
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x08
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x09
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x0A
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x0B
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x0C
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x0D
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x0E
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x0F
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x10
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x11
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x12
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x13
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x14
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x15
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x16
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x17
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x18
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x19
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x1A
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x1B
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x1C
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x1D
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x1E
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x1F
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x20
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x21
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x22
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x23
    CALL TIMERADJ
    GOTO INTERRUPT
    MOVLW 0x24
    CALL TIMERADJ
    GOTO INTERRUPT
    
TIMERADJ:
    MOVWF PW		    ;Set to 2.5mS
    MOVF PW, 0
    SUBWF PERIOD, 0	    ;Takes 20mS - PW and makes it PS
    MOVWF PS
    RETURN
    
RX:
    BSF	    PORTB,1
    BCF	    PIR1,5
    MOVF    RCREG,0
    MOVWF   SAVE_RX
    XORLW   0x24
    BTFSS   STATUS,2
    RETFIE
    MOVF    SAVE_RX,0
    MOVWF   TXREG
    RETFIE
  END  