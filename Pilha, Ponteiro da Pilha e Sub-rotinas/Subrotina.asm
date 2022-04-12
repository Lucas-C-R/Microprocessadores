;Definicoes
.equ LED = PD0
    
.equ BOTAO = PB0 
.equ BOTAO2 = PB1

start:
    ldi R16,0xFF	;carrega R16 com o valor 0xFF
    out DDRB,R16	;configurando DDRB como saida
    out PORTB, R16	;todos os pinos de PORTB comecam em 1

    ldi R16,0x00
    out DDRD,R16	;leds comecam desligados
    
    ;carrega R16 com o valor 0x01 (esse 1, foi para poder usar ror e rol)
    ldi R16,0x01
    
main:
    sbis PINB,BOTAO	;PB0 nao pressionado, pula a proxima linha
    rcall ajuste	;chama a sub-rotina
    sbis PINB,BOTAO2	;PB1 nao pressionado, pula a proxima linha
    rcall selecao	;chama a sub-rotina
    rjmp main		;volta para a linha 18
    

;Sub-rotina que liga sequencialmente os leds da esquerda para a direita
ajuste:
    cbi PORTD, LED	;desliga o pino atual
    ror R16		;rotaciona o bit 1 do R16 para a direita
    out DDRD,R16	;configura o pino deslocado como saida
    ldi r19,80		;configura o delay para 1s
    rcall delay		;chama a sub-rotina de atraso
    sbi PORTD, LED	;liga o pino atual
    ret			;encerra a sub-rotina
    

;Sub-rotina que liga sequencialmente os leds da direita para a esquerda
selecao:
    cbi PORTD, LED	;desliga o pino atual
    rol R16		;rotaciona o bit 1 do R16 para a esquerda
    out DDRD,R16	;configura o pino deslocado como saida
    ldi r19,16		;configura o delay para 200ms
    rcall delay		;chama a sub-rotina de atraso
    sbi PORTD, LED	;liga o pino atual
    ret			;encerra a sub-rotina
    
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