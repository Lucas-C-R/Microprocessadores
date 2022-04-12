.equ aux = pd3
    
start:
    ldi r16,0x00
    out ddrd,r16	;desliga todos os leds
    ldi r16,0x01	;seta o R16 para usar o rol
    ldi r26,0x80	;seta o R26 para usar o ror
    ldi r30, 0x00	;zera o R30
    rcall delay		;chama o delay
    
main:
    add r30, r26	;R30 += R26
    add r30, r16	;R30 += R16
    out ddrd,r30	;define os pinos ativos, baseado no R30
    rcall delay
    rol r16		;rotaciona o bit 1 do R16 para a esquerda
    ror r26		;rotaciona o bit 1 do R26 para a direita
    sbic ddrd, aux	;se PD3 esta ligado, desliga os leds
    rjmp start
    
    rjmp main
    
    
delay:
    ldi r19,80		;configura o delay para 1s
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