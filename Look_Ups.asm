#include p18f87k22.inc
    
    global	    Keys_Translator, LookUp_d_h, M_Table
    extern	    tmpval
    
Look_Ups code

Keys_Translator		;sets the values of the keys of our keypad
	movlb	4			;use Bank 4
	lfsr	FSR1, 0x480		;start at 0x480 address in Bank 4
	movlw	'1'			;store ascii characters in files in Bank 4
	movwf	tmpval
	movlw	0x77
	movff	tmpval,PLUSW1		;N.B. PLUSWn does not change FSRn
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
	movlw	0xDE			;keypad can now write 'TEMP' and 'TIME'
	movff	tmpval,PLUSW1		;as well as numbers 0-9
	return

LookUp_d_h		;sets the values of the keys of our keypad
	movlb	5			;use Bank 5
	lfsr	FSR0, 0x580		;start at 0x580 address in Bank 5
	movlw	0x01			;store ascii characters in files in Bank 5
	movwf	tmpval
	movlw	0x77
	movff	tmpval,PLUSW0		;N.B. PLUSWn does not change FSRn
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

M_Table			    ;lookup table (basically)
    movlb   6		    ;use Bank 6
    lfsr    FSR2, 0x680	    ;start at 0x680 address in Bank 6
    movlw   '1'		    ;ascii characters into files in Bank 6
    movwf   tmpval
    movlw   0x1
    movff   tmpval,PLUSW2
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