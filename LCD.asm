#include p18f87k22.inc
; File Overview:
; Contains all LCD functions. 
    
	; External and global routines/variables
	global  LCD_Setup, LCD_Write_Message, LCD_Clear, LCD_Move, LCD_delay
	global  LCD_Send_Byte_D, LCD_delay_ms, LCD_Write_Hex, LCD_Send_Nib
	global	LCD_User1, LCD_User2, LCD_User3
	extern	tenLCD, unitLCD, decLCD

	; Named variables in access ram
acs0    udata_acs		    
LCD_cnt_l   res 1		    ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h   res 1		    ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms  res 1		    ; reserve 1 byte for ms counter
LCD_tmp	    res 1		    ; reserve 1 byte for temporary use
LCD_counter res 1		    ; reserve 1 byte for counting through message

acs_ovr	    access_ovr
LCD_hex_tmp res 1		    ; reserve 1 byte for variable LCD_hex_tmp	

	constant    LCD_E=5	    ; LCD enable bit
    	constant    LCD_RS=4	    ; LCD register select bit

LCD	code
    
LCD_Setup
	clrf    LATB
	movlw   b'11000000'	    ; RB0:5 all outputs
	movwf	TRISB
	movlw   .40
	call	LCD_delay_ms	    ; wait 40ms for LCD to start up properly
	movlw	b'00000010'	    ; Function set 4-bit
	call	LCD_Send_Nib
	movlw	.10		    ; wait 40us
	call	LCD_delay_x4us
	movlw	b'00101000'	    ; 2 line display 5x8 dot characters
	call	LCD_Send_Byte_I
	movlw	.10		    ; wait 40us
	call	LCD_delay_x4us
	movlw	b'00101000'	    ; repeat, 2 line display 5x8 dot characters
	call	LCD_Send_Byte_I
	movlw	.10		    ; wait 40us
	call	LCD_delay_x4us
	movlw	b'00001111'	    ; display on, cursor on, blinking on
	call	LCD_Send_Byte_I
	movlw	.10		    ; wait 40us
	call	LCD_delay_x4us
	movlw	b'00000001'	    ; display clear
	call	LCD_Send_Byte_I
	movlw	.2		    ; wait 2ms
	call	LCD_delay_ms
	movlw	b'00000110'	    ; entry mode incr by 1 no shift
	call	LCD_Send_Byte_I
	movlw	.10		    ; wait 40us
	call	LCD_delay_x4us
	return

LCD_Write_Hex	    ; Writes byte stored in W as hex
	movwf	LCD_hex_tmp
	swapf	LCD_hex_tmp,W	    ; high nibble first
	call	LCD_Hex_Nib
	movf	LCD_hex_tmp,W	    ; then low nibble
LCD_Hex_Nib	    ; Writes low nibble as hex character
	andlw	0x0F
	movwf	LCD_tmp
	movlw	0x0A
	cpfslt	LCD_tmp
	addlw	0x07		    ; number is greater than 9 
	addlw	0x26
	addwf	LCD_tmp,W
	call	LCD_Send_Byte_D	    ; write out ascii
	return
	
LCD_Write_Message   ; Message stored at FSR2, length stored in W
	movwf   LCD_counter
LCD_Loop_message
	movf    POSTINC2, W
	call    LCD_Send_Byte_D
	decfsz  LCD_counter
	bra	LCD_Loop_message
	return

LCD_Send_Byte_I	    ; Transmits byte stored in W to instruction reg
	movwf   LCD_tmp
	swapf   LCD_tmp,W	    ; swap nibbles, high nibble goes first
	andlw   0x0f		    ; select just low nibble
	movwf   LATB		    ; output data bits to LCD
	bcf	LATB, LCD_RS	    ; Instruction write clear RS bit
	call    LCD_Enable	    ; Pulse enable Bit 
	movf	LCD_tmp,W	    ; swap nibbles, now do low nibble
LCD_Send_Nib
	andlw   0x0f		    ; select just low nibble
	movwf   LATB		    ; output data bits to LCD
	bcf	LATB, LCD_RS	    ; Instruction write clear RS bit
        call    LCD_Enable	    ; Pulse enable Bit 
	return

LCD_Send_Byte_D	    ; Transmits byte stored in W to data reg
	movwf   LCD_tmp
	swapf   LCD_tmp,W	    ; swap nibbles, high nibble goes first
	andlw   0x0f		    ; select just low nibble
	movwf   LATB		    ; output data bits to LCD
	bsf	LATB, LCD_RS	    ; Data write set RS bit
	call    LCD_Enable	    ; Pulse enable Bit 
	movf	LCD_tmp,W	    ; swap nibbles, now do low nibble
	andlw   0x0f		    ; select just low nibble
	movwf   LATB		    ; output data bits to LCD
	bsf	LATB, LCD_RS	    ; Data write set RS bit	    
        call    LCD_Enable	    ; Pulse enable Bit 
	movlw	.10		    ; delay 40us
	call	LCD_delay_x4us
	return

