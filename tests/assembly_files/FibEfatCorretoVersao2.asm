.data
_nl: .asciiz "\n"
_str5: .asciiz ""A subtracao do valor do fatorial pelo valor de finbonacci e: ""
_str4: .asciiz ""A soma do valor do fatorial com o valor de fibonacci e: ""
_str3: .asciiz ""Fibonacci de ""
_str2: .asciiz "" e: ""
_str1: .asciiz ""O fatorial de ""
_str0: .asciiz ""digite um numero""

.text
.globl main

main:

    # Setup do Stack Frame para main
    subu $sp, $sp, 12
    move $fp, $sp


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

fibonacci:
    subu $sp, $sp, 32
    sw $ra, 20($sp)
    sw $fp, 16($sp)
    addu $fp, $sp, 32
    sw $a0, -4($fp)
    lw $t0, -4($fp)
    li $t1, 0
    seq $t0, $t0, $t1
    beq $t0, $zero, _L_else_2
    li $t0, 0
    move $v0, $t0
    lw $ra, 20($sp)
    lw $fp, 16($sp)
    addu $sp, $sp, 32
    jr $ra
    j _L_endif_3
_L_else_2:
    lw $t0, -4($fp)
    li $t1, 1
    seq $t0, $t0, $t1
    beq $t0, $zero, _L_else_4
    li $t0, 1
    move $v0, $t0
    lw $ra, 20($sp)
    lw $fp, 16($sp)
    addu $sp, $sp, 32
    jr $ra
    j _L_endif_5
_L_else_4:
    lw $t1, -4($fp)
    li $t2, 1
    sub $t1, $t1, $t2
    move $a0, $t1
    jal fibonacci
    move $t0, $v0
    lw $t2, -4($fp)
    li $t3, 2
    sub $t2, $t2, $t3
    move $a0, $t2
    jal fibonacci
    move $t1, $v0
    add $t0, $t0, $t1
    sw $t0, -4($fp)
    lw $t0, -4($fp)
    move $v0, $t0
    lw $ra, 20($sp)
    lw $fp, 16($sp)
    addu $sp, $sp, 32
    jr $ra
_L_endif_5:
_L_endif_3:
    lw $ra, 20($sp)
    lw $fp, 16($sp)
    addu $sp, $sp, 32
    jr $ra
    li $t0, 1
    li $t1, 0
    sub $t0, $t0, $t1
    sw $t0, -4($fp)
_L_startwhile_6:
    lw $t0, -4($fp)
    li $t1, 0
    slt $t0, $t0, $t1
    beq $t0, $zero, _L_endwhile_7
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

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Leitura de Inteiro
    li $v0, 5
    syscall
    sw $v0, 0($fp)

    # Leitura de Inteiro
    li $v0, 5
    syscall
    sw $v0, 0($fp)
    j _L_startwhile_6
_L_endwhile_7:
    lw $t1, -4($fp)
    move $a0, $t1
    jal fatorial
    move $t0, $v0
    sw $t0, fat
    lw $t2, -4($fp)
    move $a0, $t2
    jal fatorial
    move $t1, $v0
    sw $t1, fat
    li $v0, 4
    syscall
    lw $t1, -4($fp)

    # Escreve um inteiro
    move $a0, $t1
    li $v0, 1
    syscall
    li $v0, 4
    syscall
    lw $t1, fat

    # Escreve um inteiro
    move $a0, $t1
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    lw $t2, -4($fp)
    move $a0, $t2
    jal fibonacci
    move $t1, $v0
    sw $t1, fib
    lw $t2, -4($fp)

    # Escreve um inteiro
    move $a0, $t2
    li $v0, 1
    syscall
    li $v0, 4
    syscall
    lw $t2, fat

    # Escreve um inteiro
    move $a0, $t2
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    lw $t3, -4($fp)
    move $a0, $t3
    jal fibonacci
    move $t2, $v0
    sw $t2, fib
    li $v0, 4
    syscall
    lw $t3, fat

    # Escreve um inteiro
    move $a0, $t3
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    lw $t4, -4($fp)
    move $a0, $t4
    jal fibonacci
    move $t3, $v0
    sw $t3, fib
    lw $t4, fat

    # Escreve um inteiro
    move $a0, $t4
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    lw $t5, -4($fp)
    move $a0, $t5
    jal fibonacci
    move $t4, $v0
    sw $t4, fib

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    lw $t6, -4($fp)
    move $a0, $t6
    jal fibonacci
    move $t5, $v0
    sw $t5, fib
    lw $t7, -4($fp)
    move $a0, $t7
    jal fibonacci
    move $t6, $v0
    sw $t6, fib
    li $v0, 4
    syscall
    lw $t6, -4($fp)

    # Escreve um inteiro
    move $a0, $t6
    li $v0, 1
    syscall
    li $v0, 4
    syscall
    lw $t6, fib

    # Escreve um inteiro
    move $a0, $t6
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    li $v0, 4
    syscall
    lw $t6, fat
    lw $t7, fib
    add $t6, $t6, $t7
    sw $t6, somaFunc
    lw $t7, -4($fp)

    # Escreve um inteiro
    move $a0, $t7
    li $v0, 1
    syscall
    li $v0, 4
    syscall
    lw $t7, fib

    # Escreve um inteiro
    move $a0, $t7
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    li $v0, 4
    syscall
    lw $t7, fat
    lw $t8, fib
    add $t7, $t7, $t8
    sw $t7, somaFunc
    li $v0, 4
    syscall
    lw $t8, fib

    # Escreve um inteiro
    move $a0, $t8
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    li $v0, 4
    syscall
    lw $t8, fat
    lw $t9, fib
    add $t8, $t8, $t9
    sw $t8, somaFunc
    lw $t9, fib

    # Escreve um inteiro
    move $a0, $t9
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    li $v0, 4
    syscall
    lw $t9, fat
