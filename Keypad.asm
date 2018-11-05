#include p18f87k22.inc

    extern  LCD_delay
  
;Setup	
   ; bsf	    PADCFG1, REPU, banked
    ;clrf    LATE
    ;movlw   b'00001111'
    ;movwf   TRISE, ACCESS
;translator  res  0x14		;reserve 20 bytes for translator data
Test	
    movlw   b'00001111'
    movwf   PORTE, ACCESS
    
    end

