#include p18f87k22.inc
; File Overview:
; Contains Analogue to Digital Converter set up and read functions
    
    ; Global routines/variables
    global	ADC_Setup, ADC_Read
	
ADC    code

    ; ACD_Setup:
    ; Runs as part of the setup of the system
ADC_Setup
    bsf	    TRISA,RA3	    ; Use pin A0(==AN0) for input
    bsf	    ANCON0,ANSEL3   ; Set A0 to analog
    movlw   b'00001101'	    ; Select AN0 for measurement...
    movwf   ADCON0	    ; ...And turn ADC on
    movlw   0x30	    ; Select 4.096V positive reference
    movwf   ADCON1	    ; 0V for -ve reference and -ve input
    movlw   0xF6	    ; Right justified output
    movwf   ADCON2	    ; Fosc/64 clock and acquisition times
    return
    
    ; ACD_Read:
    ; Converts analogue to digital, as read off of pin A0
ADC_Read
    bsf	    ADCON0,GO	    ; Start conversion
adc_loop
    btfsc   ADCON0,GO	    ; Check to see if finished
    bra	    adc_loop
    return
    
    end