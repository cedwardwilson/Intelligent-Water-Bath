	#include p18f87k22.inc
; The RunMe file is the central file to the whole project - it shows the 
; progression of the code from Temp/Time input to Routine Select and then 
; through each routine as needed 
	
	; External and global routines/variables
	extern  LCD_Setup, ADC_Setup, UART_Setup, SecondTimer
	extern	FDLP_Time, FDLP_Temp, Time_alg, Power_Alg, TempIn_Alg, LCD_Alg
	extern  ADC_Read, LCD_Clear, LCD_Send_Byte_D, LCD_delay_ms, PowerCheck
	extern	LCD_User1, LCD_User2, LCD_User3
	extern	Keys_Translator, LookUp_d_h, M_Table, Keypad, T_in_d_h
	extern	tens, units, decimals, TimeDesL, TimeDesH
	global	T_CrntL, T_CrntH, offset, TimerCount, DataCount, TimeL, TimeH
	global	delay, TempLoop
	
	; Named variables in access ram
acs0	    udata_acs		    
counter	    res 1		    ; Counter 
delay_count res 1		    ; For counter in the delay routine
offset	    res 1		    ; Offset in the Voltage-Temp conversion
T_CrntL	    res 1		    ; Voltage readout off the LM35
T_CrntH	    res 1		    
TimerCount  res 1		    ; Seconds passed between data readouts
DataCount   res 1		    ; Desired seconds between data readouts
TimeL	    res 1		    ; 2 bytes for the 'real time'
TimeH	    res 1
Aascii	    res 1		    ; For routine select (A, B or C)
Bascii	    res 1
Cascii	    res 1
Ascii	    res 1		    
PowerResL   res 1		    ; Holds desired temperature whilst warming 
PowerResH   res 1		    ; up in power routine
PowerResU   res 1

tables	    udata	0x400	    ; Reserve data anywhere in RAM (here at 0x400)
myArray	    res		0x80	    ; Reserve 128 bytes for message data

rst	code	0		    ; Reset vector
	goto	setup
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	    ; Point to Flash program memory  
	bsf	EECON1, EEPGD	    ; Access Flash program memory
	call	UART_Setup	    ; Setup UART
	call	LCD_Setup	    ; Setup LCD
	call	ADC_Setup	    ; Setup ADC
	; ***sets up our 3 look up tables***
	call	LookUp_d_h	    ; Using FSR0			
	call	Keys_Translator	    ; Using FSR1
	call	M_Table		    ; Using FSR2
	clrf	TimerCount	    ; Reset the timers
	clrf	DataCount
	clrf	TimeL
	clrf	TimeH
	movlw	0x41		    ; Ascii code - A
	movwf	Aascii
	movlw	0x42		    ; Ascii code - B
	movwf	Bascii
	movlw	0x43		    ; Ascii code - C
	movwf	Cascii
	goto	start
	
	; ******* Main programme ****************************************
start 	movlw	0x0A		    ; Define time between data readings
	movwf	DataCount
	movlw	0x0D		    ; Callibrates between mV and T readings
	movwf	offset
	clrf	PORTJ, ACCESS	    ; Clears J, ensures heater off
	movlw	0x0A		    ; For comparison loops later (in T_in_d_h)
	movwf	tens
	movwf	units
	movwf	decimals
	call	LCD_User1
	call	T_in_d_h	    ; Converts input values in decimal to hex 
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	call	LCD_Clear
	call	LCD_User2
	bra	RoutineSelect
	
	; RoutineSelect:
	; Determines which routine will run based on user input (A, B or C)
	;			    - requires button press (A, B or C)
RoutineSelect
	call	Keypad		    ; Puts ascii value for A, B or C onto W
	movwf	Ascii
	call	LCD_Send_Byte_D	    ; Sends A, B or C to LCD
	call	SecondTimer	    ; Sets up timer/interrupts for data readings
	movf	Ascii, W
	cpfseq	Aascii		    ; Has routine A been selected?
	bra	Continue	    ; If not, check if B or C has been selected
	bra	TempLoop	    ; Else, run routine A (TempLoop)
Continue  
   	cpfseq	Bascii		    ; Has routine B been selected? 
	bra	TimeLoop	    ; If not, run routine C (TimeLoop)
	bra	Power		    ; Else, run routine C (Power)
	
	; TempLoop:
	; This is routine A - heater on until desired temperature is met
TempLoop			    
	call	TempIn_Alg	    ; Turns user input into a temperature
	call	ADC_Read	    
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	call	LCD_Clear
	call	LCD_Alg		    ; Outputs current temperature to LCD
	call	LCD_User3
	call	FDLP_Temp	    ; Determines in heater should be on/off
	goto	TempLoop	    ; Holds the system in this loop
	
	; Power:
	; This is routine B - heater on for a calculated amount of time, such 
	; that the desired temperature is reached when system = equilibrium
Power				    
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	call	LCD_Clear
	call	LCD_Alg		    ; Outputs current temperature to LCD
	call	PowerCheck	    ; Checks if Tdes > Tcurrent before heating
	movff	decimals, PowerResL ; Save desired temperature whilst warming up
	movff	units, PowerResH
	movff	tens, PowerResU
	movlw	0x09		    ; Sets up 5.9 minutes warm up time 
	movwf	decimals
	movlw	0x05		    
	movwf	units
	clrf	tens
	call	WarmUpTime	    ; Heater on for the given warm up time
	clrf	TimeL		    ; After warm up, clear the timer
	clrf	TimeH
	movff	PowerResL, decimals ; Reset desired temperature, for power loop
	movff	PowerResH, units
	movff	PowerResU, tens 
	call	Power_Alg	    ; Finds the required time for heater on 
	movlw	0x2C		    ; Accounts for the levelling off time
	subwf	TimeDesL, f	    ; of 240s (= 0x012C)
	movlw	0x01
	subwfb	TimeDesH, f
PowerLoop			    ; System sits in this loop for required time 
	call	ADC_Read	    
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	call	LCD_Clear
	call	LCD_Alg		    ; Outputs current temperature to LCD
	call	LCD_User3	    ; Outputs desired temperature to LCD
	call	FDLP_Time	    ; Determines if heater should be on/off
	goto	PowerLoop	    ; Holds the system in this loop
	
	; TimeLoop:
	; This is routine C - heater on until desired time has passed
TimeLoop			    
	call	Time_alg	    ; Turns user input into a time
	call	ADC_Read	    
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	call	LCD_Clear
	call	LCD_Alg		    ; Outputs current temperature to LCD
	call	FDLP_Time	    ; Determines if heater should be on/off
	goto	TimeLoop	    ; Holds the system in this loop
	
	; WarmUpTime:
	; Keeps the heater on for a set time, at the start of routine B
	; Follows a similar format to routine C
WarmUpTime
	call	Time_alg	    
	call	ADC_Read	    
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	call	LCD_Clear
	call	LCD_Alg		    ; Outputs current temperature to LCD
	call	LCD_User3	    ; Outputs the desired temperature to LCD
	call	FDLP_Time	    ; Determines if heater should be on/off
	clrf	0x00		    ; Condition to check if warm up time is 
	movf	PORTJ, W	    ; complete by checking if heater is on/off
	cpfseq	0x00
	goto	WarmUpTime	    ; Holds the system in this loop
	return			    ; Returns back to routine B once complete
	
	; delay:
	; A delay subroutine 
delay	decfsz	delay_count	    ; Decrement until zero
	bra delay
	return

	end