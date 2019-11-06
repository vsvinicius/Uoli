.globl _start
.equ INTERRUPCAO_GPT, 0xFFFF0100 #define quanto tempo esperar ate a proxima interrupcao. Caso seja 0, nao tera interrupcoes
.equ MOTOR_TOP, 0xFFFF001C
.equ MOTOR_MID, 0xFFFF001D
.equ MOTOR_BASE, 0xFFFF001E
.equ ULTRASSOM, 0xFFFF0024
.equ POSICAO_UOLI_X, 0xFFFF0008
.equ POSICAO_UOLI_Y, 0xFFFF000C
.equ POSICAO_UOLI_Z, 0xFFFF0010
.equ ANGULOS_ROTACAO_UOLI, 0xFFFF0014
.equ TORQUE_MOTOR_1, 0xFFFF001A
.equ TORQUE_MOTOR_2, 0xFFFF0018
.equ ANGULO_MOTOR_TOP, 0xFFFF001C
.equ ANGULO_MOTOR_MID, 0xFFFF001D
.equ ANGULO_MOTOR_BASE, 0xFFFF001E
.equ ESCRITA_UART, 0xFFFF0109 #escreve alguma informacao na saida padrao
.equ LEITURA_UART, 0xFFFF010B #le alguma informacao da saida padrao

.equ FLAG_POSICAO_UOLI, 0xFFFF0004 #setar pra 0 quando quiser comecar a ler a posicao do robo. vira 1 quando terminar
.equ FLAG_ULTRASSOM, 0xFFFF0020 #seta pra 0 quando quiser comecar a fazer a leitura do ultrassom
.equ FLAG_INTERRUPCAO_GPT, 0xFFFF0104 # é setado pra 1 quando ha uma interrupcao nao tratada do gpt
.equ FLAG_ESCRITA_UART, 0xFFFF0108 # seta pra 1 pra comecar o processo de escrita
.equ FLAG_LEITURA_UART, 0xFFFF010A # seta ra 1 pra comecar o processo de leitura

int_handler:
    #tratamento de interrupcoes

_start:
    #configura o gpt
    la t0, INTERRUPCAO_GPT
    li t1, 100 #interrupcoes a cada 100 ms
    sw t1, 0(t0)
    #seta torque dos motores pra zero
    la t0, TORQUE_MOTOR_1
    sw zero, 0(t0)
    la t0, TORQUE_MOTOR_2
    sw zero, 0(t0)
    #configura articulacoes da cabeca do robo 
    #nessa parte, MOTOR_* recebem 1 byte. Eu to fazendo um sw, esperando que ele trunque automaticamente
    #se der erro, pode ser isso
    la t0, MOTOR_BASE
    li t1, 31
    sw t1, 0(t0)
    la t0, MOTOR_MID
    li t1, 80
    sw t1, 0(t0)
    la t0, MOTOR_TOP
    li t1, 78
    sw t1, 0(t0)

    la t0, int_handler #carrega o endereco da rotina que trata interrupcoes
    csrw mtvec, t0 #salva endereco

    #habilita interrupcoes globais
    csrr t1, mstatus
    ori t1, t1, 0x80
    csrw mstatus, t1

    #ajusta mscratch - registrador usado na hora de salvar o contexto
    la t1, reg_buffer
    csrw mscratch, t1
    li sp, 134217724

    #muda para o modo usuario
    csrr t1, mstatus
    li t2, ~0x1800
    and t1, t1, t2
    csrw mstatus, t1
    #grava o endereco da funcao main
    la t0, main
    csrw mepc, t0
    #vai pra funcao main
    mret
reg_buffer: .skip 124