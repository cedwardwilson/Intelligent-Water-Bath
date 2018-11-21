#include p18f87k22.inc
; File Overview:
; Sets up 3 look-up tables: LookUp_d_h, Keys_Translator, and M_Table
; LookUp_d_h - uses FSR0 and Bank 5 
; Keys_Translator - uses FSR1 and Bank 4
; M_Table - uses FSR2 and Bank 6
    
    ; External and global routines/variables
    global	    Keys_Translator, LookUp_d_h, M_Table
    extern	    tmpval
    
Look_Ups code

	; LookUp_d_h:
	; Stores values 0 - 9 at the equivalent binary file address as 
	; corresponds to a button press on the keypad
	; Uses FSR0 and Bank 5
LookUp_d_h		
	movlb	5			
	lfsr	FSR0, 0x580		; Start at 0x580 address in Bank 5
	movlw	0x01			
	movwf	tmpval
	movlw	0x77
	movff	tmpval,PLUSW0		; N.B. PLUSW0 does not change FSR0
	movlw	0x02
	movwf	tmpval
	movlw	0xB7
	movff	tmpval,PLUSW0
	movlw	0x03
	movwf	tmpval
	movlw	0xD7
	movff	tmpval,PLUSW0
	movlw	0x04
	movwf	tmpval
	movlw	0x7B
	movff	tmpval,PLUSW0
	movlw	0x05
	movwf	tmpval
	movlw	0xBB 
	movff	tmpval,PLUSW0
	movlw	0x06
	movwf	tmpval
	movlw	0xDB
	movff	tmpval,PLUSW0
	movlw	0x07
	movwf	tmpval
	movlw	0x7D
	movff	tmpval,PLUSW0
	movlw	0x08
	movwf	tmpval
	movlw	0xBD
	movff	tmpval,PLUSW0
	movlw	0x09
	movwf	tmpval
	movlw	0xDD
	movff	tmpval,PLUSW0
	movlw	0x0
	movwf	tmpval
	movlw	0xBE
	movff	tmpval, PLUSW0
	return
	
	; Keys_Translator:
	; Stores ascii code for  0 - 9, A - D, * and # at the equivalent binary 
	; file address as corresponds to a button press on the keypad
	; Uses FSR1 and Bank 4
Keys_Translator		
	movlb	4			
	lfsr	FSR1, 0x480		; Start at 0x480 address in Bank 4
	movlw	'1'			
	movwf	tmpval
	movlw	0x77
	movff	tmpval,PLUSW1		; N.B. PLUSW1 does not change FSR1
	movlw	'2'
	movwf	tmpval
	movlw	0xB7
	movff	tmpval,PLUSW1
	movlw	'3'
	movwf	tmpval
	movlw	0xD7
	movff	tmpval,PLUSW1
	movlw	'4'
	movwf	tmpval
	movlw	0x7B
	movff	tmpval,PLUSW1
	movlw	'5'
	movwf	tmpval
	movlw	0xBB 
	movff	tmpval,PLUSW1
	movlw	'6'
	movwf	tmpval
	movlw	0xDB
	movff	tmpval,PLUSW1
	movlw	'7'
	movwf	tmpval
	movlw	0x7D
	movff	tmpval,PLUSW1
	movlw	'8'
	movwf	tmpval
	movlw	0xBD
	movff	tmpval,PLUSW1
	movlw	'9'
	movwf	tmpval
	movlw	0xDD
	movff	tmpval,PLUSW1
	movlw	'A'		    
	movwf	tmpval		    
	movlw	0xE7
	movff	tmpval,PLUSW1
	movlw	'B'
	movwf	tmpval
	movlw	0xEB
	movff	tmpval,PLUSW1
	movlw	'C'
	movwf	tmpval
	movlw	0xED
	movff	tmpval,PLUSW1
	movlw	'D'
	movwf	tmpval
	movlw	0xEE
	movff	tmpval,PLUSW1
	movlw	'0'
	movwf	tmpval
	movlw	0xBE
	movff	tmpval, PLUSW1
	movlw	'*'
	movwf	tmpval
	movlw	0x7E
	movff	tmpval,PLUSW1
	movlw	'#'
	movwf	tmpval
	movlw	0xDE			
	movff	tmpval,PLUSW1		
	return

	; M_Table:
	; Stores ascii code for  0 - 9 at the equivalent hex file address as 
	; corresponds to their values, 0 - 9
	; Uses FSR2 and Bank 6
M_Table			   
	movlb   6		    
	lfsr    FSR2, 0x680	    ; Start at 0x680 address in Bank 6
        movlw   '1'		    
        movwf   tmpval
        movlw   0x1
	movff   tmpval,PLUSW2	    ; N.B. PLUSW2 does not change FSR2
	movlw   '2'
	movwf   tmpval
	movlw   0x2
	movff   tmpval,PLUSW2
	movlw   '3'
	movwf   tmpval
	movlw   0x3
	movff   tmpval,PLUSW2
	movlw   '4'
	movwf   tmpval
	movlw   0x4
	movff   tmpval,PLUSW2
	movlw   '5'
    	movwf   tmpval
	movlw   0x5 
	movff   tmpval,PLUSW2
	movlw   '6'
	movwf   tmpval
	movlw   0x6
	movff   tmpval,PLUSW2
	movlw   '7'
	movwf   tmpval
	movlw   0x7
	movff   tmpval,PLUSW2
	movlw   '8'
	movwf   tmpval
	movlw   0x8
	movff   tmpval,PLUSW2
	movlw   '9'
	movwf   tmpval
	movlw   0x9
	movff   tmpval,PLUSW2
	movlw   '0'
	movwf   tmpval
	movlw   0x0
	movff   tmpval,PLUSW2
	return

	end