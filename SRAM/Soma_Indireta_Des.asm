start:
    ldi r29, 0x01
    ldi r28, 0x00
    ld r0, Y
    
    ldd r1, Y+2
    
    add r0, r1
    
    std Y+4, r0
   
rjmp start