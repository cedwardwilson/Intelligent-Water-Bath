#include p18f87k22.inc
    
    global	Keys_Translator, Keypad, tmpval, T_in_d_h, hundreds, tens, units
    extern	delay, LCD_delay_ms
    
acs0    udata_acs			; named variables in access ram
tmpval	res 1
b_add_LCD	res 1			;for binary addresses for LCD
b_add_d_h	res 1			;for binary addresses for d-h convert.
units	res 1				;for our t_in_d_h
tens	res 1
hundreds    res 1			
	
Keys	code
	
Keys_Translator		;sets the values of the keys of our keypad
	movlb	5			;use Bank 5
	lfsr	FSR1, 0x580		;start at 0x580 address in Bank 5
	movlw	'1'			;store ascii characters in files in Bank 5
	movwf	tmpval
	movlw	0x77
	movff	tmpval,PLUSW1		;N.B. PLUSWn does not change FSRn
	movlw	'2'
	movwf	tmpval
	movlw	0xB7
	movff	tmpval,PLUSW1
	movlw	'3'
	movwf	tmpval
	movlw	0xD7
	movff	tmpval,PLUSW1
	movlw	'4'
	movwf	tmpval
	movlw	0x7B
	movff	tmpval,PLUSW1
	movlw	'5'
	movwf	tmpval
	movlw	0xBB 
	movff	tmpval,PLUSW1
	movlw	'6'
	movwf	tmpval
	movlw	0xDB
	movff	tmpval,PLUSW1
	movlw	'7'
	movwf	tmpval
	movlw	0x7D
	movff	tmpval,PLUSW1
	movlw	'8'
	movwf	tmpval
	movlw	0xBD
	movff	tmpval,PLUSW1
	movlw	'9'
	movwf	tmpval
	movlw	0xDD
	movff	tmpval,PLUSW1
	movlw	'T'		    
	movwf	tmpval		    
	movlw	0xE7
	movff	tmpval,PLUSW1
	movlw	'E'
	movwf	tmpval
	movlw	0xEB
	movff	tmpval,PLUSW1
	movlw	'M'
	movwf	tmpval
	movlw	0xED
	movff	tmpval,PLUSW1
	movlw	'P'
	movwf	tmpval
	movlw	0xEE
	movff	tmpval,PLUSW1
	movlw	'0'
	movwf	tmpval
	movlw	0xBE
	movff	tmpval, PLUSW1
	movlw	'I'
	movwf	tmpval
	movlw	0x7E
	movff	tmpval,PLUSW1
	movlw	'#'
	movwf	tmpval
	movlw	0xDE			;keypad can now write 'TEMP' and 'TIME'
	movff	tmpval,PLUSW1		;as well as numbers 0-9
	return

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
	call	LookUp_d_h
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
	;movf	tmpval, W
	movlw	0x0A
	cpfseq	hundreds
	;call	delay
	bra	tenscheck
	movff	tmpval, hundreds
	movlw	.255
	call	LCD_delay_ms
	call	LCD_delay_ms
	bra	T_in_d_h
tenscheck 
	movlw	0x0A
	cpfseq	tens
	;call	delay
	bra	set_units
	movff   tmpval, tens
	call	LCD_delay_ms
	call	LCD_delay_ms
	;movf	tens, W
	;clrf	TRISD
	;movwf	PORTD
	;call	delay
	bra	T_in_d_h
set_units   
	movff	tmpval, units
	call	LCD_delay_ms
	call	LCD_delay_ms
	return
	
LookUp_d_h		;sets the values of the keys of our keypad
	movlb	5			;use Bank 6
	lfsr	FSR0, 0x580		;start at 0x680 address in Bank 6
	movlw	0x01			;store ascii characters in files in Bank 6
	movwf	tmpval
	movlw	0x77
	movff	tmpval,PLUSW0		;N.B. PLUSWn does not change FSRn
	movlw	0x02
	movwf	tmpval
	movlw	0xB7
	movff	tmpval,PLUSW0
	movlw	0x03
	movwf	tmpval
	movlw	0xD7
	movff	tmpval,PLUSW0
	movlw	0x04
	movwf	tmpval
	movlw	0x7B
	movff	tmpval,PLUSW0
	movlw	0x05
	movwf	tmpval
	movlw	0xBB 
	movff	tmpval,PLUSW0
	movlw	0x06
	movwf	tmpval
	movlw	0xDB
	movff	tmpval,PLUSW0
	movlw	0x07
	movwf	tmpval
	movlw	0x7D
	movff	tmpval,PLUSW0
	movlw	0x08
	movwf	tmpval
	movlw	0xBD
	movff	tmpval,PLUSW0
	movlw	0x09
	movwf	tmpval
	movlw	0xDD
	movff	tmpval,PLUSW0
	movlw	0x0
	movwf	tmpval
	movlw	0xBE
	movff	tmpval, PLUSW0
	return
	
end