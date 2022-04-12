.EQU botao = PD2
.EQU botao2 = PD3
    
.DSEG
.ORG SRAM_START
    satisfeito: .BYTE 1		; alocando 8 bits(1 byte) para o rotulo
    insatisfeito: .BYTE 1	;                  ""
    botao_flag: .BYTE 1		;                  ""
    wr_flag: .BYTE 1		;                  ""
 
.CSEG 
.ORG 0x0000			; vetor reset
    rjmp setup
 
.ORG 0x0002
    rjmp isr_int0
    
.ORG 0x0004
    rjmp isr_int1
    
.ORG 0x0020	    
    rjmp isr_tc0b
    
.ORG 0x0034
setup:
    ldi r16, 0
    sts satisfeito, r16
    sts insatisfeito, r16
    sts botao_flag, r16
    sts wr_flag, r16
    
    cbi DDRD, botao		; configura o PD2 como entrada
    sbi PORTD, botao		; liga o pull-up do PD2
    
    cbi DDRD, botao2		; configura o PD3 como entrada
    sbi PORTD, botao2		; liga o pull-up do PD3
    
    rcall init_ssds		; configura os displays
    
    ldi r16, 0x0A		; 0b00001010
    sts EICRA, r16		; config. INT0 e INT1 sensiveis a borda de descida
    sbi EIMSK, INT0		; habilita o INT0
    sbi EIMSK, INT1		; habilita o INT1
    
    ldi r16, 0b00000101		; TC0 com prescaler de 1024, a 16 MHz gera
    out TCCR0B, r16		; uma interrupcao a cada 16,384 ms
    LDI r16, 1
    sts TIMSK0, r16		; habilita int. do TC0B(TIMSK0(0)=TOIE0 <- 1)
    
    sei				; habilita as interrupcoes globais
    
main:
    lds r16, botao_flag
    cpi r16, 1			; verifica se o 'botao_flag' esta em 1
    breq desativa_int
    rjmp main
    
desativa_int:
    cbi EIMSK, INT0		; desabilita o INT0
    cbi EIMSK, INT1		; desabilita o INT1
    
    ldi r19, 160		; sub-rotina de atraso de 2s 
    rcall delay
    
    ldi r16, 0			; zera o
    sts botao_flag, r16		; 'botao_flag'
    
    sbi EIFR, INTF0
    sbi EIFR, INTF1
    
    sbi EIMSK, INT0		; habilita o INT0
    sbi EIMSK, INT1		; habilita o INT1
    
    rjmp main

;-----------------------------------------------------
; Rotina de interrupcao que incrementa os satisfeitos
;-----------------------------------------------------    
isr_int0:			
    push r16			; 
    in r16, SREG		; salva o contexto (SREG)
    push r16			;
    push r20
    
    lds r20, satisfeito
    
    cpi r20, 15			; verifica se os displays ja chegaram em 15
    breq fim_int0
    
    inc r20
    sts satisfeito, r20
    
    ldi r20, 1
    sts botao_flag, r20
    
fim_int0:
    pop r20
    pop r16			; 
    out SREG, r16		; Restaura o contexto (SREG)
    pop r16			;
    reti

;-------------------------------------------------------
; Rotina de interrupcao que incrementa os insatisfeitos
;-------------------------------------------------------    
isr_int1:
    push r16			; 
    in r16, SREG		; salva o contexto (SREG)
    push r16			;
    push r20
    
    lds r20, insatisfeito
    
    cpi r20, 15			; verifica se os displays ja chegaram em 15
    breq fim_int1
    
    inc r20
    sts insatisfeito, r20
    
    ldi r20, 1
    sts botao_flag, r20
    
fim_int1:
    pop r20
    pop r16			; 
    out SREG, r16		; Restaura o contexto (SREG)
    pop r16			;
    reti

;---------------------------------------------------------------------------
; Rotina de interrupcao beseada no tempo, que inverte o dislpay a ser aceso
;---------------------------------------------------------------------------   
isr_tc0b:
    push r16			; 
    in r16, SREG		; salva o contexto (SREG)
    push r16			;
    push xl
    push xh
    
    lds r16, wr_flag
    cpi r16, 0			; verifica qual display deve ascender
    
    breq liga_satisfeito
    rjmp liga_insatisfeito
    
liga_satisfeito:
    ldi r16, 1			; alterando o valor em 'wr_flag' para na
    sts wr_flag, r16		; proxima, ascender o display dos insatisfeitos
    
    ldi xl,low(satisfeito)	; inicializa o ponteiro X
    ldi xh,high(satisfeito)	; com o endereco de 'satisfeito'
    
    rcall write_ssd1
    
    rjmp fim_tc0b

liga_insatisfeito:
    ldi r16, 0			; alterando o valor em 'wr_flag' para na
    sts wr_flag, r16		; proxima, ascender o display dos satisfeitos
    
    ldi xl,low(insatisfeito)	; inicializa o ponteiro X
    ldi xh,high(insatisfeito)	; com o endereco de 'insatisfeito'
    
    rcall write_ssd2
    
