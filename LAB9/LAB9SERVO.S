;===============================================================================
    ;Rudy Earnest
    ;RCET 3375
    ;Fall 2025
    ;Experiment9 UART comms Servo control
;===============================================================================
    
;Configuration
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
  ;Include Statments
#include <xc.inc>
#include <pic16f883.inc>
;===============================================================================
  ;Register Setup
;===============================================================================
PW_ON	    EQU 0X20
PS_ON	    EQU 0X21
PERIOD	    EQU 0X22
PCOUNT_SKIP EQU	0X23
PW_COUNT    EQU 0X24
PS_COUNT    EQU 0X25
WTS	    EQU 0X26
ADC_HIGH    EQU 0X27
ADC_LOW	    EQU 0X28
STATUS_SAVE EQU 0X29
W_SAVE	    EQU 0X2A
RX_SAVE	    EQU 0X2B
JEFF	    EQU 0X2C
	    

    ;Start of Program
PSECT resetVect,class=CODE,delta=2
    GOTO SETUP
    
PSECT isrVect,class=CODE,delta=2
    GOTO ISR_VECT
    
PSECT code,class=CODE,delta=2
;===============================================================================
 ;Setup Code
;===============================================================================
SETUP:
    ;ensuring interrupts are off
    CLRF    INTCON
    
    ;Bank 0
    BCF	    STATUS,5
    BCF	    STATUS,6
    
    ;Clearing made registers
    CLRF    PW_ON
    CLRF    PS_ON
    CLRF    PERIOD
    CLRF    PCOUNT_SKIP
    CLRF    PW_COUNT
    CLRF    PS_COUNT
    CLRF    WTS
    CLRF    ADC_HIGH
    CLRF    ADC_LOW
    CLRF    STATUS_SAVE
    CLRF    W_SAVE
    CLRF    RX_SAVE
    CLRF    JEFF
    
    ;Setting Period to static 200uS
    MOVLW   200
    MOVWF   PERIOD
    
    ;Bank 1
    BSF	    STATUS,5
    BCF	    STATUS,6
    
    ;Adc Setup
    CLRF    ADCON1
    
    ;Set timer count to
    MOVLW   100
    MOVWF   PR2
    
    ;TX setup
    MOVLW   0x26
    MOVWF   TXSTA
    
    ;Enable Pin 0 of PORTA as input
    MOVLW   0x01
    MOVWF   TRISA
    
    ;PORTC and PORTB as outputs
    CLRF    TRISB
    CLRF    TRISC
    
    ;Enable Interrupts
    MOVLW   0x22
    MOVWF   PIE1
    
    ;Set SPBRGH and SPBRG
    MOVLW   25
    MOVWF   SPBRGH
    MOVWF   SPBRG
    
    ;Clearing stuff in Bank 2
    BCF	    STATUS,5
    BSF	    STATUS,6
    CLRF    CM2CON1
    
    ;Bank 3
    BSF	    STATUS,5
    BSF	    STATUS,6
    
    ;Baud setup
    MOVLW   0x01
    MOVWF   BAUDCTL
    
    ;Setting PORTA 0 as ADC clearing adc's for others
    CLRF    ANSELH
    MOVLW   0x01
    MOVWF   ANSEL
    
    ;More Bank 0 setup 
    BCF	    STATUS,5
    BCF	    STATUS,6
    
    ;INIT ADC
    MOVLW   0x43
    MOVWF   ADCON0
    
    ;INIT Timer 2
    MOVLW   0x04
    MOVWF   T2CON
    
    ;RX setup
    MOVLW   0x90
    MOVWF   RCSTA
    
    ;Cearing Ports
    CLRF    PORTA
    CLRF    PORTB
    CLRF    PORTC
    
    ;Interrupt enables
    CLRF    PIR1
    MOVLW   0xC0
    MOVWF   INTCON
    
    ;Enable first GO of ADC
    BSF	    ADCON0,0
    BSF	    ADCON0,1
    
    GOTO    MAIN
    
