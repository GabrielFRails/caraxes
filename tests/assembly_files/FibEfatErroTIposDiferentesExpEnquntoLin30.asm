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
    li $t1, 48
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
    j _L_startwhile_6
_L_endwhile_7:
    lw $t1, -4($fp)
    move $a0, $t1
    jal fatorial
    move $t0, $v0
    sw $t0, fat
    li $v0, 4
    syscall
    lw $t0, -4($fp)

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall
    li $v0, 4
    syscall
    lw $t0, fat

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
    jal fibonacci
    move $t0, $v0
    sw $t0, fib
    li $v0, 4
    syscall
    lw $t0, -4($fp)

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall
    li $v0, 4
    syscall
    lw $t0, fib

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    li $v0, 4
    syscall
    lw $t0, fat
    lw $t1, fib
    add $t0, $t0, $t1
    sw $t0, somaFunc
    lw $t0, somaFunc

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    li $v0, 4
    syscall
    lw $t0, fat
    lw $t1, fib
    sub $t0, $t0, $t1

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall

    # Limpeza do Stack Frame
    addu $sp, $sp, 12
    li $v0, 10
    syscall
