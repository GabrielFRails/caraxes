.data
_nl: .asciiz "\n"
_str0: .asciiz "" ""

.text
.globl main

main:

    # Setup do Stack Frame para main
    subu $sp, $sp, 4
    move $fp, $sp

    li $t0, 50
    sw $t0, -4($fp)
    sw $t0, -4($fp)
    sw $t0, -4($fp)
    lw $t0, -4($fp)

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall
    li $v0, 4
    syscall
    lw $t0, -4($fp)

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall
    li $v0, 4
    syscall
    lw $t0, -4($fp)

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    lw $t0, -4($fp)
    li $t1, 2
    mul $t0, $t0, $t1
    lw $t1, -4($fp)
    li $t2, 4
    div $t1, $t2
    mflo $t1
    sub $t0, $t0, $t1

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall
    li $v0, 4
    syscall
    lw $t0, -4($fp)

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall
    li $v0, 4
    syscall
    lw $t0, -4($fp)

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    lw $t0, -4($fp)
    li $t1, 2
    mul $t0, $t0, $t1
    lw $t1, -4($fp)
    li $t2, 4
    div $t1, $t2
    mflo $t1
    sub $t0, $t0, $t1

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall
    lw $t0, -4($fp)

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall
    li $v0, 4
    syscall
    lw $t0, -4($fp)

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    lw $t0, -4($fp)
    li $t1, 2
    mul $t0, $t0, $t1
    lw $t1, -4($fp)
    li $t2, 4
    div $t1, $t2
    mflo $t1
    sub $t0, $t0, $t1

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall
    li $v0, 4
    syscall
    lw $t0, -4($fp)

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    lw $t0, -4($fp)
    li $t1, 2
    mul $t0, $t0, $t1
    lw $t1, -4($fp)
    li $t2, 4
    div $t1, $t2
    mflo $t1
    sub $t0, $t0, $t1

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall
    lw $t0, -4($fp)

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    lw $t0, -4($fp)
    li $t1, 2
    mul $t0, $t0, $t1
    lw $t1, -4($fp)
    li $t2, 4
    div $t1, $t2
    mflo $t1
    sub $t0, $t0, $t1

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall
    lw $t0, -4($fp)
    li $t1, 2
    mul $t0, $t0, $t1
    lw $t1, -4($fp)
    li $t2, 4
    div $t1, $t2
    mflo $t1
    sub $t0, $t0, $t1

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall
    lw $t0, -4($fp)
    li $t1, 2
    mul $t0, $t0, $t1
    lw $t1, -4($fp)
    li $t2, 4
    div $t1, $t2
    mflo $t1
    sub $t0, $t0, $t1

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall

    # Limpeza do Stack Frame
    addu $sp, $sp, 4
    li $v0, 10
    syscall
