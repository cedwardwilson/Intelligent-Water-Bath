#include p18f87k22.inc
	
	extern	    T_CrntH, T_CrntL, measure_loop
	global	    FDLP
acs0    udata_acs		    ; named variables in access ram
T_desL	res 1		;2 bytes for input desired temp
T_desH	res 1

Feedback_Loop	code
	
FDLP	
	movlw	0x0C		    ;manual input desired T
	movwf	T_desL
	movlw	0x01
	movwf	T_desH	    
	movf	T_desH, W
	cpfsgt	T_CrntH		    ;compare high bytes (current/desired)?
	bra	Heql_cmp
	bra	HeaterOff
	
Heql_cmp	    ;are the high bytes equal (current/desired)?
	cpfseq	T_CrntH
	bra	HeaterOn 
	
Low_cmp		    ;compare low bytes (current/desired)?
	movf	T_desL, W
	cpfsgt	T_CrntL
	bra	Equal_comp
	bra	HeaterOff
	
Equal_comp	    ;are the low bytes equal (current/desired)?
	cpfseq	T_CrntL
	bra	HeaterOn
	bra	HeaterOff

ReadOut	    ;this will be filled later, for efficiency/timing estimations
	nop
	return
	
; **Heater On/Off routines - either powering or disabling the BD135 transistor**
	;pin 1 on PORTJ controls the heater - low = heater off, high = heater on
HeaterOff
	clrf	TRISJ
	movlw	0x00
	movwf	PORTJ
	bra	ReadOut
	
HeaterOn
	clrf	TRISJ
	movlw	0x01
	movwf	PORTJ
	bra	ReadOut

	end