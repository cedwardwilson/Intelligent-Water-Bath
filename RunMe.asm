	#include p18f87k22.inc

	extern  LCD_Setup, LCD_Clear, LCD_Send_Byte_D, LCD_delay_ms ; external LCD subroutines
	extern  ADC_Setup, ADC_Read		    ; external ADC routines
	extern	M_16x16, M_8x24, numbL, numbH, numbU, M_SelectHigh, M_Move
	global	delay
	
acs0	    udata_acs		    ; reserve data space in access ram
counter	    res 1		    ; reserve one byte for a counter variable
delay_count res 1		    ; reserve one byte for counter in the delay routine
offset	    res 1		    ; reserve one byte for the offset in the V-T conversion
temp	    res 1		    ; reserve one byte for tempory values

tables	    udata	0x400		    ; reserve data anywhere in RAM (here at 0x400)
myArray	    res 0x80		    ; reserve 128 bytes for message data

rst	code	0		    ; reset vector
	goto	setup
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	    ; point to Flash program memory  
	bsf	EECON1, EEPGD	    ; access Flash program memory
	;call	UART_Setup	    ; setup UART
	call	LCD_Setup	    ; setup LCD
	call	ADC_Setup	    ; setup ADC
	goto	start
	
	; ******* Main programme ****************************************
start 	movlw	0x0D
	movwf	offset
	bra	measure_loop
	
measure_loop
	call	ADC_Read	    ;get out a hex value for voltage
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	call	LCD_Clear
	call	Algorithm	    ;convert hex to decimal and output to LCD
	goto	measure_loop	    ; goto current line in code
	
Algorithm			    ;follows procedure as outlined in lec9
	movf	ADRESL, W
	movwf	temp
	movf	offset, W
	subwf	temp, f
	movf	temp, W
	movwf	numbL
	movf	ADRESH, W
	movwf	temp
	movlw	0x0
	subwfb	temp,f
	movf	temp, W
	movwf	numbH
	call	M_16x16
	call	M_SelectHigh
	call	LCD_Send_Byte_D
	call	M_Move
	call	M_8x24
	call	M_SelectHigh
	call	LCD_Send_Byte_D
	call	M_Move
	call	M_8x24
	call	M_SelectHigh
	call	LCD_Send_Byte_D
	call	M_Move
	movlw	'.'
	call	LCD_Send_Byte_D
	call	M_8x24
	call	M_SelectHigh
	call	LCD_Send_Byte_D
	return
	

	; a delay subroutine if you need one, times around loop in delay_count
delay	decfsz	delay_count	; decrement until zero
	bra delay
	return

	end