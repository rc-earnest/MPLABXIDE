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
  DATA_EE_DATA	EQU 0x20
  DATA_EE_ADR	EQU 0x21
  SCAN          EQU 0x22
  S_SAVE	EQU 0x23
  W_SAVE	EQU 0x24
  TIMER_TIME	EQU 0x25
  DOT_S		EQU 0x26
  CLK1		EQU 0x27
  CLK2		EQU 0x28
  CLK3		EQU 0x29
  CLK4		EQU 0x2A
  ADR_COUNT	EQU 0x2B
    

PSECT resetVect,class=CODE,delta=2
    GOTO    SETUP

PSECT isrVect,class=CODE,delta=2
   GOTO    ISR_VECT
  
PSECT code,class=CODE,delta=2

 
SETUP:
    
    ;clearing some registers for setup
    CLRF    INTCON
    ;going to bank 3
    BSF	    STATUS,5	
    BSF	    STATUS,6
    CLRF    ANSEL
    CLRF    ANSELH
    CLRF    OPTION_REG
    BSF	    OPTION_REG,7
    MOVLW   0x80
    MOVWF   EECON1

    ;going to bank 2
    BCF	    STATUS,5	
    BSF	    STATUS,6
    CLRF    CM2CON1
    CLRF    CM1CON0
    CLRF    CM2CON0
    
    ;going to bank 1
    BSF	    STATUS,5	
    BCF	    STATUS,6
    ;setting half of PORT A as inputs
    MOVLW   0x0F
    MOVWF   TRISA
    ;setting half of PORTB as outputs
    BCF	    TRISB,7
    BCF	    TRISB,6
    BCF	    TRISB,5
    BCF	    TRISB,4
    BSF	    TRISB,3
    BSF	    TRISB,2
    BSF	    TRISB,1
    BSF	    TRISB,0
    ;setting PORTC as outputs
    CLRF    TRISC
    ;enabling timer2 interrupt
    BSF	    PIE1,1
    ;enabling IOCB on PORTB inputs
    MOVLW   0x03
    MOVWF   IOCB
    ;setting count to value for Timer2
    MOVLW   0xFF
    MOVWF   PR2
    CLRF    PSTRCON
    
    ;going to bank 0
    BCF	    STATUS,5
    BCF	    STATUS,6
    ;clearing ports
    CLRF    PORTA
    CLRF    PORTB
    CLRF    PORTC
    CLRF    PIR1
    CLRF    DATA_EE_DATA
    CLRF    DATA_EE_ADR
    CLRF    SCAN
    CLRF    S_SAVE
    CLRF    W_SAVE
    CLRF    TIMER_TIME
    CLRF    DOT_S
    CLRF    ADR_COUNT
    
    MOVLW   15
    MOVWF   TIMER_TIME
    
    MOVLW   0x53
    MOVWF   DOT_S
    ;setting up timer 2 for max time
    MOVLW   0xFF
    MOVWF   T2CON
    
    ;enabling interrupts
    BSF	    INTCON,6
    BSF	    INTCON,3
    BSF	    INTCON,7
   
    
    GOTO    MAIN
    
MAIN:
    BCF	    STATUS,5
    BCF	    STATUS,6
    BSF	    PORTA,4
    BTFSC   SCAN,1
    GOTO    READ_EEPROM
    BTFSC   PORTB,2
    GOTO    RST
    BCF	    PORTA,4
    BTFSS   SCAN,0
    GOTO    MAIN
    
SCANNING:
    
    CLRF    PORTB
    BSF	    PORTB,4
    
    MOVLW   0
    BTFSC   PORTA,0
    GOTO    DOSTUFF

    MOVLW   3
    BTFSC   PORTA,1
    GOTO    DOSTUFF

    MOVLW   6
    BTFSC   PORTA,2
    GOTO    DOSTUFF
    
    MOVLW   9
    BTFSC   PORTA,3
    GOTO    DOSTUFF

    
    BCF	    PORTB,4
    BSF	    PORTB,5
    
    MOVLW   12
    BTFSC   PORTA,0
    GOTO    DOSTUFF

    MOVLW   15
    BTFSC   PORTA,1
    GOTO    DOSTUFF

    MOVLW   18
    BTFSC   PORTA,2
    GOTO    DOSTUFF
    
    MOVLW   21
    BTFSC   PORTA,3
    GOTO   DOSTUFF

    BCF	    PORTB,5
    BSF	    PORTB,6 
    
    MOVLW   24
    BTFSC   PORTA,0
    GOTO    DOSTUFF

    MOVLW   27
    BTFSC   PORTA,1
    GOTO    DOSTUFF

    MOVLW   30
    BTFSC   PORTA,2
    GOTO    DOSTUFF
    
    MOVLW   33
    BTFSC   PORTA,3
    GOTO   DOSTUFF

    
    BCF	    PORTB,6
    BSF	    PORTB,7
    
    MOVLW   36
    BTFSC   PORTA,0
    GOTO   DOSTUFF

    MOVLW   39
    BTFSC   PORTA,1
    GOTO    DOSTUFF

    MOVLW   42
    BTFSC   PORTA,2
    GOTO   DOSTUFF
    
    MOVLW   45
    BTFSC   PORTA,3
    GOTO    DOSTUFF

    GOTO    MAIN
    
    