;===============================================================================
 ;Main Code
;===============================================================================
 
MAIN:
  ADCPOLLING:
    ;Checks to see if the ADC is done continuously
    BTFSC   ADCON0,1
    GOTO    ADCPOLLING
    
  MoveADCToRegisters:
    ;ADRESH in bank 0 easy move
    MOVF    ADRESH,0
    MOVWF   ADC_HIGH
    
    ;ADRESL in bank 1 not so easy
    BSF	    STATUS,5
    MOVF    ADRESL,0
    BCF	    STATUS,5
    MOVWF   ADC_LOW
    
    BTFSC   JEFF,0
    CALL    WORKPLS
    
    ;Restart the ADC conversion
    BSF	    ADCON0,1
    
    GOTO    MAIN
    
    
  WORKPLS:
     ;HandShake?
    MOVF   RX_SAVE,0
    XORLW   0x24
    BTFSC   STATUS,2
    GOTO    HANDSHAKE
    
    ;Send ADC?
    MOVF    RX_SAVE,0
    XORLW   0x3C
    BTFSC   STATUS,2
    GOTO    SEND_ADC
    
    ;Anything Else should be servo data
    BTFSS   STATUS,2
    GOTO    SUPPLIED_SERVO
    
    GOTO    TX_END
    
    HANDSHAKE:
    ;send a $
    MOVLW   0x24
    MOVWF   TXREG
    BSF	    WTS,0
    BCF	    PIR1,5
    GOTO    TX_END
    
    SEND_ADC:
    ;send high byte and low byte of ADC
    MOVF    ADC_HIGH,0
    MOVWF   TXREG
    
    ;polling to see when we can send again
    BTFSS   PIR1,4
    GOTO    $-1
    
    MOVF    ADC_LOW,0
    MOVWF   TXREG
    
    ;clearing adc registers
    CLRF    ADC_HIGH
    CLRF    ADC_LOW
    BCF	    PIR1,5
    
    GOTO    TX_END
    
    SUPPLIED_SERVO:
    ;cannot do this unless there was a hand shake
    MOVLW   0
    BTFSS   WTS,0
    MOVLW   11
    ADDWF   PCL,1
    CLRF    PCOUNT_SKIP
    BTFSC   RX_SAVE,0
    CALL    RX_SAVE_0
    BTFSC   RX_SAVE,1
    CALL    RX_SAVE_1
    BTFSC   RX_SAVE,2
    CALL    RX_SAVE_2
    BTFSC   RX_SAVE,3
    CALL    RX_SAVE_3
    BTFSC   RX_SAVE,4
    CALL    RX_SAVE_4
    BCF	    PIR1,5
    GOTO    TX_END
    
      RX_SAVE_0:
    MOVLW   2
    ADDWF   PCOUNT_SKIP,1
    RETURN
    
      RX_SAVE_1:
    MOVLW   4
    ADDWF   PCOUNT_SKIP,1
    RETURN
    
      RX_SAVE_2:
    MOVLW   8
    ADDWF   PCOUNT_SKIP,1
    RETURN
    
      RX_SAVE_3:
    MOVLW   16
    ADDWF   PCOUNT_SKIP,1
    RETURN
    
      RX_SAVE_4:
    MOVLW   32
    ADDWF   PCOUNT_SKIP,1
    RETURN
    
  TX_END:
    BCF	    JEFF,0
    RETURN
    
;===============================================================================
    ;ISR Stuff
