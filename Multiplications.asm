#include p18f87k22.inc
; File Overview:
; Contains routines for doing 16 by 16 bit and 8 by 24 bit multiplication
    
	; External and global routines/variables
	global	    M_16x16, M_8x24, M_SelectHigh, M_Move
	global	    numbH, numbL, numbU, ru
	extern	    delay
    
	; Named variables in Access Ram
acs0		udata_acs
numa		res 1		; Variable storage bytes
numbH		res 1		; "
numbL		res 1		; "    
numbU		res 1		; "  
numcH		res 1		; "  
numcL		res 1		; "  
tmpnumLL	res 1		; "  
tmpnumLH	res 1		; "  
tmpnumLU	res 1		; "  
tmpnumHL	res 1		; "  
tmpnumHH	res 1		; "  
tmpnumHU	res 1		; "  
tmpnumUL	res 1		; "  
tmpnumUH	res 1		; "  
tmpnumUU	res 1		; "  
rb		res 1		; "  	   
rl		res 1		; "  	    
rh		res 1		; "  	    
ru		res 1		; "  
rt		res 1		; "  
purse		res 1		; "  
		
Multiplications	code
	
	; M_16x16:
	; Multiplies two 16 bit numbers together
	;			- requires numbL, numbH ( = 16 bit number)
	;			- puts result into rb, rl, rh, ru
M_16x16				 
    call    M_16Setup		
    movff   numcL, numa
    call    M_CalculateL
    movff   numcH, numa
    call    M_CalculateH
    call    M_addHL16
    return
  
	; M_8x24:
	; Multiplies an 8 bit and a 24 bit number together
	;			- requires numbL, numbH, numbU (= 24 bit number)
	;			- puts result into rb, rl, rh, ru, rt
M_8x24				
    call    M_24Setup		
    call    M_CalculateL
    call    M_CalculateU
    call    M_addHL24
    return
  
M_16Setup			
    clrf    tmpnumLL		; Ensures temporary files are clear
    clrf    tmpnumLH
    clrf    tmpnumLU
    clrf    tmpnumHL
    clrf    tmpnumHH
    clrf    tmpnumHU	
    movlw   0x8A		; This forces one of 16 bit numbers to always
    movwf   numcL		; be 0x418A ( = 16778, for ADC)
    movlw   0x41
    movwf   numcH
    return
  
M_24Setup			
    clrf    tmpnumLL		; Ensures temporary files are clear
    clrf    tmpnumLH
    clrf    tmpnumLU
    clrf    tmpnumHL
    clrf    tmpnumHH
    clrf    tmpnumHU	
    movlw   0x0A		; This forces 8 bit number to be 10 (0x0A)
    movwf   numa
    return
  
M_CalculateL		  ;calculating low byte of result from multiplication
			  ;involving adding with carries
    movf    numa, W
    mulwf   numbL
    movff   PRODL, tmpnumLL
    movff   PRODH, purse
    mulwf   numbH
    movf    purse, W
    addwf   PRODL, W
    movwf   tmpnumLH
    movf    PRODH, W
    addwfc  tmpnumLU, f
    return
  
M_CalculateH		   ;calculating high byte of result from multiplication
			   ;involving adding with carries
    movf    numa, W	   
    mulwf   numbL
    movff   PRODL, tmpnumHL
    movff   PRODH, purse
    mulwf   numbH
    movf    purse, W
    addwf   PRODL, W
    movwf   tmpnumHH
    movf    PRODH, W
    addwfc  tmpnumHU, f
    return
  
M_CalculateU		   ;calculating upper byte of result from multiplication
			   ;involving adding with carries
    movf    numa, W
    mulwf   numbU
    movff   PRODL, tmpnumUL
    movff   PRODH, tmpnumUH
    return
 
M_addHL16			;addition to give final 16x16 bit calculation
    movff   tmpnumLL, rb
    movf    tmpnumLH, w
    addwf   tmpnumHL, w
    movwf   rl
    movf    tmpnumLU,w
    addwfc  tmpnumHH, f
    movff   tmpnumHH, rh
    movlw   0x0
    addwfc  tmpnumHU, f
    movff   tmpnumHU, ru
    return
  
M_addHL24			;addition to give final 8x24 bit calculation
    movff   tmpnumLL, rb
    movff   tmpnumLH, rl
    movf    tmpnumLU, W
    addwf   tmpnumUL, f
    movff   tmpnumUL, rh
    movlw   0x0
    addwfc  tmpnumUH, f
    movff   tmpnumUH, ru
    return
 
M_SelectHigh	    		   ;grabs top byte of result of latest multiply
    movf    ru, W, ACCESS	   ;ru is upper byte of the result  
    movff   PLUSW2, purse	   ;puts value at fsr2+w into purse  	
    call    delay			
    movf    purse, W
    return

M_Move				    ;moves latest result into correct bytes 
    movff   rb, numbL		    ;so it can be used again in following calc
    movff   rl, numbH
    movff   rh, numbU
    return
    
    end