DOSTUFF:
    ADDWF   PCL,1
    
    MOVLW   0x33
    MOVWF   DATA_EE_DATA
    GOTO    WRITE_EEPROM
    
    MOVLW   0x32
    MOVWF   DATA_EE_DATA
    GOTO    WRITE_EEPROM
    
    MOVLW   0x31
    MOVWF   DATA_EE_DATA
    GOTO    WRITE_EEPROM
    
    MOVLW   0x41
    MOVWF   DATA_EE_DATA
    GOTO    WRITE_EEPROM
    
    MOVLW   0x36
    MOVWF   DATA_EE_DATA
    GOTO    WRITE_EEPROM
    
    MOVLW   0x35
    MOVWF   DATA_EE_DATA
    GOTO    WRITE_EEPROM
    
    MOVLW   0x34
    MOVWF   DATA_EE_DATA
    GOTO    WRITE_EEPROM
    
    MOVLW   0x42
    MOVWF   DATA_EE_DATA
    GOTO    WRITE_EEPROM
    
    MOVLW   0x39
    MOVWF   DATA_EE_DATA
    GOTO    WRITE_EEPROM
    
    MOVLW   0x38
    MOVWF   DATA_EE_DATA
    GOTO    WRITE_EEPROM
    
    MOVLW   0x37
    MOVWF   DATA_EE_DATA
    GOTO    WRITE_EEPROM
    
    MOVLW   0x43
    MOVWF   DATA_EE_DATA
    GOTO    WRITE_EEPROM
    
    MOVLW   0x23
    MOVWF   DATA_EE_DATA
    GOTO    WRITE_EEPROM
    
    MOVLW   0x30
    MOVWF   DATA_EE_DATA
    GOTO    WRITE_EEPROM
    
    MOVLW   0x2A
    MOVWF   DATA_EE_DATA
    GOTO    WRITE_EEPROM
    
    MOVLW   0x44
    MOVWF   DATA_EE_DATA
    GOTO    WRITE_EEPROM

WRITE_EEPROM:
    BCF	    INTCON,7
    MOVF    DATA_EE_DATA,0
    MOVWF   PORTC
    MOVF    DATA_EE_ADR,0  ;moves address to w
    BCF	    STATUS,5
    BSF	    STATUS,6
    MOVWF   EEADR ;Sets Address
    BCF	    STATUS,5
    BCF	    STATUS,6
    MOVF    DATA_EE_DATA,0 ;moves number pressed to data
    BCF	    STATUS,5
    BSF	    STATUS,6
    MOVWF   EEDATA ;Move button press to EEPREOM
    BSF	    STATUS,5
    BSF	    STATUS,6
    BCF	    EECON1,7
    MOVLW   0x55
    MOVWF   EECON2
    MOVLW   0xAA
    MOVWF   EECON2 
    BSF	    EECON1,1
    BSF	    INTCON,7
    BCF	    STATUS,5
    BCF	    STATUS,6
    
    BTFSS   PIR2,4
    GOTO    $-1
    BCF	    PIR2,4
    
    BSF	    STATUS,5
    BSF	    STATUS,6
    BSF	    EECON1,7
    BCF	    STATUS,5
    BCF	    STATUS,6
    CALL    DELAY
    CLRF    PORTC
    INCF    DATA_EE_ADR,1
    INCF    ADR_COUNT,1
    MOVF    DATA_EE_ADR,0
    BCF	    STATUS,2
    XORLW   10
    BTFSC   STATUS,2
    GOTO    RST
    GOTO    MAIN
    
    
DELAY:
    MOVLW	45	;27	
    MOVWF	CLK3	
    LOOP3:
    MOVLW	185	;185
    MOVWF	CLK2
    LOOP2:
    MOVLW	32	;32
    MOVWF	CLK1
    LOOP1:
    DECFSZ	CLK1	;+1(2)
    GOTO	LOOP1	;+2
    DECFSZ	CLK2	;+1(2)
    GOTO	LOOP2	;+2
    NOP		;+1
    NOP		;+1
    NOP		;+1
    NOP		;+1
    DECFSZ	CLK3	;+1(2)
    GOTO	LOOP3	;+2
	
    MOVLW	0x1	;1	
    MOVWF	CLK4
    FUDGE:
    DECFSZ	CLK4	;+1(2)
    GOTO	FUDGE
    RETURN
    
    
