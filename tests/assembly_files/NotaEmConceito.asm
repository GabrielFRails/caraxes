.data
_nl: .asciiz "\n"
_str1: .asciiz ""Conceito: ""
_str0: .asciiz ""Digite um valor inteiro para a nota de um aluno""

.text
.globl main

main:

    # Setup do Stack Frame para main
    subu $sp, $sp, 0
    move $fp, $sp

    li $v0, 4
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Leitura de Inteiro
    li $v0, 5
    syscall
    sw $v0, 0($fp)
    lw $t0, -4($fp)
    li $t1, 6
    slt $t0, $t0, $t1
    beq $t0, $zero, _L_else_0
    li $t0, 68
    sw $t0, -4($fp)
    li $v0, 4
    syscall
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    j _L_endif_1
_L_else_0:
    lw $t0, -4($fp)
    li $t1, 7
    slt $t0, $t0, $t1
    beq $t0, $zero, _L_else_2
    li $t0, 67
    sw $t0, -4($fp)
    li $v0, 4
    syscall
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    j _L_endif_3
_L_else_2:
    lw $t0, -4($fp)
    li $t1, 9
    slt $t0, $t0, $t1
    beq $t0, $zero, _L_else_4
    li $t0, 66
    sw $t0, -4($fp)
    li $v0, 4
    syscall
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    j _L_endif_5
_L_else_4:
    li $t0, 65
    sw $t0, -4($fp)
    li $v0, 4
    syscall
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
_L_endif_5:
_L_endif_3:
_L_endif_1:

    # Limpeza do Stack Frame
    addu $sp, $sp, 0
    li $v0, 10
    syscall
