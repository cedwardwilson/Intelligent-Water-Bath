#include p18f87k22.inc
; File Overview:
; Contains 4 algorithms: LCD_Alg, TempIn_Alg, Time_alg, Power_Alg
	
	; External and global routines/variables
	global	tempL, tempH, TimeDesL, TimeDesH
	global	Power_Alg, PowerCheck, LCD_Alg, TempIn_Alg, Time_alg
	extern	offset, numbL, numbH, T_CrntH, T_CrntL, tens, units, decimals
	extern	DataLow, DataHigh, DataUp, DataTop, ru
	extern	M_16x16, M_SelectHigh, LCD_Send_Byte_D, M_Move, M_8x24, TempLoop
	
	; Named variables in access ram	
acs0	    udata_acs		    
tempL	    res 1		    ; Reserve low byte for temporary values
tempH	    res 1		    ; Reserve high byte for temporary values
tempU	    res 1		    ; Reserve upper byte for temporary values
temp	    res 1		    ; For storing values from LM35
Tdec	    res 1		    ; For power alg - decimal time difference
Tunit	    res 1		    ; For power alg - units time difference
Tten	    res 1		    ; For power alg - tens time difference
Temporary   res 1		    ; Temporary value storage space
TempCD	    res 1		    ; Current temperature (decimals)
TempCU	    res 1		    ; Current temperature (units)
TempCT	    res 1		    ; Current temperature (tens)
TimeDesL    res 1		    ; Calculated desired time (low byte)
TimeDesH    res 1		    ; Calculated desired time (high byte)
PACheck	    res 1		    ; The value 9 (for use in Power_Alg)
PASub	    res 1		    ; The value 246 (for use in Power_Alg)

Algorithms  code
  
	; Takes analogue reading from LM35 (in mV) and converts this to an 
	; equivalent temperature in degrees Celsius (and outputs to LCD)
	;			    - Requires LM35 connection, offset
	;			    - Sets TempCD, TempCU, TempCT 
LCD_Alg				   
	movf	ADRESL, W	    ; Stores mV reading (low byte) from LM35
	movwf	temp
	movwf	T_CrntL		    
	movf	offset, W	    ; Offset is the mV LM35 reading at 0 deg. C
	subwf	temp, f		    
	movf	temp, W		    ; Move this corrected voltage into 'temp'
	movwf	numbL
	movf	ADRESH, W	    ; Stores mV reading (high byte) from LM35
	movwf	temp
	movwf	T_CrntH
	movlw	0x0
	subwfb	temp,f
	movf	temp, W
	movwf	numbH
	call	M_16x16		    ; Start conversion - hex. to decimal 
	call	M_SelectHigh
	movwf	DataTop
	call	LCD_Send_Byte_D	    ; Sends the 'hundreds' column to LCD
	call	M_Move		    ; Continues conversion
	call	M_8x24
	call	M_SelectHigh
	movwf	DataUp
	movff	ru, TempCT	    ; Stores current temperature (tens) 
	call	LCD_Send_Byte_D	    ; Sends the 'tens' column to LCD
	call	M_Move		    ; Continues conversion
	call	M_8x24
	call	M_SelectHigh
	movwf	DataHigh
	movff	ru, TempCU	    ; Stores current temperature (units)
	call	LCD_Send_Byte_D	    ; Sends the 'units' column to LCD
	call	M_Move
	movlw	'.'		    ; Forcing a decimal place onto the LCD
	call	LCD_Send_Byte_D	
	call	M_8x24		    ; Continues conversion
	call	M_SelectHigh
	movwf	DataLow
	movff	ru, TempCD	    ; Stores current temperature (decimals)
	call	LCD_Send_Byte_D	    ; Sends the 'decimals' column to LCD
	return

	; Converts the keypad input (temperature) to the equivalent hex. voltage 
	;			    - Requires button presses (through T_in_d_h)
	;			    - Sets tempL, tempH, tempU
	;			    - Sets W to 0x0
	; N.B. temperatures are 10 times smaller than voltages (and offset)
