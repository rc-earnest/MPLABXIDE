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

 

 
SETUP:
    
    BCF	    STATUS,5	;going to bank 0
    BCF	    STATUS,6
    ;setting up all of the registers that we will need
    CAR1    EQU 0x20
    CAR2    EQU 0x21
    CAR3    EQU 0x22
    NSG	    EQU 0x23
    NSY	    EQU 0x24
    ADD2    EQU 0x25
    EWG	    EQU 0x26
    EWY	    EQU 0x27
    EWR	    EQU 0x28
    JEFF    EQU 0x29
    NSRR    EQU 0x2A
    EWRR    EQU 0x2B
    NSC	    EQU 0x2C
    EWC	    EQU 0x2D
	    
	    
	    
    BSF	    STATUS,5	;going to bank 3
    BSF	    STATUS,6
    CLRF    INTCON	;clearing registers for both port B and C operation
    CLRF    OPTION_REG
    CLRF    ANSELH
    MOVLW   0x03
    MOVWF   TRISB
    CLRF    ANSEL
    
    BCF	    STATUS,5	;going to bank 2
    BSF	    STATUS,6
    CLRF    CM2CON1     ;getting rid of comparators
   
    BSF	    STATUS,5	;going to bank 1
    BCF	    STATUS,6
    MOVLW   0x02	;allowing timer int to be enabled
    MOVWF   PIE1
    CLRF    WPUB	;clearing registers for port b and c
    CLRF    IOCB
    CLRF    PSTRCON
    CLRF    TRISC
   
    BCF	    STATUS,5	;going to bank 0
    BCF	    STATUS,6
    CLRF    PIR1	;clearing the flag just in case
    MOVLW   0x56
    MOVWF   T2CON	;setting up timer two with a 1:16 and 1:11 scalers respectively
    CLRF    T1CON
    CLRF    SSPCON
    CLRF    RCSTA
    CLRF    CCP2CON
    CLRF    CCP1CON
    CLRF    PORTC
    CLRF    PORTB   ;clearing portB
    MOVLW   0XC0
    MOVWF   INTCON
    BCF	    INTCON,0
    
    
    MOVLW   109		;moving counts for timing later into registers
    MOVWF   NSG
    MOVWF   EWG
    MOVWF   EWR
    MOVLW   22
    MOVWF   NSY
    MOVWF   EWY
    MOVWF   NSRR
    MOVWF   EWRR
    CLRF    ADD2	;clearing registers that need to start at zero
    CLRF    JEFF
    
    GOTO    MAIN
   
MAIN:
    BCF	    STATUS,5
    BCF	    STATUS,6	;checks port b to see if N/S or E/W has cars
    BTFSC   PORTB,0
    BSF	    CAR1,0
    BTFSC   PORTB,1
    BSF	    CAR2,0
    MOVLW   109		;sets either N/S or E/W register for infinite operation
    BTFSC   PORTB,0
    MOVWF   NSC
    MOVLW   109
    BTFSC   PORTB,1
    MOVWF   EWC
    GOTO    MAIN
    
    
INTERUPT:
    CLRF    PIR1	 ;clears flag and checks which direction we need to be doing
    MOVF    ADD2,0
    ADDWF   PCL,1
    MOVF    CAR2,0
    ANDWF   CAR1,0
    MOVWF   CAR3
    BTFSC   CAR3,0
    GOTO    BOTH
    BTFSC   CAR1,0
    GOTO    NSDIR
    BTFSC   CAR2,0
    GOTO    EWDIR
    GOTO    BOTH
    
    
