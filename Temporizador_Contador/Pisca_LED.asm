.INCLUDE <m328Pdef.inc>
    
.def ticks = r17
.equ botao = pd2
.def valor = r18
.def compare = r19
    
.ORG 0x0000	    ; Vetor reset
    RJMP setup
    
.ORG 0x0002
    RJMP isr_int0
    
.ORG 0x0020	    ; Vetor(endereco na Flash) do estouro do T/C0
    RJMP isr_tc0b 

setup: 
    sbi DDRB, PB5 
    cbi PORTB, PB5	; desliga led
    sbi DDRD, botao	; configura o PD2 como entrada
    sbi PORTD, botao	; liga o pull-up do PD2

    ldi r16, 0b00000101 ;TC0 com prescaler de 1024, a 16 MHz gera
    out TCCR0B, r16	;uma interrupcao a cada 16,384 ms
    LDI r16, 1
    sts TIMSK0, r16     ; habilita int. do TC0B(TIMSK0(0)=TOIE0 <- 1)
    
    LDI r16, 0x01 
    STS EICRA, r16	; config. INT0 sensivel a borda
    SBI EIMSK, INT0	; habilita a INT0
    
    ldi valor, 13

    sei			    ; habilita as interrupcoes globais

main:
    rjmp main

;---------------------------------------------
; Rotina de interrupcao baseada em tempo
;---------------------------------------------
isr_tc0b:
    push r16		; 
    in r16, SREG	; Salva o contexto (SREG)
    push r16		;
    
    inc ticks
    rcall metade	    ; chama a sub-rotina que divide o valor
    cp ticks, compare	    ; compara se deve inverter o estado do LED
    brlt fim		    
    sbi PINB, PB5	    ; inverte o estado do LED depois de entrar x vezes
			    ; na interrupcao: x = compare
    ldi ticks,0
    
fim:
    pop r16		; 
    in r16, SREG	; Restaura o contexto (SREG)
    pop r16		;
    
    reti

;----------------------------------------------------------------------------
; Sub-rotina que divide o tempo de operacao do led ao meio (metade ele fica
; aceso e metade, apagado)
;----------------------------------------------------------------------------
metade:
    push valor	    ; guarda na pilha, o valor
    ldi compare, 0
    
looping:
    cpi valor, 2	; compara se o dividendo e menor que o divisor
    brlt fim_metade	; se for, encera o looping
    
    subi valor, 2
    inc compare
    
    rjmp looping
    
fim_metade:
    pop valor	    ; restaura o valor
    ret
    
;-------------------------------------------------------------
; Rotina de interrupcao baseada em interrupcao externa (botao)
;-------------------------------------------------------------
isr_int0:
    push r16		; 
    in r16, SREG	; Salva o contexto (SREG)
    push r16		;
    
    cpi valor, 65	; se o valor chegar em 65 (1 segundo), reseta tudo
    breq reduz
    
adiciona:
    subi valor, -13
    rjmp fim_int0
    
reduz:
    ldi valor, 13
    
fim_int0:
    pop r16		; 
    in r16, SREG	; Restaura o contexto (SREG)
    pop r16		;
    
    reti