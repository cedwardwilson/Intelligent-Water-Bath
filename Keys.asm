#include p18f87k22.inc
    
    global	Keys_Translator, Keypad, Display, tmpval
    extern	delay, LCD_Send_Byte_D
    
acs0    udata_acs   ; named variables in access ram
tmpval	res 1
	  
Keys	code
	
Keys_Translator 
	movlb	5		    ;use Bank 5
	lfsr	FSR1, 0x580	    ;start at 0x580 address in Bank 5
	movlw	'F'		    ;ascii characters into files in Bank 5
	movwf	tmpval
	movlw	0x77
	movff	tmpval,PLUSW1
	movlw	'U'
	movwf	tmpval
	movlw	0xB7
	movff	tmpval,PLUSW1
	movlw	'C'
	movwf	tmpval
	movlw	0xD7
	movff	tmpval,PLUSW1
	movlw	'T'
	movwf	tmpval
	movlw	0x7B
	movff	tmpval,PLUSW1
	movlw	'H'
	movwf	tmpval
	movlw	0xBB 
	movff	tmpval,PLUSW1
	movlw	'I'
	movwf	tmpval
	movlw	0xDB
	movff	tmpval,PLUSW1
	movlw	'S'
	movwf	tmpval
	movlw	0x7D
	movff	tmpval,PLUSW1
	movlw	'H'
	movwf	tmpval
	movlw	0xBD
	movff	tmpval,PLUSW1
	movlw	'I'
	movwf	tmpval
	movlw	0xDD
	movff	tmpval,PLUSW1
	movlw	'K'
	movwf	tmpval
	movlw	0xE7
	movff	tmpval,PLUSW1
	movlw	'S'
	movwf	tmpval
	movlw	0xEB
	movff	tmpval,PLUSW1
	movlw	'T'
	movwf	tmpval
	movlw	0xED
	movff	tmpval,PLUSW1
	movlw	'D'
	movwf	tmpval
	movlw	0xEE
	movff	tmpval,PLUSW1
	movlw	'0'
	movwf	tmpval
	movlw	0xBE
	movff	tmpval, PLUSW1
	movlw	'*'
	movwf	tmpval
	movlw	0x7E
	movff	tmpval,PLUSW1
	movlw	'#'
	movwf	tmpval
	movlw	0xDE
	movff	tmpval,PLUSW1
	return

Keypad	
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
	bra	Keypad
	movwf	0x02, ACCESS
	movlw	0xf0			;collecting high nibble
	movwf	TRISE
	call	delay
	movwf	PORTE
	call	delay
	movf	PORTE, W, ACCESS
	addwf	0x02
	movf	0x02, W, ACCESS		;storing full binary number in W
	clrf	TRISH
	movff	PLUSW1, tmpval		;turning W into an address,
	call	delay			;where ascii character will be stored
	movf	tmpval, W		
	;movwf	PORTH			;and reading it back out onto Port H
	return
	
Display					;displaying on the LCD
	;movf	PORTH, W, ACCESS
	call	LCD_Send_Byte_D
	return
	
	end