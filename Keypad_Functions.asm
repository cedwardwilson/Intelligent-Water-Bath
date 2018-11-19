#include p18f87k22.inc
; File Overview:
; Contains two routines interfacing with the hardware keypad - Keypad and
; T_in_d_h.
; Both utilise PORTE.
    
    ; External and global routines/variables
    global	Keypad, tmpval, T_in_d_h, tens, units, decimals
    extern	delay, LCD_delay_ms, LCD_Send_Byte_D, TempIn_Alg, LCD_Alg
    
    ; Named variables in access ram
acs0    udata_acs			
tmpval		res 1		    ; A temporary value 
b_add_LCD	res 1		    ; For binary addresses, used by LCD
b_add_d_h	res 1		    ; For binary addresses, used by Dec. to Hex.
decimals	res 1		    ; For T_in_d_h
units		res 1		    ; " 
tens		res 1		    ; " 
tenLCD		res 1		    ; For outputting to LCD
unitLCD		res 1		    ; "
decLCD		res 1		    ; "
	
Keypad_Functions	code
	
	; Moves appropriate ascii character to W 
	; Requires button press on keypad, and lookup table 'Keys Translator'
	; Sets W to ascii character of button pressed
	; Uses FSR1
Keypad			
	banksel	PADCFG1			
	bsf	PADCFG1, REPU, BANKED	; Set pull up resistors on Port E
	movlb	0x0 
	clrf	LATE
	movlw	0x0f			; Collecting low nibble 
	movwf	TRISE
	movwf	tmpval
	call	delay
	movwf	PORTE
	call	delay
	movf	PORTE, W, ACCESS
	cpfsgt	tmpval, ACCESS
	bra	Keypad			; If no key pressed, start Keypad again
	movwf	b_add_LCD, ACCESS
	movlw	0xf0			; Collecting high nibble
	movwf	TRISE
	call	delay
	movwf	PORTE
	call	delay
	movf	PORTE, W, ACCESS
	addwf	b_add_LCD		; Adding low and high nibbles
					; to create a binary address.
	movf	b_add_LCD, W, ACCESS	; Storing full binary number in W
	movff	PLUSW1, tmpval		; Turning W into an address,
	call	delay			; where ascii character will be stored.
	movf	tmpval, W
	return  
	
	; Converts decimal kepyad input to hex. and stores this as a 
	; desired time/temperature
	;			- Requires 3 button presses on keypad
	;			- Sets decimals, units, tens
	; Uses FSR2
T_in_d_h	    
	banksel	PADCFG1			
	bsf	PADCFG1, REPU, BANKED	; Set pull up resistors on Port E
	movlb	0x0 
	clrf	LATE
	movlw	0x0f			; Collecting low nibble 
	movwf	TRISE
	movwf	tmpval
	call	delay
	movwf	PORTE
	call	delay
	movf	PORTE, W, ACCESS
	cpfsgt	tmpval, ACCESS
	bra	T_in_d_h		; If no key pressed, branch to T_in_d_h
	movwf	b_add_d_h, ACCESS
	movlw	0xf0			; Collecting high nibble
	movwf	TRISE
	call	delay
	movwf	PORTE
	call	delay
	movf	PORTE, W, ACCESS
	addwf	b_add_d_h		; Adding low and high nibbles
					; to create a binary address.
	movf	b_add_d_h, W, ACCESS	; Storing full binary number in W
	movff	PLUSW0, tmpval		; Turning W into an address,
	call	delay			; where hex value will be stored.
	movlw	0x0A
	cpfseq	tens			; Check tens is set before units
	bra	unitcheck
	movff	tmpval, tens
	movf	tens, W
	movff	PLUSW2, tenLCD
	movf	tenLCD, W
	call	LCD_Send_Byte_D		; Sends value to LCD as typed
	movlw	.255
	call	LCD_delay_ms
	call	LCD_delay_ms
	bra	T_in_d_h
unitcheck 
	movlw	0x0A
	cpfseq	units			; Check units is set before decimals
	bra	set_decimal
	movff   tmpval, units
	movf	units, W
	movff	PLUSW2, unitLCD
	movf	unitLCD, W
	call	LCD_Send_Byte_D		; Sends value to LCD as typed
	call	LCD_delay_ms
	call	LCD_delay_ms
	bra	T_in_d_h
set_decimal   
	movff	tmpval, decimals
	movf	decimals, W
	movff	PLUSW2, decLCD
	movlw	'.'			; Forces decimal point in 
	call	LCD_Send_Byte_D
	movf	decLCD, W
	call	LCD_Send_Byte_D
	call	LCD_delay_ms
	call	LCD_delay_ms
	return
	
	end