;===============================================================================
ISR_VECT:
    BSF	    PORTB,0
    ;Save Status and W
    MOVWF   W_SAVE
    MOVF    STATUS,0
    MOVWF   STATUS_SAVE
    
    ;Make sure we are in bank 0
    BCF	    STATUS,5
    BCF	    STATUS,6
    
    ;Check Flags
    BTFSC   PIR1,5
    GOTO    RX_ISR
    BTFSC   PIR1,1
    GOTO    TIMER_ISR
    
    ;If we somehow get here
    GOTO    END_ISR
    
  RX_ISR:
    BSF	    PORTB,2
    ;get the recieved data out of the register
    ;this also clears the flag
    MOVF    RCREG,0
    MOVWF   RX_SAVE
    BSF	    JEFF,0
    GOTO    END_ISR
   
    
    
  TIMER_ISR:
    ;checking to see if we are on the Pulse Width cycle
    ;or the PS cycle if both are not set then we
    ;check to see what they should be
    BCF	    PIR1,1
    BTFSC   PW_ON,0
    GOTO    PW_TIME
    
    BTFSC   PS_ON,0
    GOTO    PS_TIME
    
    ;lookup table to give set values to do the Pulse space calculation
    ;the PCOUNT_SKIP is set by weighted bits from calculation sent back
    ;based off of the ADC set position
    MOVF    PCOUNT_SKIP,0
    ADDWF   PCL,1
    
    MOVLW   5
    GOTO    PS_CALC
    MOVLW   5
    GOTO    PS_CALC
    MOVLW   6
    GOTO    PS_CALC
    MOVLW   6
    GOTO    PS_CALC
    MOVLW   7
    GOTO    PS_CALC
    MOVLW   8
    GOTO    PS_CALC
    MOVLW   9
    GOTO    PS_CALC
    MOVLW   10
    GOTO    PS_CALC
    MOVLW   10
    GOTO    PS_CALC
    MOVLW   11
    GOTO    PS_CALC
    MOVLW   11
    GOTO    PS_CALC
    MOVLW   12
    GOTO    PS_CALC
    MOVLW   12
    GOTO    PS_CALC
    MOVLW   13
    GOTO    PS_CALC
    MOVLW   13
    GOTO    PS_CALC
    MOVLW   14
    GOTO    PS_CALC
    MOVLW   14
    GOTO    PS_CALC
    MOVLW   15
    GOTO    PS_CALC
    MOVLW   15
    GOTO    PS_CALC
    MOVLW   16
    GOTO    PS_CALC
    MOVLW   17
    GOTO    PS_CALC
    MOVLW   18
    GOTO    PS_CALC
    MOVLW   19
    GOTO    PS_CALC
    MOVLW   20
    GOTO    PS_CALC
    MOVLW   20
    GOTO    PS_CALC
    MOVLW   21
    GOTO    PS_CALC
    MOVLW   22
    GOTO    PS_CALC
    MOVLW   23
    GOTO    PS_CALC
    MOVLW   23
    GOTO    PS_CALC
    MOVLW   24
    GOTO    PS_CALC
    MOVLW   25
    GOTO    PS_CALC
    MOVLW   25
    GOTO    PS_CALC
    
    PS_CALC:
    ;This puts the value from the above lookup table into PW
    ;this is then subtracted from the static Period value
    MOVWF   PW_COUNT
    MOVF    PW_COUNT,0
    SUBWF   PERIOD,0
    MOVWF   PS_COUNT
    GOTO    PW_TIME
    
    PW_TIME:
    ;decreases PW_ON based off of timer2 timing with PORTA 1 on
    BCF	    PIR1,1
    BSF	    PW_ON,0
    BSF	    PORTA,1
    DECFSZ  PW_COUNT,1
    GOTO    END_ISR
    BCF	    PW_ON,0
    BSF	    PS_ON,0
    GOTO    PS_TIME
 
    PS_TIME:
    ;decreases PS_ON based off of timer2 timing with PORTA 1 off
    BCF     PIR1,1
    BSF	    PS_ON,0
    BCF	    PORTA,1
    DECFSZ  PS_COUNT,1
    GOTO    END_ISR
    BCF	    PS_ON,0
    GOTO    END_ISR
    
  END_ISR:
    CLRF    PORTB
    ;this ends the ISR Vect
    MOVF    STATUS_SAVE,0
    MOVWF   STATUS
    MOVF    W_SAVE,0
    RETFIE
    
 End