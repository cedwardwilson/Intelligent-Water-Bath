#include p18f87k22.inc
; File Overview:
; Contains UART setup and transmit functions to allow data to be sent to the
; serial port terminal

    ; Global routines/variables
    global  UART_Setup, UART_Transmit_Message, UART_Transmit_Byte

    ; Named variables in Access Ram
acs0    udata_acs	  
UART_counter res 1		; Reserve 1 byte for variable UART_counter

UART    code
    
UART_Setup
    bsf	    RCSTA1, SPEN	; Enable
    bcf	    TXSTA1, SYNC	; Synchronous
    bcf	    TXSTA1, BRGH	; Slow speed
    bsf	    TXSTA1, TXEN	; Enable transmit
    bcf	    BAUDCON1, BRG16	; 8-bit generator only
    movlw   .103		; Gives 9600 Baud rate (actually 9615)
    movwf   SPBRG1
    bsf	    TRISC, TX1		; TX1 pin as output
    return
    
UART_Transmit_Message		; Message stored at FSR2???, length stored in W
    movwf   UART_counter
UART_Loop_message
    movf    POSTINC2, W
    call    UART_Transmit_Byte
    decfsz  UART_counter
    bra	    UART_Loop_message
    return

    ; UART_Transmit_Byte:
	; Transmits a byte of information to the UART (which reads out in the
	; serial port terminal)
	;				- requires W (this is what is sent)
UART_Transmit_Byte	   
    btfss   PIR1,TX1IF		; TX1IF is set when TXREG1 is empty
    bra	    UART_Transmit_Byte	; Sits in this loops until byte is sent
    movwf   TXREG1
    return

    end


