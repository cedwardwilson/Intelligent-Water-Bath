#include p18f87k22.inc
; File Overview:
; Contains an interrupt routine that counts every second (actually 1.04seconds)
; Within the interrupt, data is taken if 10 interrupts have run since the last
; data reading
; This data is sent to the UART (so it appears in the serial port terminal)
	
	; External and global routines/variables
	global	    SecondTimer, DataLow, DataHigh, DataTop, DataUp
	extern	    TimerCount, DataCount, TimeL, TimeH
	
	; Named variables in Access Ram
acs0    udata_acs		    
DataTop	    res 1			; To send the highest digit to UART
DataHigh    res 1			; To send the next digit to UART
DataUp	    res 1			; To send the next digit to UART
DataLow	    res 1			; To send the lowest digit to UART
	    
    ; int_hi:
    ; A high priority interrupt that is called every 1.04 seconds whilst the 
    ; code runs
    ; Sends the current temperature reading to the serial port terminal, such
    ; that it can be graphed in a python script
    ;					- requires TimerCount, DataCount, TimeL,
    ;					TimeH
    ;					- changes TimerCount, TimeL, TimeH
    ;					- sets DataTop, DataHigh, DataUp,
    ;					DataLow
int_hi	code	    0x0008		
	btfss	    INTCON,TMR0IF	; Check that this is timer0 interrupt
	retfie	    FAST		; If not, return
	incf	    TimeL		; Increment TimeL (every 1.04s)
	movlw	    0x0
	cpfseq	    TimeL		; Check if carry has happened
	bra	    Cont		; If not, continue with interrupt 
	incf	    TimeH		; Else, increment TimeH
Cont	incf	    TimerCount		; Increment TimerCount (every 1.04s)
	movf	    TimerCount, W	
	cpfseq	    DataCount		; Check if time between readings has passed
	bra	    ContInt		; If not, skip data read out 
	movf	    DataTop, W		; Else, begin transmitting data to UART
	call	    UART_Transmit_Byte
	movf	    DataUp, W
	call	    UART_Transmit_Byte
	movf	    DataHigh, W
	call	    UART_Transmit_Byte
	movlw	    '.'			; Forcing a decimal place into the data
	call	    UART_Transmit_Byte
	movf	    DataLow, W
	call	    UART_Transmit_Byte
	movlw	    ','			; Forcing a comma between readings
	call	    UART_Transmit_Byte
	clrf	    TimerCount		; Start timer between readings again
ContInt	bcf	    INTCON,TMR0IF	; Clear interrupt flag
	retfie	    FAST		; Fast return from interrupt
	
	; UART_Transmit_Byte:
	; Transmits a byte of information to the UART (which reads out in the
	; serial port terminal)
	;				- requires W (this is what is sent)
UART_Transmit_Byte			
	btfss   PIR1,TX1IF		; TX1IF is set when TXREG1 is empty
	bra	UART_Transmit_Byte	; Sits in this loops until byte is sent
	movwf   TXREG1
	return
	
main	code
	; SecondTimer:
	; Sets up the interrupt timer (to allow data to be taken at specific 
	; timing intervals, and the time comparsion loop to work)
	; Once run, the interrupts then run for the entirety of the code 
SecondTimer	
	clrf	TimerCount
	movlw	b'10000111'		; Set timer0 to 16-bit, Fosc/4/256
	movwf	T0CON			; = 62.5KHz clock rate - 1.04s rollover
	bsf	INTCON,TMR0IE		; Enable timer0 interrupt
	bsf	INTCON,GIE		; Enable all interrupts
	return	
	
	end



