; PIC16F887 Configuration Bit Settings

#include "p16f887.inc"

; CONFIG1
; __config 0xE0D4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 

;				VARIABLES
;*******************************************************************************
GPR_VAR	    UDATA
TIEMPO_1    RES 1
TIEMPO_2    RES 1
W_TEMP	    RES 1
VAR_STATUS  RES 1
BANDERA	    RES 1
SERVO1	    RES 1
SERVO2	    RES 1
MOTORDC	    RES 1
   
   
	    
;				INTERRUPCIONES
;*******************************************************************************
 
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

ISR_VECT    CODE    0x0004

PUSH:
    BCF	    INTCON, GIE
    MOVWF   W_TEMP
    SWAPF   STATUS, W
    MOVWF   VAR_STATUS

ISR:
    BTFSC   PIR1, ADIF
    CALL    COSO_ADC	    ; CONVERSION
    BTFSC   INTCON, T0IF
    CALL    COSO_TMR0
    
POP:
    SWAPF   VAR_STATUS, W
    MOVWF   STATUS
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    RETFIE

;		    SUB-RUTINAS DE LA INTERRUPCION 
;*******************************************************************************
COSO_TMR0:
    BTFSC   PORTA, RA7
    GOTO    COSO_1
    BTFSC   PORTA, RA6
    GOTO    NIVEL_1
    RETURN
    
    COSO_1
    BTFSC   PORTA, RA6
    GOTO    NIVEL_3
    
    NIVEL_2
    
    RETURN
    
    NIVEL_3
    
    RETURN
    
    NIVEL_1
    
    RETURN

COSO_ADC:
   BTFSC    BANDERA, 0
   GOTO	    COSO2
   COSO1	     ; VARIAR EN QUE VARIABLE SE GUARDA EL VALOR Y EL CANAL	    
   MOVFW    ADRESH	   
   MOVWF    SERVO2	    ;VALOR DE ADRESH A VARIABLE ENVIAR
   BSF	    BANDERA, 0
   BSF	    ADCON0, 2
   CALL	    DELAY_2	; DARLE TIEMPO ANTES DE LA SIGUIENTE CONVERSION
   GOTO	    TERMINAR
   
   COSO2	    ; CONVERSION EN EL CANAL AN1
   MOVFW    ADRESH  ; GUARDAR VALOR EN LA VARIABLE PARA EL EJE Y
   MOVWF    SERVO1	  
   BCF	    BANDERA, 0
   BCF	    ADCON0, 2
   CALL	    DELAY_2
   
   TERMINAR
   BSF	    ADCON0, 1
   BCF	    PIR1, ADIF	    ;BANDERA TERMINAR CONVERSION
   RETURN

;				TABLA
;******************************************************************************* 
TABLA
;   87654321
;   .BAFGCDE
    ANDLW   B'00001111'		; 0-F
    ADDWF   PCL
    
    RETLW   B'10001000'		; 0	ABCDEF
    RETLW   B'10111011'		; 1	BC
    RETLW   B'10010100'		; 2	ABGED
    RETLW   B'10010001'		; 3	ABCDG
    RETLW   B'10100011'		; 4	BCFG
    RETLW   B'11000001'		; 5	ACDFG
    RETLW   B'11000000'		; 6	ACDEFG
    RETLW   B'10011011'		; 7	ABC
    RETLW   B'10000000'		; 8	ABCDEFG
    RETLW   B'10000001'		; 9	ABCDFG
    RETLW   B'10000010'		; A	ABCEFG
    RETLW   B'11100000'		; b	CDEFG
    RETLW   B'11001100'		; C	ADEF
    RETLW   B'10110000'		; d	BCDEG
    RETLW   B'11000100'		; E	ADEFG
    RETLW   B'11000110'		; F	AEFG
    RETURN
    
;			    PRINCIPAL 
;****************************************************************************
MAIN_PROG   CODE

START			    ; CONFIGURACIONES
   CALL	    CONFIG_IO
   CALL	    UGHHHHHH
   CALL	    CONFIG_ADC
   CALL	    CONFIG_INTERRUPT
   GOTO	    LOOP
   CALL	    CONFIG_PWM
   GOTO	    LOOP
   
