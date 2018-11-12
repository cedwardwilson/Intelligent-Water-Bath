#include p18f87k22.inc
    
    global	Keypad, tmpval, T_in_d_h, hundreds, tens, units, tmpval
    extern	delay, LCD_delay_ms
    extern	LCD_Send_Byte_D, TempIn_Alg
    
acs0    udata_acs			; named variables in access ram
tmpval		res 1
b_add_LCD	res 1			;for binary addresses for LCD
b_add_d_h	res 1			;for binary addresses for d-h convert.
units		res 1			;for our t_in_d_h
tens		res 1
hundreds	res 1
hunLCD		res 1			;for outputting to LCD
tenLCD		res 1
unitLCD		res 1	
	
Keys	code

Keypad			;moves appropriate ascii character to W
	banksel	PADCFG1			
	bsf	PADCFG1, REPU, BANKED	;pull up resistors on Port E
	movlb	0x0 
	clrf	LATE
	movlw	0x0f			;collecting low nibble 
	movwf	TRISE
	movwf	tmpval
	call	delay
	movwf	PORTE
	call	delay
	movf	PORTE, W, ACCESS
	cpfsgt	tmpval, ACCESS
	bra	Keypad			;if nothing is pressed, loop back to start
	movwf	b_add_LCD, ACCESS
	movlw	0xf0			;collecting high nibble
	movwf	TRISE
	call	delay
	movwf	PORTE
	call	delay
	movf	PORTE, W, ACCESS
	addwf	b_add_LCD
	movf	b_add_LCD, W, ACCESS		;storing full binary number in W
	movff	PLUSW1, tmpval		;turning W into an address,
	call	delay			;where ascii character will be stored
	movf	tmpval, W
	return  
	
T_in_d_h	    ;temperature input (from keypad) to hex
	banksel	PADCFG1			
	bsf	PADCFG1, REPU, BANKED	;pull up resistors on Port E
	movlb	0x0 
	clrf	LATE
	movlw	0x0f			;collecting low nibble 
	movwf	TRISE
	movwf	tmpval
	call	delay
	movwf	PORTE
	call	delay
	movf	PORTE, W, ACCESS
	cpfsgt	tmpval, ACCESS
	bra	T_in_d_h		;if nothing is pressed, loop back to start
	movwf	b_add_d_h, ACCESS
	movlw	0xf0			;collecting high nibble
	movwf	TRISE
	call	delay
	movwf	PORTE
	call	delay
	movf	PORTE, W, ACCESS
	addwf	b_add_d_h
	movf	b_add_d_h, W, ACCESS		;storing full binary number in W
	movff	PLUSW0, tmpval		;turning W into an address,
	call	delay			;where ascii character will be stored
	movlw	0x0A
	cpfseq	hundreds		;check hundreds set before setting tens
	bra	tenscheck
	movff	tmpval, hundreds
	movf	hundreds, W
	movff	PLUSW2, hunLCD
	movf	hunLCD, W
	call	LCD_Send_Byte_D
	movlw	.255
	call	LCD_delay_ms
	call	LCD_delay_ms
	bra	T_in_d_h
tenscheck 
	movlw	0x0A
	cpfseq	tens			;check tens set before setting units
	bra	set_units
	movff   tmpval, tens
	movf	tens, W
	movff	PLUSW2, tenLCD
	movf	tenLCD, W
	call	LCD_Send_Byte_D
	call	LCD_delay_ms
	call	LCD_delay_ms
	bra	T_in_d_h
set_units   
	movff	tmpval, units
	movf	units, W
	movff	PLUSW2, unitLCD
	movlw	'.'
	call	LCD_Send_Byte_D
	movf	unitLCD, W
	call	LCD_Send_Byte_D
	call	LCD_delay_ms
	call	LCD_delay_ms
	;call	TempIn_Alg
	return
	
	end