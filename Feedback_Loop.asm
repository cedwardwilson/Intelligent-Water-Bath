#include p18f87k22.inc
	
	extern	    T_CrntH, T_CrntL, tempL, tempH, TimeDesL, TimeDesH, TimeL, TimeH
	global	    FDLP_Temp, FDLP_Time
acs0    udata_acs		    ; named variables in access ram
T_desL	res 1		;2 bytes for input desired temp
T_desH	res 1

Feedback_Loop	code
	
FDLP_Temp				    ; Temperature Feedback Loop
	movff	tempL, T_desL	    ;use the keypad in temp for comparison
	;movlw	0xF0		    ;manual input desired T
	;movwf	T_desL
	movff	tempH, T_desH
	;movlw	0x00
	;movwf	T_desH	    
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

FDLP_Time	    
	movf	TimeDesH, W
	cpfsgt	TimeH		    ;compare high bytes (current/desired)?
	bra	TimeStep1
	bra	HeaterOff
	
TimeStep1	    ;are the high bytes equal (current/desired)?
	cpfseq	TimeH
	bra	HeaterOn 
	
TimeStep2	    ;compare low bytes (current/desired)?
	movf	TimeDesL, W
	cpfsgt	TimeL
	bra	TimeStep3
	bra	HeaterOff
	
TimeStep3	    ;are the low bytes equal (current/desired)?
	cpfseq	TimeL
	bra	HeaterOn
	bra	HeaterOff
; **Heater On/Off routines - either powering or disabling the BD135 transistor**
	;pin 1 on PORTJ controls the heater - low = heater off, high = heater on
HeaterOff
	clrf	TRISJ
	movlw	0x00
	movwf	PORTJ
	return
	
HeaterOn
	clrf	TRISJ
	movlw	0x01
	movwf	PORTJ
	return 

	end