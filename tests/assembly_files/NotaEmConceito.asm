.data
_nl: .asciiz "\n"
_str1: .asciiz "Conceito: "
_str0: .asciiz "Digite um valor inteiro para a nota de um aluno"

.text
.globl main
    j main

main:

    # Setup do Stack Frame para main
    subu $sp, $sp, 128
    move $fp, $sp

    la $a0, _str0
    li $v0, 4
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Leitura de Inteiro
    li $v0, 5
    syscall
    sw $v0, -4($fp)
    lw $t0, -4($fp)
    li $t1, 6
    slt $t0, $t0, $t1
    beq $t0, $zero, _L_else_0
    li $t0, 68
    sw $t0, -4($fp)
    la $a0, _str1
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
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
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
    la $a0, _str1
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
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
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
    la $a0, _str1
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
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    j _L_endif_5
_L_else_4:
    li $t0, 65
    sw $t0, -4($fp)
    la $a0, _str1
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
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
_L_endif_5:
_L_endif_3:
_L_endif_1:

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Leitura de Inteiro
    li $v0, 5
    syscall
    sw $v0, -4($fp)
    lw $t0, -4($fp)
    li $t1, 6
    slt $t0, $t0, $t1
    beq $t0, $zero, _L_else_6
    li $t0, 68
    sw $t0, -4($fp)
    la $a0, _str1
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
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    j _L_endif_7
_L_else_6:
    lw $t0, -4($fp)
    li $t1, 7
    slt $t0, $t0, $t1
    beq $t0, $zero, _L_else_8
    li $t0, 67
    sw $t0, -4($fp)
    la $a0, _str1
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
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    j _L_endif_9
_L_else_8:
    lw $t0, -4($fp)
    li $t1, 9
    slt $t0, $t0, $t1
    beq $t0, $zero, _L_else_10
    li $t0, 66
    sw $t0, -4($fp)
    la $a0, _str1
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
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    j _L_endif_11
_L_else_10:
    li $t0, 65
    sw $t0, -4($fp)
    la $a0, _str1
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
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
_L_endif_11:
_L_endif_9:
_L_endif_7:

    # Leitura de Inteiro
    li $v0, 5
    syscall
    sw $v0, -4($fp)
    lw $t0, -4($fp)
    li $t1, 6
    slt $t0, $t0, $t1
    beq $t0, $zero, _L_else_12
    li $t0, 68
    sw $t0, -4($fp)
    la $a0, _str1
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
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    j _L_endif_13
_L_else_12:
    lw $t0, -4($fp)
    li $t1, 7
    slt $t0, $t0, $t1
    beq $t0, $zero, _L_else_14
    li $t0, 67
    sw $t0, -4($fp)
    la $a0, _str1
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
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    j _L_endif_15
_L_else_14:
    lw $t0, -4($fp)
    li $t1, 9
    slt $t0, $t0, $t1
    beq $t0, $zero, _L_else_16
    li $t0, 66
    sw $t0, -4($fp)
    la $a0, _str1
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
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    j _L_endif_17
_L_else_16:
    li $t0, 65
    sw $t0, -4($fp)
    la $a0, _str1
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
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
_L_endif_17:
_L_endif_15:
_L_endif_13:
    lw $t0, -4($fp)
    li $t1, 6
    slt $t0, $t0, $t1
    beq $t0, $zero, _L_else_18
    li $t0, 68
    sw $t0, -4($fp)
    la $a0, _str1
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
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    j _L_endif_19
_L_else_18:
    lw $t0, -4($fp)
    li $t1, 7
    slt $t0, $t0, $t1
    beq $t0, $zero, _L_else_20
    li $t0, 67
    sw $t0, -4($fp)
    la $a0, _str1
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
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    j _L_endif_21
_L_else_20:
    lw $t0, -4($fp)
    li $t1, 9
    slt $t0, $t0, $t1
    beq $t0, $zero, _L_else_22
    li $t0, 66
    sw $t0, -4($fp)
    la $a0, _str1
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
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    j _L_endif_23
_L_else_22:
    li $t0, 65
    sw $t0, -4($fp)
    la $a0, _str1
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
    lw $t0, -4($fp)

    # Escreve um caractere
    move $a0, $t0
    li $v0, 11
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
_L_endif_23:
_L_endif_21:
_L_endif_19:

    # Encerramento do programa
    li $v0, 10
    syscall