LOOP:
    RRF	    SERVO1, 0
    ANDLW   b'01111111'
    ADDLW   .32
    MOVWF   CCPR1L
    
    RRF	    SERVO2, 0
    ANDLW   b'01111111'
    ADDLW   .32
    MOVWF   CCPR2L
    
    BSF	    ADCON0, GO
    GOTO    LOOP
    
;				CONFIGURACIONES
;*******************************************************************************
UGHHHHHH:
    BSF	STATUS,RP0
    MOVLW   .187
    MOVWF   PR2
    BCF	    STATUS,RP0
    MOVLW   0x9d
    MOVWF   CCPR1L
    BCF	    CCP1CON,7
    BCF	    CCP1CON,6
    BCF	    CCP1CON,5 
    BCF	    CCP1CON,4
    BSF	    CCP1CON,3
    BSF	    CCP1CON,2
    BCF	    CCP1CON,1
    BCF	    CCP1CON,0

    MOVLW   0x20
    MOVWF   CCPR2L
    BSF	    CCP2CON,5
    BCF	    CCP2CON,4
    BSF	    CCP2CON,3   
    BSF	    CCP2CON,2
    BSF	    CCP2CON,1
    BSF	    CCP2CON,0
	
    BANKSEL OPTION_REG
    CLRWDT
    MOVLW   b'01010111'
    MOVWF   OPTION_REG	
    BANKSEL PORTA
    MOVLW   .255
    MOVWF   T2CON
    RETURN
    
    
CONFIG_TMR1			    ; 1 SEGUNDO PARA LEDS
    BANKSEL PORTA
    CLRF    T1CON
    BSF	    T1CON, 0
    BCF	    T1CON, 1
    BCF	    T1CON, 3
    BSF	    T1CON, 4
    BSF	    T1CON, 5
    RETURN
    
CONFIG_IO
   BANKSEL  ANSEL
   CLRF	    ANSEL
   BSF	    ANSEL, 0	; CONFIGURAR ANSEL PARA EL CANAL AN0 Y AN1
   BSF	    ANSEL, 1
   CLRF	    ANSELH
   BANKSEL  TRISA
   CLRF	    TRISA
   COMF	    TRISA	; PONER COMO INPUT EL PUERTO A
   CLRF	    TRISC	; COLOCAR PUERTOS COMO SALIDAS
   CLRF	    TRISD
   BANKSEL  PORTD
   CLRF	    PORTA
   CLRF	    PORTC
   CLRF	    PORTD
   RETURN

   
CONFIG_ADC:		    ; CONFIGURACION ADC
   BANKSEL  ADCON1
   CLRF	    ADCON1
   BANKSEL  ADCON0
   MOVLW    B'10000111'	    ; CANAL INICIAL AN1
   MOVWF    ADCON0
   RETURN
    
CONFIG_INTERRUPT:
    BANKSEL TRISA
    BSF	    PIE1, ADIE
    BSF	    INTCON, PEIE
    BSF	    INTCON, T0IE
    
    BANKSEL PORTA
    BCF	    INTCON, T0IF
    BSF	    INTCON, GIE
    RETURN
    
    DELAY_1		    ; DELAYS
    MOVLW   .250
    MOVWF   TIEMPO_1
    CONFIG1:
    CALL    DELAY_2
    DECFSZ  TIEMPO_1, F
    GOTO    CONFIG1
    RETURN

    DELAY_2
    MOVLW   .250
    MOVWF    TIEMPO_2
    CONFIG2:
    DECFSZ  TIEMPO_2, F
    GOTO    CONFIG2
    RETURN
   
;PWM PERIODO = (PR2 + 1) * 4 * Tosc * Prescaler
;20mS = (1249 + 1) * 4 * (1/4MHZ) * 16
;31 - 63
CONFIG_PWM:
    MOVLW   B'000111'
    MOVWF   CCPR1L
    MOVLW   B'00111111'
    MOVWF   CCP1CON
    
    
    MOVLW   B'000111'
    MOVWF   CCPR2L
    MOVLW   B'00111111'
    MOVWF   CCP2CON
    RETURN

END