#include p18f87k22.inc
    
	global	LCD_Alg, tempL, tempH, TempIn_Alg, Time_alg, TimeDesL, TimeDesH, Power_Alg
	extern	offset, numbL, T_CrntH, T_CrntL, numbH, ru
	extern	M_16x16, M_SelectHigh, LCD_Send_Byte_D, M_Move, M_8x24
	extern	hundreds, tens, units, offset, UART_Transmit_Byte
	extern	DataLow, DataHigh, DataUp, DataTop
	
acs0	    udata_acs		    ; reserve data space in access ram	
tempL	    res 1		    ; reserve 3 bytes for tempory values
tempH	    res 1	
tempU	    res 1
temp	    res 1
Tdec	    res 1		    ; for power alg - decimal time difference
Tunit	    res 1		    ; for power alg - units time difference
Tten	    res 1		    ; for power alg - tens time difference
Temporary   res 1		    ; temp value storage space
TempCD	    res 1		    ; current temp. (decimals)
TempCU	    res 1		    ; current temp. (units)
TempCT	    res 1		    ; current temp. (tens)
TimeDesL    res 1
TimeDesH    res 1
Algorithms  code
  
LCD_Alg				    ;follows procedure as outlined in lec9
	movf	ADRESL, W	    ;Takes a hex number from LM35
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
	movff	ru, TempCT
	call	LCD_Send_Byte_D
	call	M_Move
	call	M_8x24
	call	M_SelectHigh
	movwf	DataHigh
	movff	ru, TempCU
	call	LCD_Send_Byte_D
	call	M_Move
	movlw	'.'			; Forcing a decimal place into the LCD
	call	LCD_Send_Byte_D
	call	M_8x24
	call	M_SelectHigh
	movwf	DataLow
	movff	ru, TempCD
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
	
Power_Alg			    ; input temp is in hundreds, tens, units
				    ; current temp is in TempCT, TempCU, TempCD
	clrf	TimeDesL
	clrf	TimeDesH
	movf	TempCD, W	    
	movff	units, Temporary
	subwf	Temporary, f	    ; subtract the decimal temp contributions...
	movff	Temporary, Tdec	    ; ...to get temp difference (decimal)
	movf	TempCU, W
	movff	tens, Temporary 
	subwfb	Temporary, f	    ; sub with borrow the units temp contrib... 
	movff	Temporary, Tunit    ; ...to get temp difference (units)
	movf	TempCT, W
	movff	hundreds, Temporary
	subwfb	Temporary, f	    ; sub with borrow the tens temp contrib...
	movff	Temporary, Tten	    ; ...to get temp difference (tens)
	movf	Tten, W
	mullw	0x0A		    ; multiply the tens column by 10...
	movf	PRODL, W
	addwf	Tunit, f	    ; ...and add this to the units...
	movf	Tunit, W	    ; ...to get integer temp difference
	mullw	0x28		    ; multiply by .40 to get a time difference
	movff	PRODL, TimeDesL
	movff	PRODH, TimeDesH
	movf	Tdec, W		    ; now we deal with the decimal temp difference
	mullw	0x04		    ; multiply by 4...
	movf	PRODL, W	    ; ...to get the additional time difference
	addwf	TimeDesL, f	    ; add this contribution in 
	movlw	0x0
	addwfc	TimeDesH, f	    ; add a carry if needed from the decimal contrib.
	return	
	
	end