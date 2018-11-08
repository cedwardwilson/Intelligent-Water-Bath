#include p18f87k22.inc

    global	ADC_Setup, ADC_Read, M_Table
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
    
M_Table			    ;lookup table (basically)
    movlb   6		    ;use Bank 6
    lfsr    FSR2, 0x680	    ;start at 0x680 address in Bank 6
    movlw   '1'		    ;ascii characters into files in Bank 6
    movwf   tmpval
    movlw   0x1
    movff   tmpval,PLUSW2
    movlw   '2'
    movwf   tmpval
    movlw   0x2
    movff   tmpval,PLUSW2
    movlw   '3'
    movwf   tmpval
    movlw   0x3
    movff   tmpval,PLUSW2
    movlw   '4'
    movwf   tmpval
    movlw   0x4
    movff   tmpval,PLUSW2
    movlw   '5'
    movwf   tmpval
    movlw   0x5 
    movff   tmpval,PLUSW2
    movlw   '6'
    movwf   tmpval
    movlw   0x6
    movff   tmpval,PLUSW2
    movlw   '7'
    movwf   tmpval
    movlw   0x7
    movff   tmpval,PLUSW2
    movlw   '8'
    movwf   tmpval
    movlw   0x8
    movff   tmpval,PLUSW2
    movlw   '9'
    movwf   tmpval
    movlw   0x9
    movff   tmpval,PLUSW2
    movlw   '0'
    movwf   tmpval
    movlw   0x0
    movff   tmpval,PLUSW2
    return

end