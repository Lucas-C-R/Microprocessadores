.INCLUDE <m328Pdef.inc>

;DEFINI¸C~OES
.equ BOTAO = PD3
.equ L0 = PB0
.equ L1 = PB1
.def AUX = R16

.ORG 0x0000		; Reset vector
    RJMP setup

.ORG 0x0002		; Vetor (endereco na Flash) da INT0
    RJMP isr_int0

.ORG 0x0034		;primeira end. livre depois dos vetores
setup:
    ldi AUX,0x03	; 0b00000011
    out DDRB,AUX	; configura PB3/2 como sa?da
    out PORTB,AUX	; desliga os LEDs
    sbi DDRD, BOTAO	; configura o PD3 como entrada
    sbi PORTD, BOTAO	; liga o pull-up do PD3

    LDI AUX, 0x01 
    STS EICRA, AUX	; config. INT0 sens´?vel a borda
    SBI EIMSK, INT0	; habilita a INT0

    SEI			; habilita a interrup¸c~ao global ...
			; ... (bit I do SREG)
main:
    sbi PORTB,L0	; desliga L0
    ldi r19, 160
    rcall delay		; delay 1s
    cbi PORTB,L0	; liga L0
    ldi r19, 160
    rcall delay		; delay 1s
    rjmp main

;-------------------------------------------------
; Rotina de Interrup¸c~ao (ISR) da INT0
;-------------------------------------------------
isr_int0:
    push R16		; Salva o contexto (SREG)
    in R16, SREG
    push R16

    sbic PIND,BOTAO	; botao press. salta a pr´oxima inst.
    rjmp desliga
    cbi PORTB,L1	; liga L1
    rjmp fim
desliga:
    sbi PORTB,L1	; desliga L1

fim:
    pop R16		; Restaura o contexto (SREG)
    in R16, SREG
    pop R16
    reti		; retorna da interrupcao

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