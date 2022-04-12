start:
    ldi r27, 0x01
    ldi r26, 0x00
    ld r0, X
    
    ldi r27, 0x01
    ldi r26, 0x01
    ld r1, X
    
    add r0, r1
    
    ldi r27, 0x01
    ldi r26, 0x02    
    st X, r0
    
rjmp start