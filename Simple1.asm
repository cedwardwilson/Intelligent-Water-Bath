	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message, LCD_Clear    ; external LCD subroutines
	extern	LCD_Write_Hex, LCD_Send_Nib, LCD_Send_Byte_D, LCD_delay_ms		    ; external LCD subroutines
	extern  ADC_Setup, ADC_Read		    ; external ADC routines
	extern	M_16x16, M_8x24, numbL, numbH, numbU, M_SelectHigh, M_Move
	global	delay
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine

tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****
myTable data	    "Fello World!\n"	; message, plus carriage return
	constant    myTable_l=.13	; length of data
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	call	ADC_Setup	; setup ADC
	goto	start
	
	; ******* Main programme ****************************************
start 	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter		; our counter register
loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
		
	movlw	myTable_l-1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	;call	LCD_Write_Message

	movlw	myTable_l	; output message to UART
	lfsr	FSR2, myArray
	call	UART_Transmit_Message
	
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
	goto	measure_loop		; goto current line in code
	
Algorithm			    ;follows procedure as outlined in lec9
	movf	ADRESH, W
	movwf	numbH
	movf	ADRESL, W
	movwf	numbL
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
	call	M_8x24
	call	M_SelectHigh
	call	LCD_Send_Byte_D
	return
	

	; a delay subroutine if you need one, times around loop in delay_count
delay	decfsz	delay_count	; decrement until zero
	bra delay
	return

	end