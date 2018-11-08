#include p18f87k22.inc

    global	ADC_Setup, ADC_Read
    extern	delay, LCD_Write_Hex, tmpval

		
ADC    code
    
ADC_Setup
    bsf	    TRISA,RA3	    ; use pin A0(==AN0) for input
    bsf	    ANCON0,ANSEL3   ; set A0 to analog
    movlw   b'00001101'	    ; select AN0 for measurement
    movwf   ADCON0	    ; and turn ADC on
    movlw   0x30	    ; Select 4.096V positive reference
    movwf   ADCON1	    ; 0V for -ve reference and -ve input
    movlw   0xF6	    ; Right justified output
    movwf   ADCON2	    ; Fosc/64 clock and acquisition times
    return

ADC_Read
    bsf	    ADCON0,GO	    ; Start conversion
adc_loop
    btfsc   ADCON0,GO	    ; check to see if finished
    bra	    adc_loop
    return
    
    end