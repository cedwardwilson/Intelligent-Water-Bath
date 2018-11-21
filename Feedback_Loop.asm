#include p18f87k22.inc
; File Overview:
; Contains 2 routines for controlling the heater - one for timing and one for 
; temperature.
; Both are comparisons between a current value and a desired, which can then 
; turn the heater on/off as needed. 
; There are 2 subroutines at the end of the file for Heater On/Off. 
	
	; External and global routines/variables
	extern	    T_CrntH, T_CrntL, tempL, tempH, TimeDesL, TimeDesH 
	extern	    TimeL, TimeH
	global	    FDLP_Temp, FDLP_Time
	
	; Named variables in Access Ram
acs0    udata_acs
T_desL	res 1		; Low byte of desired temperature 
T_desH	res 1		; High byte of desired temperature 

Feedback_Loop	code

	; Temperature Feedback Loop - requires tempL, tempH, T_CrntH, T_CrntL
	;			    - sets W to 0 (if heater off) or 1 (else)
FDLP_Temp				   
	movff	tempL, T_desL	    ; Set up the low byte of the desired Temp.
	movff	tempH, T_desH	    ; Set up the high byte of the desired Temp.
	movf	T_desH, W
	cpfsgt	T_CrntH		    ; Compare current and desired high bytes
	bra	TempStep1	    ; If current =< desired, continue checking  
	bra	HeaterOff	    ; If current > desired, switch heater off
	
TempStep1			    
	cpfseq	T_CrntH		    ; Are high bytes of current/desired equal?
	bra	HeaterOn	    ; If not, current < desired. Heater on
				    ; If they are equal, continue checking
TempStep2		    
	movf	T_desL, W
	cpfsgt	T_CrntL		    ; Compare current and desired low bytes
	bra	TempStep3	    ; If current =< desired, continue checking
	bra	HeaterOff	    ; If current > desired, switch heater off
	
TempStep3	    
	cpfseq	T_CrntL		    ; Are low bytes of current/desired equal?  
	bra	HeaterOn	    ; If not, current < desired. Heater on
	bra	HeaterOff	    ; Else, current > desired. Heater off

	; Time Feedback Loop - requires TimeDesH, TimeDesL, TimeH, TimeL
	;		     - sets W to 0 (if heater off) or 1 (else)
FDLP_Time	    
	movf	TimeDesH, W
	cpfsgt	TimeH		    ; Compare current and desired high bytes
	bra	TimeStep1	    ; If current =< desired, continue checking 
	bra	HeaterOff	    ; If current > desired, switch heater off
	
TimeStep1	    
	cpfseq	TimeH		    ; Are high bytes of current/desired equal?
	bra	HeaterOn	    ; If not, current < desired. Heater on
				    ; If they are equal, continue checking
TimeStep2	    
	movf	TimeDesL, W
	cpfsgt	TimeL		    ; Compare current and desired low bytes
	bra	TimeStep3	    ; If current =< desired, continue checking
	bra	HeaterOff	    ; If current > desired, switch heater off
	
TimeStep3	    
	cpfseq	TimeL		    ; Are low bytes of current/desired equal?
	bra	HeaterOn	    ; If not, current < desired. Heater on
	bra	HeaterOff	    ; Else, current > desired. Heater off
	
; **Heater On/Off routines - either powering or disabling the BD135 transistor**
; Pin 0 (RJ0) on PORTJ controls the heater - low = heater off, high = heater on
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