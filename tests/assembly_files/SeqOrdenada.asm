.data
_nl: .asciiz "\n"
_str4: .asciiz "DESORDENADA"
_str3: .asciiz "ORDENADA"
_str2: .asciiz "digite o tamanho de uma sequencia de numeros inteiros - digite 0 para terminar."
_str1: .asciiz " numeros inteiros separados entre si por um espaco"
_str0: .asciiz "digite uma sequencia de "

.text
.globl main

main:

    # Setup do Stack Frame para main
    subu $sp, $sp, 0
    move $fp, $sp


checaOrd:
    subu $sp, $sp, 32
    sw $ra, 20($sp)
    sw $fp, 16($sp)
    addu $fp, $sp, 32
    sw $a0, -4($fp)
    li $t0, 118
    sw $t0, -4($fp)
    li $t0, 1
    sw $t0, -4($fp)

    # Leitura de Inteiro
    li $v0, 5
    syscall
    sw $v0, 0($fp)
    la $a0, _str0
    li $v0, 4
    syscall
    lw $t0, -4($fp)

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall
    la $a0, _str1
    li $v0, 4
    syscall
_L_startwhile_0:
    lw $t0, -4($fp)
    lw $t1, -4($fp)
    slt $t0, $t0, $t1
    beq $t0, $zero, _L_endwhile_1

    # Leitura de Inteiro
    li $v0, 5
    syscall
    sw $v0, 0($fp)
    lw $t0, -4($fp)
    lw $t1, -4($fp)
    slt $t0, $t0, $t1
    beq $t0, $zero, _L_else_2
    lw $t0, -4($fp)
    sw $t0, -4($fp)
    j _L_endif_3
_L_else_2:
    li $t1, 102
    sw $t1, -4($fp)
    lw $t1, -4($fp)
    sw $t1, -4($fp)
_L_endif_3:
    lw $t1, -4($fp)
    li $t2, 1
    add $t1, $t1, $t2
    sw $t1, -4($fp)
    lw $t2, -4($fp)
    lw $t3, -4($fp)
    slt $t2, $t2, $t3
    beq $t2, $zero, _L_else_4
    lw $t2, -4($fp)
    sw $t2, -4($fp)
    j _L_endif_5
_L_else_4:
    li $t3, 102
    sw $t3, -4($fp)
    lw $t3, -4($fp)
    sw $t3, -4($fp)
_L_endif_5:
    lw $t3, -4($fp)
    li $t4, 1
    add $t3, $t3, $t4
    sw $t3, -4($fp)
    lw $t4, -4($fp)
    li $t5, 1
    add $t4, $t4, $t5
    sw $t4, -4($fp)
    j _L_startwhile_0
_L_endwhile_1:
    lw $t4, -4($fp)
    move $v0, $t4
    lw $ra, 20($sp)
    lw $fp, 16($sp)
    addu $sp, $sp, 32
    jr $ra
    la $a0, _str0
    li $v0, 4
    syscall
    lw $t4, -4($fp)

    # Escreve um inteiro
    move $a0, $t4
    li $v0, 1
    syscall
    la $a0, _str1
    li $v0, 4
    syscall
_L_startwhile_6:
    lw $t4, -4($fp)
    lw $t5, -4($fp)
    slt $t4, $t4, $t5
    beq $t4, $zero, _L_endwhile_7

    # Leitura de Inteiro
    li $v0, 5
    syscall
    sw $v0, 0($fp)
    lw $t4, -4($fp)
    lw $t5, -4($fp)
    slt $t4, $t4, $t5
    beq $t4, $zero, _L_else_8
    lw $t4, -4($fp)
    sw $t4, -4($fp)
    j _L_endif_9
_L_else_8:
    li $t5, 102
    sw $t5, -4($fp)
    lw $t5, -4($fp)
    sw $t5, -4($fp)
_L_endif_9:
    lw $t5, -4($fp)
    li $t6, 1
    add $t5, $t5, $t6
    sw $t5, -4($fp)
    lw $t6, -4($fp)
    lw $t7, -4($fp)
    slt $t6, $t6, $t7
    beq $t6, $zero, _L_else_10
    lw $t6, -4($fp)
    sw $t6, -4($fp)
    j _L_endif_11
_L_else_10:
    li $t7, 102
    sw $t7, -4($fp)
    lw $t7, -4($fp)
    sw $t7, -4($fp)
_L_endif_11:
    lw $t7, -4($fp)
    li $t8, 1
    add $t7, $t7, $t8
    sw $t7, -4($fp)
    lw $t8, -4($fp)
    li $t9, 1
    add $t8, $t8, $t9
    sw $t8, -4($fp)
    j _L_startwhile_6
_L_endwhile_7:
    lw $t8, -4($fp)
    move $v0, $t8
    lw $ra, 20($sp)
    lw $fp, 16($sp)
    addu $sp, $sp, 32
    jr $ra
    lw $t8, -4($fp)

    # Escreve um inteiro
    move $a0, $t8
    li $v0, 1
    syscall
    la $a0, _str1
    li $v0, 4
    syscall
_L_startwhile_12:
    lw $t8, -4($fp)
    lw $t9, -4($fp)
    slt $t8, $t8, $t9
    beq $t8, $zero, _L_endwhile_13

    # Leitura de Inteiro
    li $v0, 5
    syscall
    sw $v0, 0($fp)
    lw $t8, -4($fp)
    lw $t9, -4($fp)
    slt $t8, $t8, $t9
    beq $t8, $zero, _L_else_14
    lw $t8, -4($fp)
    sw $t8, -4($fp)
    j _L_endif_15
_L_else_14:
    li $t9, 102
    sw $t9, -4($fp)
    lw $t9, -4($fp)
    sw $t9, -4($fp)
_L_endif_15:
    lw $t9, -4($fp)
