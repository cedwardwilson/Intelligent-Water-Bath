	#include p18f87k22.inc
; The RunMe file is the central file to the whole project - it shows the 
; progression of the code from Temp/Time input to Routine Select and then 
; through each routine as needed 
	
	; External and global routines/variables
	extern  LCD_Setup, ADC_Setup, UART_Setup, SecondTimer
	extern	FDLP_Time, FDLP_Temp, Time_alg, Power_Alg, TempIn_Alg, LCD_Alg
	extern  ADC_Read, LCD_Clear, LCD_Send_Byte_D, LCD_delay_ms, PowerCheck
	extern	Keys_Translator, LookUp_d_h, M_Table, Keypad, T_in_d_h
	extern	tens, units, decimals, TimeDesL, TimeDesH
	global	T_CrntL, T_CrntH, offset, TimerCount, DataCount, TimeL, TimeH
	global	delay, TempLoop
	
	; Named variables in access ram
acs0	    udata_acs		    
counter	    res 1		    ; reserve one byte for a counter variable
delay_count res 1		    ; reserve one byte for counter in the delay routine
offset	    res 1		    ; reserve one byte for the offset in the V-T conversion
T_CrntL	    res 1
T_CrntH	    res 1		    ; reserved for the current voltage readout off the LM35
TimerCount  res 1		    ; number of seconds passed between data readouts
DataCount   res 1		    ; number of seconds between data readouts
TimeL	    res 1		    ; 2 bytes for the 'real time'
TimeH	    res 1
Aascii	    res 1		    ; for routine select (A, B or C)
Bascii	    res 1
Cascii	    res 1
Ascii	    res 1		    ; holds the ascii in routine select
PowerResL   res 1		    ; for holding power vals whilst warming up
PowerResH   res 1
PowerResU   res 1

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
	clrf	TimerCount	    ; reset the timers
	clrf	DataCount
	clrf	TimeL
	clrf	TimeH
	movlw	0x41
	movwf	Aascii
	movlw	0x42
	movwf	Bascii
	movlw	0x43
	movwf	Cascii
	goto	start
	
	; ******* Main programme ****************************************
start 	movlw	0x0A		    ; define time in sec between data readings
	movwf	DataCount
	movlw	0x0D		    ; callibrates between mV and T readings
	movwf	offset
	clrf	PORTJ, ACCESS	    ;cleared for use later with powering heater
	movlw	0x0A		    ; for comparison loops later (in T_in_d_h)
	movwf	tens
	movwf	units
	movwf	decimals
	call	T_in_d_h	    ; converts Temp in decimal to hex voltage
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	call	LCD_Clear
	call	SecondTimer	    ; sets up timer/interrupts for data readings
	bra	RoutineSelect
	
RoutineSelect
	call	Keypad		    ; puts ascii value for A, B or C onto W
	movwf	Ascii
	call	LCD_Send_Byte_D
	movf	Ascii, W
	cpfseq	Aascii		    ; routine A select?
	bra	Continue
	bra	TempLoop
Continue  
   	cpfseq	Bascii		    ; routine B or C select? 
	bra	TimeLoop
	bra	Power
	
TempLoop			    ; Routine A: input temp vs current temp
	call	TempIn_Alg
	call	ADC_Read	    ; get out a hex value for voltage
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	call	LCD_Clear
	call	LCD_Alg		    ; converts hex to decimal and output to LCD
	call	FDLP_Temp	    ; determines in heater should be on/off
	goto	TempLoop	    ; holds the system in this loop
		
Power				    ; Routine B: power calculation controls heat
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	call	LCD_Clear
	call	LCD_Alg
	call	PowerCheck
	movff	decimals, PowerResL    ; save power vals (Tdesired) whilst warming up
	movff	units, PowerResH
	movff	tens, PowerResU
	movlw	0x09
	movwf	decimals
	movlw	0x05		    ; 5.9 minutes warm up time - is actually 370s (including x1.04 correction)
	movwf	units
	clrf	tens
	call	WarmUpTime
	clrf	TimeL
	clrf	TimeH
	movff	PowerResL, decimals
	movff	PowerResH, units
	movff	PowerResU, tens 
	call	Power_Alg	    ; after this, TimeDesL/H store the time to run for
	movlw	0x2C		    ; this is an offset for the levelling off time
	subwf	TimeDesL, f	    ; of 240s (*1.04 therefore actually 250s)
	movlw	0x01
	subwfb	TimeDesH, f
PowerLoop			    ; we only want to set the desired time once
				    ; so we only loop to PowerLoop, not the top
	call	ADC_Read	    ; of the Power routine
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	call	LCD_Clear
	call	LCD_Alg
	call	FDLP_Time
	goto	PowerLoop
	
TimeLoop			    ; Routine C: input time vs current time
	call	Time_alg
	call	ADC_Read	    ; get out a hex value for voltage
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	call	LCD_Clear
	call	LCD_Alg		    ; converts hex to decimal and output to LCD
	call	FDLP_Time
	goto	TimeLoop
	
WarmUpTime
	call	Time_alg
	call	ADC_Read	    ; get out a hex value for voltage
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	movlw	.250
	call	LCD_delay_ms
	call	LCD_Clear
	call	LCD_Alg		    ; converts hex to decimal and output to LCD
	call	FDLP_Time
	clrf	0x00		    ; this condition may not be working????
	movf	PORTJ, W
	cpfseq	0x00
	goto	WarmUpTime
	return
	
	; a delay subroutine if you need one, times around loop in delay_count
delay	decfsz	delay_count	; decrement until zero
	bra delay
	return

	end