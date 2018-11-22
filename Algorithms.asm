#include p18f87k22.inc
; File Overview:
; Contains 4 algorithms: LCD_Alg, TempIn_Alg, Time_alg, Power_Alg
	
	; External and global routines/variables
	extern	offset, numbL, numbH, T_CrntH, T_CrntL, tens, units, decimals
	extern	DataLow, DataHigh, DataUp, DataTop, ru
	extern	M_16x16, M_SelectHigh, LCD_Send_Byte_D, M_Move, M_8x24, TempLoop
	global	tempL, tempH, TimeDesL, TimeDesH
	global	Power_Alg, PowerCheck, LCD_Alg, TempIn_Alg, Time_alg
	
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
  
	; LCD_Alg:
	; Takes analogue reading from LM35 (in mV) and converts this to an 
	; equivalent temperature in degrees Celsius (and outputs to LCD)
	;			    - Requires LM35 connection, offset
	;			    - Sets TempCD, TempCU, TempCT 
LCD_Alg				   
	movlw	0x54		    ; Outputs 'Temp:' onto the LCD
	call	LCD_Send_Byte_D
	movlw	0x65
	call	LCD_Send_Byte_D
	movlw	0x6D
	call	LCD_Send_Byte_D
	movlw	0x70
	call	LCD_Send_Byte_D
	movlw	0x3A
	call	LCD_Send_Byte_D
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

	; TempIn_Alg
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
	
	; Time_alg:
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
	mullw	0x58		    ; multiplies by low byte of 600
	movf	PRODL, W
	addwf	TimeDesL	    ; Low byte of this adds to TimeDesL
	movf	PRODH, W
	addwfc	TimeDesH	    ; High byte of this adds to TimeDesH
	movf	tens, W
	mullw	0x02		    ; Multiplies tens by high byte of 600
	movf	PRODL, W
	addwfc	TimeDesH	    ; Puts low byte of that into TimeDesH
        return
	
	; Power_Alg:
	; Converts the difference between the desired temperature and the
	; current temperature into a time required to reach the desired
	;			    - requires 3 button presses from keypad 
	;			    for desired temperature and LM35 readout
	;			    - sets TimeDesL and TimeDesH
Power_Alg
	clrf	TimeDesL
	clrf	TimeDesH
	movlw	0xf6		
	movwf	PASub		    ; PASub is used in a carry correction (=246)
	movlw	0x09
	movwf	PACheck		    ; PACheck is used to check for a carry (=9)
	movf	TempCD, W	    
	movff	decimals, Temporary
	subwf	Temporary, f	    ; Find the difference in decimals
	movff	Temporary, Tdec	    
	movf	TempCU, W
	movff	units, Temporary 
	subwfb	Temporary, f	    ; Find the difference in units
	movff	Temporary, Tunit    
	movf	TempCT, W
	movff	tens, Temporary
	subwfb	Temporary, f	    ; Find the difference in tens
	movff	Temporary, Tten	    
	movf	PACheck, W
	cpfsgt	Tdec		    ; Check if a borrow was needed for decimals
	bra	NextCheck	    ; If not, continue on to check units next
	call	CorrectionDec	    ; Else, correct this before checking units
NextCheck
	movf	PACheck, W	
	cpfsgt	Tunit		    ; Check if a borrow was needed for units
	bra	Conversion	    ; If not, start the conversion to a run time
	call	CorrectionUnit	    ; Else, correct this before conversion
Conversion
	movf	Tten, W
	mullw	0x0A		    ; Multiply the tens column by 10...
	movf	PRODL, W
	addwf	Tunit, f	    ; ...and add this to the units...
	movf	Tunit, W	    ; ...to get integer temperature difference
	mullw	0x28		    ; 40 is the heat capacity / power (in s/K)
	movff	PRODL, TimeDesL	    ; 40 * temperature difference = run time 
	movff	PRODH, TimeDesH
	movf	Tdec, W		    ; This is the decimal time difference
	mullw	0x04		    ; 40/10 is used to negate the decimal point
	movf	PRODL, W	    ; 
	addwf	TimeDesL, f	    ; Add this contribution to the integer one 
	movlw	0x0
	addwfc	TimeDesH, f      
	return	
	
	; CorrectionDec:
	; Corrects the decimal temperature difference if a borrow was needed by
	; taking the temperature difference away from 246 
CorrectionDec		   
	movf	Tdec, W
	movwf	Temporary
	movf	PASub, W
	subwf	Temporary, f
	movff	Temporary, Tdec
	return

	; CorrectionUnit:
	; Corrects the unit temperature difference if a borrow was needed by
	; taking the temperature difference away from 246 
CorrectionUnit
	movf	Tunit, W
	movwf	Temporary
	movf	PASub, W
	subwf	Temporary, f
	movff	Temporary, Tunit
	return
	
	; PowerCheck:
	; Checks if the desired temperature is less than the current temperature
	; If it is, the system will revert to Method A of heating 
	; If not, the system will continue with this Method B
	;			    - requires 3 button presses on the keypad
	;			    to set desired temperature and LM35 readout
PowerCheck	    
	movf	tens, W
	cpfsgt	TempCT		    ; Compare current and desired tens columns
	bra	CheckStep1	    ; If current =< desired, continue checking
	bra	HeaterOff	    ;  If current > desired, switch heater off
	
CheckStep1	    
	cpfseq	TempCT		    ; Are tens columns of current/desired equal?
	return			    ; If not, power routine can run
				    ; If they are equal, continue checking
CheckStep2	    
	movf	units, W
	cpfsgt	TempCU		    ; Compare current and desired units column
	bra	CheckStep3	    ; If current =< desired, continue checking
	bra	HeaterOff	    ; If current > desired, switch heater off
	
CheckStep3	    
	cpfseq	TempCU		    ; Are units column of current/desired equal?
	return			    ; If not, power routine can run
				    ; If they are equal, continue checking
CheckStep4  
	movf	decimals, W
	cpfsgt	TempCD		    ; Compare current and desired decimals column
	bra	CheckStep5	    ; If current =< desired, continue checking
	bra	HeaterOff	    ; If current > desired, switch heater off

CheckStep5  
	cpfseq	TempCD		    ; Are decimals column of current/desired equal?
	return			    ; If not, power routine can run
	bra	HeaterOff	    ; If they are equal, switch heater off
	return 
	    
	; HeaterOff:
	; Switches heater off and places the system into Method A, where it will
	; only heat if the current temperature drops below the desired
HeaterOff
	clrf	TRISJ
	movlw	0x00
	movwf	PORTJ
	call	TempLoop	
	
	end