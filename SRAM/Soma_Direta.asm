start:
    lds r27, 0x0100
    lds r29, 0x0101
    add r27, r29
    sts 0x0102, r27
    
rjmp start