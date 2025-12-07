.data
_nl: .asciiz "\n"
_str4: .asciiz ""DESORDENADA""
_str3: .asciiz ""ORDENADA""
_str2: .asciiz ""digite o tamanho de uma sequencia de numeros inteiros - digite 0 para terminar.""
_str1: .asciiz "" numeros inteiros separados entre si por um espaco""
_str0: .asciiz ""digite uma sequencia de ""

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
    li $v0, 4
    syscall
    lw $t0, -4($fp)

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall
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
    li $t0, 102
    sw $t0, -4($fp)
    lw $t0, -4($fp)
    sw $t0, -4($fp)
_L_endif_3:
    lw $t0, -4($fp)
    li $t1, 1
    add $t0, $t0, $t1
    sw $t0, -4($fp)
    j _L_startwhile_0
_L_endwhile_1:
    lw $t0, -4($fp)
    move $v0, $t0
    lw $ra, 20($sp)
    lw $fp, 16($sp)
    addu $sp, $sp, 32
    jr $ra
    lw $ra, 20($sp)
    lw $fp, 16($sp)
    addu $sp, $sp, 32
    jr $ra
    li $v0, 4
    syscall

    # Leitura de Inteiro
    li $v0, 5
    syscall
    sw $v0, 0($fp)
_L_startwhile_4:
    lw $t0, -4($fp)
    li $t1, 0
    sne $t0, $t0, $t1
    beq $t0, $zero, _L_endwhile_5
    lw $t1, -4($fp)
    move $a0, $t1
    jal checaOrd
    move $t0, $v0
    li $t1, 118
    seq $t0, $t0, $t1
    beq $t0, $zero, _L_else_6
    li $v0, 4
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    j _L_endif_7
_L_else_6:
    li $v0, 4
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
_L_endif_7:

    # Leitura de Inteiro
    li $v0, 5
    syscall
    sw $v0, 0($fp)
    j _L_startwhile_4
_L_endwhile_5:

    # Limpeza do Stack Frame
    addu $sp, $sp, 0
    li $v0, 10
    syscall
