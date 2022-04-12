start:
    ldi r16,0xFF	;seta R16 para 0xFF (255)
    
main:
    out ddrd,r16	;liga os leds, baseado no valor de R16
    ldi r19,16		;configura o delay para 200ms
    subi r16,1		;R16--
    rcall delay		;chama o delay
    
    rjmp main
    
delay:
    push r17		;salva os valores de r17,
    push r18		;... r18,
    in r17,SREG		;...
    push r17		;... e SREG na pilha.

    ; Executa sub-rotina :
    clr r17
    clr r18
loop:
    dec R17		;decrementa R17, come¸ca com 0x00
    brne loop		;enquanto R17 > 0 fica decrementando R17
    dec R18		;decrementa R18, come¸ca com 0x00
    brne loop		;enquanto R18 > 0 volta decrementar R18
    dec R19		;decrementa R19
    brne loop		;enquanto R19 > 0 vai para volta

    pop r17
    out SREG, r17	;restaura os valores de SREG,
    pop r18		;... r18
    pop r17		;... r17 da pilha
    
    ret
    