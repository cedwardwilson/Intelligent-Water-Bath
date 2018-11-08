#include p18f87k22.inc
    
	global	LCD_Alg, tempL, tempH, TempIn_Alg
	extern	offset, numbL, T_CrntH, T_CrntL, numbH
	extern	M_16x16, M_SelectHigh, LCD_Send_Byte_D, M_Move, M_8x24
	extern	hundreds, tens, units, offset
	
acs0	    udata_acs		    ; reserve data space in access ram	
tempL	    res 1		    ; reserve 3 bytes for tempory values
tempH	    res 1	
tempU	    res 1
temp	    res 1
Algorithms  code
  
LCD_Alg				    ;follows procedure as outlined in lec9
	movf	ADRESL, W	    ;Takes a hex numbert from LM35
	movwf	temp
	movwf	T_CrntL
	movf	offset, W	    ; offset is the voltage LM35 reads at 0K
	subwf	temp, f		    ;subtract the offset voltage from LM35 value
	movf	temp, W		    ;move this new voltage into temp
	movwf	numbL
	movf	ADRESH, W
	movwf	temp
	movwf	T_CrntH
	movlw	0x0
	subwfb	temp,f
	movf	temp, W
	movwf	numbH
	call	M_16x16
	call	M_SelectHigh
	call	LCD_Send_Byte_D
	call	M_Move
	call	M_8x24
	call	M_SelectHigh
	call	LCD_Send_Byte_D
	call	M_Move
	call	M_8x24
	call	M_SelectHigh
	call	LCD_Send_Byte_D
	call	M_Move
	movlw	'.'			; Forcing a decimal place into the LCD
	call	LCD_Send_Byte_D
	call	M_8x24
	call	M_SelectHigh
	call	LCD_Send_Byte_D
	return

TempIn_Alg		;converts input temperature to a comparable hex voltage
	clrf	tempL
	clrf	tempH
	clrf	tempU
	movf	tens, W		
	mullw	0x0A		    ;multiply 'tens' column by ten
	movf	PRODL, W	    
	movwf	tempL
	movf	units, W	    ;add the 'units' column to this 
	addwf	tempL
	movf	hundreds, W	    
	mullw	0x64		    ;multiply the 'hundreds' column by 100
	movf	PRODL, W
	addwf	tempL		    ;this is the low byte of our mV reading
	movf	PRODH, W
	addwfc	tempH, f	    ;this is the high byte of our mV reading 
	movf	offset, W
	addwf	tempL		    ;removes the offset
	movlw	0x0
	addwfc	tempH
	return 
	
	end