LCD_Enable	    ; pulse enable bit LCD_E for 500ns
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bsf	LATB, LCD_E	    ; Take enable high
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bcf	LATB, LCD_E	    ; Writes data to LCD
	return
    
; **** a few delay routines below here as LCD timing can be quite critical ****
LCD_delay_ms	    ; delay given in ms in W
	movwf	LCD_cnt_ms
lcdlp2	movlw	.250		    ; 1 ms delay
	call	LCD_delay_x4us	
	decfsz	LCD_cnt_ms
	bra	lcdlp2
	return	
	
LCD_delay_x4us	    ; delay given in chunks of 4 microsecond in W
	movwf	LCD_cnt_l	    ; now need to multiply by 16
	swapf   LCD_cnt_l,F	    ; swap nibbles
	movlw	0x0f	    
	andwf	LCD_cnt_l,W	    ; move low nibble to W
	movwf	LCD_cnt_h	    ; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	LCD_cnt_l,F	    ; keep high nibble in LCD_cnt_l
	call	LCD_delay
	return

LCD_delay	    ; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		    ; W=0
lcdlp1	decf 	LCD_cnt_l,F	    ; no carry when 0x00 -> 0xff
	subwfb 	LCD_cnt_h,F	    ; no carry when 0x00 -> 0xff
	bc 	lcdlp1		    ; carry, then loop again
	return			    ; carry reset so return


LCD_Clear	    ; Clear LCD screen
	movlw	b'00000001'	
	call	LCD_Send_Byte_I
	movlw	.2		    ; wait 2ms
	call	LCD_delay_ms
	return 
	
LCD_Move	    ; Moves LCD cursor to 2nd line 
	movlw	b'11000000'
	call	LCD_Send_Byte_I
	movlw	.2		    ; wait 2ms
	call	LCD_delay_ms
	return
	
	; LCD_User1:
	; Outputs 'Time/Temp?' to the LCD			    
LCD_User1
	movlw	0x54
	call	LCD_Send_Byte_D
	movlw	0x65
	call	LCD_Send_Byte_D
	movlw	0x6D
	call	LCD_Send_Byte_D
	movlw	0x70
	call	LCD_Send_Byte_D
	movlw	0x2F
	call	LCD_Send_Byte_D
	movlw	0x54
	call	LCD_Send_Byte_D 
	movlw	0x69
	call	LCD_Send_Byte_D
	movlw	0x6D
	call	LCD_Send_Byte_D
	movlw	0x65
	call	LCD_Send_Byte_D
	movlw	0x3F
	call	LCD_Send_Byte_D
	movlw	0x20
	call	LCD_Send_Byte_D
	return 
	
	; LCD_User2:
	; Outputs 'Method' to the LCD
LCD_User2
	movlw	0x4D
	call	LCD_Send_Byte_D
	movlw	0x65
	call	LCD_Send_Byte_D
	movlw	0x74
	call	LCD_Send_Byte_D
	movlw	0x68
	call	LCD_Send_Byte_D
	movlw	0x6F
	call	LCD_Send_Byte_D
	movlw	0x64
	call	LCD_Send_Byte_D
	movlw	0x3F
	call	LCD_Send_Byte_D
	movlw	0x20
	call	LCD_Send_Byte_D
	return 
    
	; LCD_User3:
	; Outputs 'Desired:' and the desired temperature to the LCD
LCD_User3
	call	LCD_Move
	movlw	0x44
	call	LCD_Send_Byte_D
	movlw	0x65
	call	LCD_Send_Byte_D
	movlw	0x73
	call	LCD_Send_Byte_D
	movlw	0x69
	call	LCD_Send_Byte_D
	movlw	0x72
	call	LCD_Send_Byte_D
	movlw	0x65
	call	LCD_Send_Byte_D
	movlw	0x64
	call	LCD_Send_Byte_D
	movlw	0x3A
	call	LCD_Send_Byte_D
	movlw	0x30
	call	LCD_Send_Byte_D
	movf	tenLCD, W
	call	LCD_Send_Byte_D
	movf	unitLCD, W
	call	LCD_Send_Byte_D
	movlw	0x2E
	call	LCD_Send_Byte_D
	movf	decLCD, W
	call	LCD_Send_Byte_D
	return
	
	
	end