TempIn_Alg			    
	clrf	tempL
	clrf	tempH
	clrf	tempU
	movf	units, W		
	mullw	0x0A		    ; Multiply 'units' column by ten
	movf	PRODL, W	    
	movwf	tempL
	movf	decimals, W	    ; Add the 'decimals' column to this 
	addwf	tempL
	movf	tens, W	    
	mullw	0x64		    ; Multiply the 'tens' column by 100
	movf	PRODL, W
	addwf	tempL		    ; This is the low byte of our mV reading
	movf	PRODH, W
	addwfc	tempH, f	    ; This is the high byte of our mV reading 
	movf	offset, W
	addwf	tempL		    ; Accounts for the offset
	movlw	0x0
	addwfc	tempH
	return 
	
	; Converts the keypad input (time) to a usuable hex. time 
	;			    - Requires button presses (through T_in_d_h)
	;			    - Sets TimeDesL, TimeDesH
	; N.B. user inputs a time in minutes - this also converts that to secs.
Time_alg
	clrf	TimeDesL
	clrf	TimeDesH
	movf	decimals, W	    ; Multiply decimals by 6
	mullw	0x06
	movf	PRODL, W
	movwf	TimeDesL	    ; Puts low byte of this into TimeDesL
	movf	units, W	    ; Multiply units by 60 
	mullw	0x3C
	movf	PRODL, W	    ; Low byte adds to TimeDesL
	addwf	TimeDesL
	movf	PRODH, W	    ; High byte adds to TimeDesH 
	addwfc	TimeDesH
	movf	tens, W		    ; 16x8 bit calculation: takes tens and
	mullw	0x58		    ; multiplies by low byte of .600
	movf	PRODL, W
	addwf	TimeDesL	    ; Low byte of this adds to TimeDesL
	movf	PRODH, W
	addwfc	TimeDesH	    ; High byte of this adds to TimeDesH
	movf	tens, W
	mullw	0x02		    ; Multiplies tens by high byte of .600
	movf	PRODL, W
	addwfc	TimeDesH	    ; Puts low byte of that into TimeDesH
        return
	
Power_Alg			    ; input temp is in hundreds, tens, units
				    ; current temp is in TempCT, TempCU, TempCD
	clrf	TimeDesL
	clrf	TimeDesH
	movlw	0xf6
	movwf	PASub
	movlw	0x09
	movwf	PACheck
	movf	TempCD, W	    
	movff	decimals, Temporary
	subwf	Temporary, f	    ; subtract the decimal temp contributions
	movff	Temporary, Tdec	    ; ...to get temp difference (decimal)
	movf	TempCU, W
	movff	units, Temporary 
	subwfb	Temporary, f	    ; sub with borrow the units temp contri.
	movff	Temporary, Tunit    ; ...to get temp difference (units)
	movf	TempCT, W
	movff	tens, Temporary
	subwfb	Temporary, f	    ; sub with borrow the tens temp contrib...
	movff	Temporary, Tten	    ; ...to get temp difference (tens)
	movf	PACheck, W
	cpfsgt	Tdec
	bra	NextCheck
	call	CorrectionDec
NextCheck
	movf	PACheck, W
	cpfsgt	Tunit
	bra	Conversion
	call	CorrectionUnit
Conversion
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
	addwfc	TimeDesH, f	    ; add a carry if needed from the decimal contrib.\A      
	return	
	
CorrectionDec
	movf	Tdec, W
	movwf	Temporary
	movf	PASub, W
	subwf	Temporary, f
	movff	Temporary, Tdec
	return

CorrectionUnit
	movf	Tunit, W
	movwf	Temporary
	movf	PASub, W
	subwf	Temporary, f
	movff	Temporary, Tunit
	return
	
PowerCheck	    
	movf	tens, W
	cpfsgt	TempCT		    ;compare high bytes (current/desired)?
	bra	CheckStep1
	bra	HeaterOff
	
CheckStep1	    ;are the high bytes equal (current/desired)?
	cpfseq	TempCT
	return 
	
CheckStep2	    ;compare low bytes (current/desired)?
	movf	units, W
	cpfsgt	TempCU
	bra	CheckStep3
	bra	HeaterOff
	
CheckStep3	    ;are the low bytes equal (current/desired)?
	cpfseq	TempCU
	return

CheckStep4  
	movf	decimals, W
	cpfsgt	TempCD
	bra	CheckStep5
	bra	HeaterOff

CheckStep5  
	cpfseq	TempCD
	return
	bra	HeaterOff
	return 
	
HeaterOff
	clrf	TRISJ
	movlw	0x00
	movwf	PORTJ
	call	TempLoop	
	
	end