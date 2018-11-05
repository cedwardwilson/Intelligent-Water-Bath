#include p18f87k22.inc
    
    global	Keys_Translator, Keypad, tmpval
    extern	delay
    
acs0    udata_acs   ; named variables in access ram
tmpval	res 1
	  
Keys	code
	
Keys_Translator 
	movlb	5		    ;use Bank 5
	lfsr	FSR1, 0x580	    ;start at 0x580 address in Bank 5
	movlw	'1'		    ;ascii characters into files in Bank 5
	movwf	tmpval
	movlw	0x77
	movff	tmpval,PLUSW1
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
	return
	
	end