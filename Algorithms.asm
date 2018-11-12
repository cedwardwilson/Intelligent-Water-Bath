#include p18f87k22.inc
    
	global	LCD_Alg, tempL, tempH, TempIn_Alg, Time_alg, TimeDesL, TimeDesH
	extern	offset, numbL, T_CrntH, T_CrntL, numbH
	extern	M_16x16, M_SelectHigh, LCD_Send_Byte_D, M_Move, M_8x24
	extern	hundreds, tens, units, offset, UART_Transmit_Byte
	extern	DataLow, DataHigh, DataUp, DataTop
	
acs0	    udata_acs		    ; reserve data space in access ram	
tempL	    res 1		    ; reserve 3 bytes for tempory values
tempH	    res 1	
tempU	    res 1
temp	    res 1
TimeDesL	    res 1
TimeDesH	    res 1
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
	movwf	DataTop
	call	LCD_Send_Byte_D
	call	M_Move
	call	M_8x24
	call	M_SelectHigh
	movwf	DataUp
	call	LCD_Send_Byte_D
	call	M_Move
	call	M_8x24
	call	M_SelectHigh
	movwf	DataHigh
	call	LCD_Send_Byte_D
	call	M_Move
	movlw	'.'			; Forcing a decimal place into the LCD
	call	LCD_Send_Byte_D
	call	M_8x24
	call	M_SelectHigh
	movwf	DataLow
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
	
Time_alg
	clrf	TimeDesL
	clrf	TimeDesH
	movf	units, W	    ; multiply units by 6 (as 0.1 min * 6 = no. of secs)
	mullw	0x06
	movf	PRODL, W
	movwf	TimeDesL	    ; puts low byte of this into timeL, high byte is always 0
	movf	tens, W		    ; multiply tens by 60 (1 min = 60 secs)
	mullw	0x3C
	movf	PRODL, W	    ; low byte adds to timeL
	addwf	TimeDesL
	movf	PRODH, W	    ; high byte adds to timeH (with carry, just in case)
	addwfc	TimeDesH
	movf	hundreds, W	    ; 16x8 bit calculation: takes hundreds and
	mullw	0x58		    ; multiplies by low byte of .600
	movf	PRODL, W
	addwf	TimeDesL	    ; low byte of this into timeL
	movf	PRODH, W
	addwfc	TimeDesH	    ; high byte (with carry) into timeH
	movf	hundreds, W
	mullw	0x02		    ; multiplies hundreds by high byte of .600
	movf	PRODL, W
	addwfc	TimeDesH	    ; puts low byte of that into timeU
        return
	
	end