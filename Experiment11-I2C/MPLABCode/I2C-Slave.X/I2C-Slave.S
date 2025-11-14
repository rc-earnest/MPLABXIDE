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
SSP_SAVE	EQU 0x20
SERVO1		EQU 0x21
SERVO2		EQU 0x22
SERVO3		EQU 0x23
PERIOD		EQU 0x24
TEMP		EQU 0x25

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
    
    MOVLW   100
    MOVWF   PR2
    BSF	    PIE1,1
    
    ;Bank 0
    BCF	    STATUS,5
    BCF	    STATUS,6
    CLRF    PORTB
    
    BCF	    SSPCON,3
    BSF	    SSPCON,2
    BSF	    SSPCON,1
    BCF	    SSPCON,0
    
    BSF	    SSPCON,5
    
    MOVLW   1
    MOVWF   PERIOD
//    
//    MOVLW   170
//    MOVWF   SERVO1
//    MOVLW   195
//    MOVWF   SERVO2
//    MOVLW   175
//    MOVWF   SERVO3
    
    MOVLW   0x04
    MOVWF   T2CON
    
    BCF	    PIR1,1
    BCF	    PIR1,3
    BSF	    INTCON,6
    BSF	    INTCON,7
    
    GOTO    MAIN
    
MAIN:
    GOTO    MAIN
    
    
ISR_VECT:
    BCF	    STATUS,5
    BCF	    STATUS,6
    BTFSC   PIR1,3
    GOTO    ADDR
    BTFSC   PIR1,1
    GOTO    T2_ISR
    GOTO    END_ISR
    
T2_ISR:
    BCF	    PIR1,1
    DECFSZ  PERIOD
    GOTO    CHECK_ISR
    MOVLW   200
    MOVWF   PERIOD
    BSF	    PORTB,0
    BSF	    PORTB,1
    BSF	    PORTB,3
    GOTO    END_ISR
    
CHECK_ISR:
    MOVF    PERIOD,0
    SUBWF   SERVO1,0
    BTFSC   STATUS,2
    BCF	    PORTB,0
    
    MOVF    PERIOD,0
    SUBWF   SERVO2,0
    BTFSC   STATUS,2
    BCF	    PORTB,1
    
    MOVF    PERIOD,0
    SUBWF   SERVO3,0
    BTFSC   STATUS,2
    BCF	    PORTB,3
    
    GOTO    END_ISR
    
ADDR:
    MOVF    SSPBUF,0
    BCF	    PIR1,3
    BTFSC   SSPBUF,0
    GOTO    READ
    GOTO    WRITE
    GOTO    END_ISR
    
READ:
    GOTO    END_ISR
    
WRITE:
    BSF	    STATUS,5
    BCF	    STATUS,6
    BTFSS   SSPSTAT,5
    GOTO    END_ISR
    BCF	    STATUS,5
    BCF	    STATUS,6
    MOVWF   SSP_SAVE
    BTFSC   SSP_SAVE,7
    CALL    S_1
    BTFSC   SSP_SAVE,6
    CALL    S_2
    BTFSC   SSP_SAVE,5
    CALL    S_3
    BSF	    STATUS,5
    BCF	    STATUS,6
    BTFSC   SSPSTAT,4
    GOTO    END_ISR
    BCF	    SSPCON2,5
    BSF	    SSPCON2,4
    GOTO    END_ISR
    
    
S_1:
    CALL    CONVERSION
    MOVWF   SERVO1
    RETURN
    
S_2:
    CALL    CONVERSION
    MOVWF   SERVO2
    RETURN
    
S_3:
    CALL    CONVERSION
    MOVWF   SERVO3
    RETURN
    
    
    
CONVERSION:
    MOVLW   0
    BTFSC   SSP_SAVE,0
    ADDLW   2
    BTFSC   SSP_SAVE,1
    ADDLW   4
    BTFSC   SSP_SAVE,2
    ADDLW   8
    BTFSC   SSP_SAVE,3
    ADDLW   16
    BTFSC   SSP_SAVE,4
    ADDLW   32
    MOVWF   TEMP
    
    MOVF    TEMP,0
    ADDWF   PCL,1
    
    MOVLW   170
    RETURN
    MOVLW   170
    RETURN
    MOVLW   171
    RETURN
    MOVLW   171
    RETURN
    MOVLW   172
    RETURN
    MOVLW   172
    RETURN
    MOVLW   173
    RETURN
    MOVLW   173
    RETURN
    MOVLW   174
    RETURN
    MOVLW   174
    RETURN
    MOVLW   175
    RETURN
    MOVLW   176
    RETURN
    MOVLW   177
    RETURN
    MOVLW   178
    RETURN
    MOVLW   179
    RETURN
    MOVLW   180
    RETURN
    MOVLW   181
    RETURN
    MOVLW   182
    RETURN
    MOVLW   183
    RETURN
    MOVLW   184
    RETURN
    MOVLW   185
    RETURN
    MOVLW   186
    RETURN
    MOVLW   187
    RETURN
    MOVLW   188
    RETURN
    MOVLW   189
    RETURN
    MOVLW   190
    RETURN
    MOVLW   191
    RETURN
    MOVLW   192
    RETURN
    MOVLW   193
    RETURN
    MOVLW   194
    RETURN
    MOVLW   195
    RETURN
    MOVLW   195
    RETURN
    MOVLW   195
    RETURN
    MOVLW   195
    RETURN
    MOVLW   195
    RETURN
    
END_ISR:
    BCF	    STATUS,5
    BCF	    STATUS,6
    RETFIE
    END