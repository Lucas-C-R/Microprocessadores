.INCLUDE <m328Pdef.inc>
    
.equ LED = PD0
.equ LED2 = PD1
.equ LED3 = PD2 
.equ LED4 = PD3
.equ LED5 = PD4
.equ LED6 = PD5
.equ LED7 = PD6
.equ LED8 = PD7
    
.equ BOTAO = PB0 
.equ BOTAO2 = PB1
    
.def AUX = R16 

setup:
    LDI AUX,0b11111111
    
    OUT DDRD, AUX 
    OUT DDRB, AUX
    
    OUT PORTD, AUX
    OUT PORTB, AUX

naoPress: 
    ; Desliga os LED's
    sbi PORTD,LED 
    sbi PORTD,LED2
    sbi PORTD,LED3
    sbi PORTD,LED4
    sbi PORTD,LED5
    sbi PORTD,LED6
    sbi PORTD,LED7
    sbi PORTD,LED8
    
    ; Verifica se ambos os LED's estao pressionados
    sbic PINB,BOTAO 
    rjmp naoPress
    sbic PINB,BOTAO2	
    rjmp naoPress 

press: 
    ; Liga os LED's
    cbi PORTD,LED 
    cbi PORTD,LED2
    cbi PORTD,LED3
    cbi PORTD,LED4
    cbi PORTD,LED5
    cbi PORTD,LED6
    cbi PORTD,LED7
    cbi PORTD,LED8
    
    ; Verifica se os botoes permanecem pressionados
    sbic PINB,BOTAO
    rjmp naoPress
    sbis PINB,BOTAO2
    rjmp press 

    rjmp naoPress 