NSDIR:
    MOVLW   6		;Starts north south operation
    MOVWF   ADD2
    MOVF    CAR2,0	;Checks to see if another car came from the other direction
    ANDWF   CAR1,0
    MOVWF   CAR3
    BTFSC   CAR3,0
    CLRF    ADD2
    MOVF    JEFF,0	;Moves whatever is in jeff and adds it to the PCL for a "look up table" operation
    ADDWF   PCL,1
    MOVLW   0X81
    MOVWF   PORTC
    DECFSZ  NSC		;decrements the north south timing count that gets reset in main if button is pushed until zero
    RETFIE
    MOVLW   0X04
    MOVWF   JEFF
    MOVLW   0X82
    MOVWF   PORTC
    DECFSZ  NSY		
    RETFIE
    MOVLW   0X0A
    MOVWF   JEFF
    MOVLW   0X84
    MOVWF   PORTC
    DECFSZ  NSRR
    RETFIE
    GOTO    RECOUNT2
    
    
EWDIR:
    MOVLW   8
    MOVWF   ADD2
    MOVF    CAR2,0
    ANDWF   CAR1,0
    MOVWF   CAR3
    BTFSC   CAR3,0
    CLRF    ADD2
    MOVF    JEFF,0
    ADDWF   PCL,1
    NOP
    NOP
    NOP
    NOP			;Functionally this is the same as North South but the no ops are in place for lookup table functionality
    NOP			;this is because when another car comes we go to north and need to pick up at the green light from East West
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    MOVLW   0X10
    MOVWF   JEFF
    MOVLW   0X24
    MOVWF   PORTC
    DECFSZ  EWC
    RETFIE
    MOVLW   0X16
    MOVWF   JEFF
    MOVLW   0X44
    MOVWF   PORTC
    DECFSZ  EWY
    RETFIE
    MOVLW   0X1C
    MOVWF   JEFF
    MOVLW   0X84
    MOVWF   PORTC
    DECFSZ  EWRR
    RETFIE
    GOTO    RECOUNT
    
    
BOTH:
    MOVLW   4
    MOVWF   ADD2
    MOVF    JEFF,0
    ADDWF   PCL,1
    MOVLW   0X81
    MOVWF   PORTC
    DECFSZ  NSG
    RETFIE
    MOVLW   0X04
    MOVWF   JEFF
    MOVLW   0X82
    MOVWF   PORTC	    ;runs north south and east west code 
    DECFSZ  NSY
    RETFIE
    MOVLW   0X0A
    MOVWF   JEFF
    MOVLW   0X84
    MOVWF   PORTC
    DECFSZ  NSRR
    RETFIE
    CLRF    CAR1
    BTFSC   CAR2,0
    CLRF    ADD2
    MOVLW   0X10
    MOVWF   JEFF
    MOVLW   0X24
    MOVWF   PORTC
    DECFSZ  EWG
    RETFIE
    MOVLW   0X19
    MOVWF   JEFF
    MOVLW   0X44
    MOVWF   PORTC
    DECFSZ  EWY
    RETFIE
    MOVLW   0X1F
    MOVWF   JEFF
    MOVLW   0X84
    MOVWF   PORTC
    DECFSZ  EWRR
    RETFIE
    GOTO    RECOUNT
    
    
    
RECOUNT:
    MOVLW   109
    MOVWF   NSG
    MOVWF   EWG
    MOVWF   EWR		;this makes it so when we start again everything resets to defaults 
    MOVLW   22
    MOVWF   NSRR
    MOVWF   EWRR
    MOVWF   NSY
    MOVWF   EWY
    CLRF    JEFF
    CLRF    CAR1
    CLRF    CAR2
    CLRF    CAR3
    CLRF    ADD2
    RETFIE
    
    
RECOUNT2:
    MOVLW   109
    MOVWF   NSG
    MOVWF   EWG
    MOVWF   EWR
    MOVLW   22
    MOVWF   NSRR
    MOVWF   EWRR
    MOVWF   NSY
    MOVWF   EWY		;this one makes it so it is forced to start at east west in both after
    MOVLW   0X10
    MOVWF   JEFF
    CLRF    CAR1
    CLRF    CAR2
    CLRF    CAR3
    CLRF    ADD2
    RETFIE
    
    END