READ_EEPROM:  
    BCF	    INTCON,7
    MOVF    DATA_EE_ADR,0
    BCF	    STATUS,5
    BSF	    STATUS,6
    MOVWF   EEADR
    BSF	    STATUS,5
    BCF	    EECON1,7
    BSF	    EECON1,0
    BCF	    STATUS,5
    MOVF    EEDATA,0
    BSF	    STATUS,5
    BSF	    STATUS,6
    BSF	    EECON1,7
    BCF	    STATUS,5
    BCF	    STATUS,6
    MOVWF   PORTC
    CALL    DELAY
    BSF	    INTCON,7
    INCF    DATA_EE_ADR,1
    MOVF    DATA_EE_ADR,0
    BCF	    STATUS,2
    XORWF   ADR_COUNT,0
    BTFSC   STATUS,2
    GOTO    RSTR
   
    GOTO    MAIN
    
    
RST:
    BTFSS   SCAN,2
    GOTO    MAIN
    CLRF    DATA_EE_ADR
    CLRF    PORTC
    MOVF    ADR_COUNT,0
    MOVWF   DATA_EE_DATA
    MOVLW   0x69
    MOVWF   DATA_EE_ADR
    CALL    WRITE_COUNT
    CLRF    DATA_EE_DATA
    CLRF    DATA_EE_ADR
    CALL    DELAY
    CLRF    ADR_COUNT
    BCF	    SCAN,0
    BCF	    SCAN,2
    BSF	    T2CON,2
    GOTO    MAIN
    
RSTR:
    CLRF    ADR_COUNT
    CLRF    DATA_EE_ADR
    CLRF    PORTC
    BCF	    SCAN,1
    BSF	    T2CON,2
    GOTO    MAIN
    
    
WRITE_COUNT:
    BCF	    INTCON,7
    MOVF    DATA_EE_ADR,0  ;moves address to w
    BCF	    STATUS,5
    BSF	    STATUS,6
    MOVWF   EEADR ;Sets Address
    BCF	    STATUS,5
    BCF	    STATUS,6
    MOVF    DATA_EE_DATA,0 ;moves number pressed to data
    BCF	    STATUS,5
    BSF	    STATUS,6
    MOVWF   EEDATA ;Move button press to EEPREOM
    BSF	    STATUS,5
    BSF	    STATUS,6
    BCF	    EECON1,7
    MOVLW   0x55
    MOVWF   EECON2
    MOVLW   0xAA
    MOVWF   EECON2 
    BSF	    EECON1,1
    BSF	    INTCON,7
    BCF	    STATUS,5
    BCF	    STATUS,6
    
    BTFSS   PIR2,4
    GOTO    $-1
    BCF	    PIR2,4
    
    BSF	    STATUS,5
    BSF	    STATUS,6
    BSF	    EECON1,7
    BCF	    STATUS,5
    BCF	    STATUS,6
    RETURN
    
    
ISR_VECT:
    MOVWF   W_SAVE
    MOVF    STATUS,0
    MOVWF   S_SAVE
    BCF	    STATUS,5
    BCF	    STATUS,6
    
    BTFSC   INTCON,0
    GOTO    PORTB_ISR
    
    BTFSC   PIR1,1
    GOTO    TIMER_ISR
    
    GOTO    END_ISR
    
  PORTB_ISR:
    BCF	    INTCON,0
    CLRF    PORTC
    
    BTFSC   PORTB,0
    GOTO    RECORD
    
    BTFSC   PORTB,1
    GOTO    PLAY
    
    
    GOTO    END_ISR
    
  TIMER_ISR:
    BCF	    PIR1,1
    DECFSZ  TIMER_TIME
    GOTO    END_ISR
    MOVF    DOT_S,0
    XORLW   0x54
    MOVWF   DOT_S
    MOVWF   PORTC
    MOVLW   15
    MOVWF   TIMER_TIME
    GOTO    END_ISR
    
  PLAY:
    BCF	    T2CON,2
    BSF	    SCAN,1
    BCF	    SCAN,0
    BCF	    SCAN,2
    BSF	    STATUS,5
    BSF	    STATUS,6
    BCF	    EECON1,2
    BCF	    STATUS,5
    BCF	    STATUS,6
    CALL    READ_COUNT
    CLRF    DATA_EE_ADR
    CLRF    DATA_EE_DATA
    GOTO    END_ISR
    
    READ_COUNT:
    MOVLW   0x69
    BCF	    STATUS,5
    BSF	    STATUS,6
    MOVWF   EEADR
    BSF	    STATUS,5
    BCF	    EECON1,7
    BSF	    EECON1,0
    BCF	    STATUS,5
    MOVF    EEDATA,0
    BSF	    STATUS,5
    BSF	    STATUS,6
    BSF	    EECON1,7
    BCF	    STATUS,5
    BCF	    STATUS,6
    MOVWF   ADR_COUNT
    RETURN
    
    
  RECORD:  
    BCF	    T2CON,2
    BSF	    SCAN,0
    BCF	    SCAN,1
    BSF	    SCAN,2
    BSF	    STATUS,5
    BSF	    STATUS,6
    BSF	    EECON1,2
    BCF	    STATUS,5
    BCF	    STATUS,6
    GOTO    END_ISR
    
    
    
  END_ISR:
    MOVF    S_SAVE,0
    MOVWF   STATUS
    MOVF    W_SAVE,0
    RETFIE
    
    
    END