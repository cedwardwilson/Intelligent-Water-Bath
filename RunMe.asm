	#include p18f87k22.inc

	extern  LCD_Setup, LCD_Clear, LCD_Send_Byte_D, LCD_delay_ms 
	extern  ADC_Setup, ADC_Read		    
	extern	M_16x16, M_8x24, numbL, numbH, numbU, M_SelectHigh, M_Move
	extern	FDLP, T_in_d_h, hundreds, tens, units
	extern	LCD_Alg, Keys_Translator, LookUp_d_h, M_Table, TempIn_Alg
	extern	SecondTimer, UART_Transmit_Byte, UART_Setup, Time_alg
	global	delay, T_CrntL, T_CrntH, measure_loop, offset, TimerCount, DataCount
	
acs0	    udata_acs		    ; reserve data space in access ram
counter	    res 1		    ; reserve one byte for a counter variable
delay_count res 1		    ; reserve one byte for counter in the delay routine
offset	    res 1		    ; reserve one byte for the offset in the V-T conversion
T_CrntL	    res 1
T_CrntH	    res 1		    ;reserved for the current voltage readout off the LM35
TimerCount  res 1		    ;number of seconds passed
DataCount   res 1		    ;number of seconds between data readouts

tables	    udata	0x400	    ; reserve data anywhere in RAM (here at 0x400)
myArray	    res		0x80	    ; reserve 128 bytes for message data

rst	code	0		    ; reset vector
	goto	setup
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	    ; point to Flash program memory  
	bsf	EECON1, EEPGD	    ; access Flash program memory
	call	UART_Setup	    ; setup UART
	call	LCD_Setup	    ; setup LCD
	call	ADC_Setup	    ; setup ADC
	; ***sets up our 3 look up tables***
	call	LookUp_d_h	    ; using FSR0			
	call	Keys_Translator	    ; using FSR1
	call	M_Table		    ; using FSR2
	goto	start
	
	; ******* Main programme ****************************************
start 	movlw	0x0A		    ; define time in sec between data readings
	movwf	DataCount
	movlw	0x0D		    ; callibrates between mV and T readings
	movwf	offset
	clrf	PORTJ, ACCESS	    ;cleared for use later with powering heater
	movlw	0x0A		    ; for comparison loops later (in T_in_d_h)
	movwf	hundreds
	movwf	tens
	movwf	units
	call	T_in_d_h	    ; converts Temp in decimal to hex voltage
	call	Time_alg
	call	TempIn_Alg
	call	SecondTimer	    ; sets up timer/interrupts for data readings
	bra	measure_loop
	
measure_loop
	call	ADC_Read	    ; get out a hex value for voltage
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	call	LCD_Clear
	call	LCD_Alg		    ; converts hex to decimal and output to LCD
	call	FDLP		    ; determines in heater should be on/off
	goto	measure_loop	    ; holds the system in this loop
		

	; a delay subroutine if you need one, times around loop in delay_count
delay	decfsz	delay_count	; decrement until zero
	bra delay
	return

	end