fim_tc0b:
    pop xh
    pop xl
    pop r16			; 
    out SREG, r16		; Restaura o contexto (SREG)
    pop r16			;
    reti
    
;---------------------------------------------------------------------------
; SUB-ROTINA: Configura os sinais de controle e segmentos dos displays.
;---------------------------------------------------------------------------
init_ssds:
  ldi r16, 0b00100111 ; configura PB5, PB2, PB1 e PB0 como saída, respect.,
  out DDRB, r16       ; LED placa, segmento G, controle SSD2 e SSD1
  out PORTB, r16      ; seta 1 nas saídas (liga led, desliga G e displays).

  LDI r16,0xFF	    ; 
  OUT DDRC, r16     ; configura PCx como saída
  OUT PORTC, r16    ; desliga os segmentos do display

  ret

;---------------------------------------------------------------------------
; SUB-ROTINA: Desliga os displays de 7 segmentos. 
;---------------------------------------------------------------------------
off_ssds:
  sbi PORTB, PB1   ; Desliga SSD2
  sbi PORTB, PB0   ; Desliga SSD1
  ret
    
;---------------------------------------------------------------------------
; SUB-ROTINA: Lê, decodifica e escreve a varíavel apontada por X no primeiro
;             display de 7 segmentos (habilitado pelo PB0).
;---------------------------------------------------------------------------
write_ssd1:
  push r16         ; Salva contexto dos registradores modificados

  sbi PORTB, PB1   ; Desliga SSD2
  nop
  cbi PORTB, PB0   ; Habilita SSD1

  ld r16, x        ; Lê valor da SRAM apontado por X

  rcall decodifica ; Chama sub-rotina de decodificação

  pop r16          ; Recupera o contexto dos registradores modificados
  ret
  
  ;---------------------------------------------------------------------------
; SUB-ROTINA: Lê, decodifica e escreve a varíavel apontada por X no primeiro
;             display de 7 segmentos (habilitado pelo PB0).
;---------------------------------------------------------------------------
write_ssd2:
  push r16         ; Salva contexto dos registradores modificados

  sbi PORTB, PB0   ; Desliga SSD1
  nop
  cbi PORTB, PB1   ; Habilita SSD2

  ld r16, x        ; Lê valor da SRAM apontado por X

  rcall decodifica ; Chama sub-rotina de decodificação

  pop r16          ; Recupera o contexto dos registradores modificados
  ret

;---------------------------------------------------------------------------
; SUB-ROTINA: Decodifica um valor de 0 a 15 passado como parâmetro no R20 e 
;             escreve em um display anodo comum com a seguinte ligação:
; Seguimento:  G   F  ...  A
; Pino:       PB2 PC5 ... PC0
;---------------------------------------------------------------------------
decodifica:
  push ZH            ; Guarda contexto
  push ZL        
  push r0        
  in r0,SREG   
  push r0      

  ldi  ZH,HIGH(Tabela<<1) 
  ldi  ZL,LOW(Tabela<<1)  
  add  ZL,R16             
  brcc le_tab             
  inc  ZH    

le_tab:     
  lpm  R0,Z      ; Lê tabela de decoficação

  sbi PORTB, PB2 ; Escreve G
  sbrs R0, 6
  cbi PORTB, PB2

  out PORTC,R0  ; Escreve A .. F      

  pop r0         ; Recupera contexto
  out SREG, r0
  pop r0
  pop ZL
  pop ZH    

  ret
  
;---------------------------------------------------------------------------
;   Tabela p/ decodificar o display: como cada endereço da memória flash é 
; de 16 bits, acessa-se a parte baixa e alta na decodificação
;---------------------------------------------------------------------------
Tabela: .dw 0x7940, 0x3024, 0x1219, 0x7802, 0x1800, 0x0308, 0x2146, 0x0E06
;             1 0     3 2     5 4     7 6     9 8     B A     D C     F E  
;===========================================================================
 
;---------------------------------
;SUB-ROTINA DE ATRASO Programável
;--------------------------------- 
 delay:           
  push r17       ; Salva os valores de r17,
  push r18       ; ... r18,
  in r17,SREG    ; ...
  push r17       ; ... e SREG na pilha.

  ; Executa sub-rotina :
  clr r17
  clr r18
loop:            
  dec  R17       ;decrementa R17, começa com 0x00
  brne loop      ;enquanto R17 > 0 fica decrementando R17
  dec  R18       ;decrementa R18, começa com 0x00
  brne loop      ;enquanto R18 > 0 volta decrementar R18
  dec  R19       ;decrementa R19
  brne loop      ;enquanto R19 > 0 vai para volta

  pop r17         
  out SREG, r17  ; Restaura os valores de SREG,
  pop r18        ; ... r18
  pop r17        ; ... r17 da pilha

  ret