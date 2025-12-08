.data
_nl: .asciiz "\n"
_str2: .asciiz " e: "
_str1: .asciiz "O fatorial de "
_str0: .asciiz "digite um numero"

.text
.globl main
    j main


fatorial:
    subu $sp, $sp, 32
    sw $ra, 20($sp)
    sw $fp, 16($sp)
    addu $fp, $sp, 32
    sw $a0, -4($fp)
    lw $t0, -4($fp)
    li $t1, 0
    seq $t0, $t0, $t1
    beq $t0, $zero, _L_else_0
    li $t0, 1
    move $v0, $t0
    lw $ra, 20($sp)
    lw $fp, 16($sp)
    addu $sp, $sp, 32
    jr $ra
    j _L_endif_1
_L_else_0:
    lw $t0, -4($fp)
    lw $t2, -4($fp)
    li $t3, 1
    sub $t2, $t2, $t3
    move $a0, $t2
    jal fatorial
    move $t1, $v0
    mul $t0, $t0, $t1
    move $v0, $t0
    lw $ra, 20($sp)
    lw $fp, 16($sp)
    addu $sp, $sp, 32
    jr $ra
_L_endif_1:
    lw $ra, 20($sp)
    lw $fp, 16($sp)
    addu $sp, $sp, 32
    jr $ra
main:

    # Setup do Stack Frame para main
    subu $sp, $sp, 128
    move $fp, $sp

    li $t0, 1
    sw $t0, -4($fp)
_L_startwhile_2:
    lw $t0, -4($fp)
    li $t1, 0
    sgt $t0, $t0, $t1
    beq $t0, $zero, _L_endwhile_3
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

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Leitura de Inteiro
    li $v0, 5
    syscall
    sw $v0, -4($fp)

    # Leitura de Inteiro
    li $v0, 5
    syscall
    sw $v0, -4($fp)
    j _L_startwhile_2
_L_endwhile_3:
    la $a0, _str1
    li $v0, 4
    syscall
    lw $t0, -4($fp)

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall
    la $a0, _str2
    li $v0, 4
    syscall
    lw $t1, -4($fp)
    move $a0, $t1
    jal fatorial
    move $t0, $v0

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    la $a0, _str1
    li $v0, 4
    syscall
    lw $t0, -4($fp)

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall
    la $a0, _str2
    li $v0, 4
    syscall
    lw $t1, -4($fp)
    move $a0, $t1
    jal fatorial
    move $t0, $v0

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    lw $t0, -4($fp)

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall
    la $a0, _str2
    li $v0, 4
    syscall
    lw $t1, -4($fp)
    move $a0, $t1
    jal fatorial
    move $t0, $v0

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    la $a0, _str2
    li $v0, 4
    syscall
    lw $t1, -4($fp)
    move $a0, $t1
    jal fatorial
    move $t0, $v0

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    lw $t1, -4($fp)
    move $a0, $t1
    jal fatorial
    move $t0, $v0

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Encerramento do programa
    li $v0, 10
    syscall
