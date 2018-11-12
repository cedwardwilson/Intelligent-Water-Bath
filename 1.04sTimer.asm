#include p18f87k22.inc

	global	    SecondTimer, DataLow, DataHigh, DataTop, DataUp
	extern	    TimerCount, DataCount, ReadOut
	
acs0    udata_acs		    ; named variables in access ram
    
DataTop	    res 1	    ;for data readout to UART (for graphing)
DataHigh    res 1
DataUp	    res 1
DataLow	    res 1
	    
    
int_hi	code	    0x0008		; high vector, no low vector
	btfss	    INTCON,TMR0IF	; check that this is timer0 interrup
	retfie	    FAST		; if not then return
	incf	    TimerCount		; increment TimerCount
	movf	    TimerCount, W
	cpfseq	    DataCount
	bra	    ContInt		; if des. time has not elapsed, continue
	movf	    DataTop, W		; sends the current temp to UART
	call	    UART_Transmit_Byte
	movf	    DataUp, W
	call	    UART_Transmit_Byte
	movf	    DataHigh, W
	call	    UART_Transmit_Byte
	movlw	    '.'			; manual input of decimal point
	call	    UART_Transmit_Byte
	movf	    DataLow, W
	call	    UART_Transmit_Byte
	movlw	    ','			; comma will help when plotting in py.
	call	    UART_Transmit_Byte
	clrf	    TimerCount		; start timer again
ContInt	bcf	    INTCON,TMR0IF	; clear interrupt flag
	retfie	    FAST		; fast return from interrupt
	
UART_Transmit_Byte			; sends a byte to UART (from W)
	btfss   PIR1,TX1IF		; TX1IF is set when TXREG1 is empty
	bra	UART_Transmit_Byte
	movwf   TXREG1
	return
	
main	code
SecondTimer	clrf	TimerCount
		movlw	b'10000111'	; Set timer0 to 16-bit, Fosc/4/256
		movwf	T0CON		; = 62.5KHz clock rate, approx 1sec rollover
		bsf	INTCON,TMR0IE	; Enable timer0 interrupt
		bsf	INTCON,GIE	; Enable all interrupts
		return			;go back and keep running
	
		end



