
; PIC16F883 Configuration Bit Settings

; Assembly source line config statements

#include "p16f883.inc"

; CONFIG1
; __config 0xE0F1
 __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

 
    ORG 0x000
    GOTO SETUP
    ORG 0x004
    RETFIE
  

SETUP:
;   MOVLW 0x60
;   MOVWF STATUS
    BSF STATUS,5 ;going to bank 3
    BSF STATUS,6
    CLRF INTCON   ;clearing registers
    CLRF OPTION_REG
    CLRF ANSELH
    CLRF TRISB
    
    
    BCF STATUS,5 ;going to bank 2
    BSF STATUS,6
    CLRF CM2CON1
   
    BSF STATUS,5 ;going to bank 1
    BCF STATUS,6
    CLRF WPUB	    ;clearing registers
    CLRF IOCB
    

   
    BCF STATUS,5 ;going to bank 0
    BCF STATUS,6
    CLRF CCP1CON
    CLRF PORTB	    ;clearing portB
    

    
   
;Main Program Loop (Loops forever) 
;MainLoop:
loop:
    INCF PORTB,1
    GOTO loop
;Subs below here
;SomeSub:
    ;NOP
    ;RETURN
    
    
    END ;End of code. This is required
