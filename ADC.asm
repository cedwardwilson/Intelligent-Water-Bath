#include p18f87k22.inc

    global	ADC_Setup, ADC_Read, M_16x16, M_8x24, numbH, numbL, numbU, M_SelectHigh, M_Move
    extern	delay, LCD_Write_Hex, tmpval

acs0    udata_acs 
;below we resevre all the variables yhat are relevant to ADC calculations
numa		res 1
numbH		res 1
numbL		res 1
numbU		res 1
numcH		res 1
numcL		res 1
tmpnumLL	res 1
tmpnumLH	res 1
tmpnumLU	res 1
tmpnumHL	res 1
tmpnumHH	res 1
tmpnumHU	res 1
tmpnumUL	res 1
tmpnumUH	res 1
tmpnumUU	res 1
rb		res 1	   
rl		res 1	    
rh		res 1	    
ru		res 1
rt		res 1
purse		res 1
		
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

M_16x16				;multiplies a 16-bit by a 16-bit 
    call    M_16Setup		;and stores output as 3 bytes (rb, rh, ru)
    movff   numcL, numa
    call    M_CalculateL
    movff   numcH, numa
    call    M_CalculateH
    call    M_addHL16
    return
  
M_8x24				;multiplies an 8-bit by a 24-bit
    call    M_24Setup		;and stores output as 4 bytes (rb, rh, ru, rt)
    call    M_CalculateL
    call    M_CalculateU
    call    M_addHL24
    return
  
M_16Setup			;must run before a 16-bit by 16-bit multiply
    call    M_Table
    clrf    tmpnumLL		;ensure the temporary memeory locations clear
    clrf    tmpnumLH
    clrf    tmpnumLU
    clrf    tmpnumHL
    clrf    tmpnumHH
    clrf    tmpnumHU	
    movlw   0x8A		;k value stored as 2 bytes
    movwf   numcL
    movlw   0x41
    movwf   numcH
    return
  
M_24Setup			;must run before 1n 8-bit by 24-bit multiply
    call    M_Table
    clrf    tmpnumLL
    clrf    tmpnumLH
    clrf    tmpnumLU
    clrf    tmpnumHL
    clrf    tmpnumHH
    clrf    tmpnumHU	
    movlw   0x0A
    movwf   numa
    return
  
M_CalculateL
    movf    numa, W
    mulwf   numbL
    movff   PRODL, tmpnumLL
    movff   PRODH, purse
    mulwf   numbH
    movf    purse, W
    addwf   PRODL, W
    movwf   tmpnumLH
    movf    PRODH, W
    addwfc  tmpnumLU, f
    return
  
M_CalculateH
    movf    numa, W
    mulwf   numbL
    movff   PRODL, tmpnumHL
    movff   PRODH, purse
    mulwf   numbH
    movf    purse, W
    addwf   PRODL, W
    movwf   tmpnumHH
    movf    PRODH, W
    addwfc  tmpnumHU, f
    return
  
M_CalculateU
    movf    numa, W
    mulwf   numbU
    movff   PRODL, tmpnumUL
    movff   PRODH, tmpnumUH
    return
 
M_addHL16			;addition to give final 16x16 bit calculation
    movff   tmpnumLL, rb
    movf    tmpnumLH, w
    addwf   tmpnumHL, w
    movwf   rl
    movf    tmpnumLU,w
    addwfc  tmpnumHH, f
    movff   tmpnumHH, rh
    movlw   0x0
    addwfc  tmpnumHU, f
    movff   tmpnumHU, ru
    return
  
M_addHL24			;addition to give final 8x24 bit calculation
    movff   tmpnumLL, rb
    movff   tmpnumLH, rl
    movf    tmpnumLU, W
    addwf   tmpnumUL, f
    movff   tmpnumUL, rh
    movlw   0x0
    addwfc  tmpnumUH, f
    movff   tmpnumUH, ru
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

M_SelectHigh	    		   ;grabs top byte of result of latest multiply
    movf    ru, W, ACCESS	   ;ru is upper byte of the result  
    movff   PLUSW2, purse	   ;puts value at fsr2+w into purse  	
    call    delay			
    movf    purse, W
    return

M_Move				    ;moves latest result into correct bytes 
    movff   rb, numbL		    ;so it can be used again in following calc
    movff   rl, numbH
    movff   rh, numbU
    return
    end