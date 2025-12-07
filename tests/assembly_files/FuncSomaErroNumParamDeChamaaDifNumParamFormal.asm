.data
_nl: .asciiz "\n"

.text
.globl main

main:

    # Setup do Stack Frame para main
    subu $sp, $sp, 0
    move $fp, $sp


soma:
    subu $sp, $sp, 32
    sw $ra, 20($sp)
    sw $fp, 16($sp)
    addu $fp, $sp, 32
    sw $a0, -4($fp)
    sw $a1, -8($fp)
    lw $t0, -4($fp)
    lw $t1, -4($fp)
    add $t0, $t0, $t1
    move $v0, $t0
    lw $ra, 20($sp)
    lw $fp, 16($sp)
    addu $sp, $sp, 32
    jr $ra
    lw $ra, 20($sp)
    lw $fp, 16($sp)
    addu $sp, $sp, 32
    jr $ra
    li $t0, 4
    sw $t0, -4($fp)
    lw $t1, -4($fp)
    move $a0, $t1
    jal soma
    move $t0, $v0
    sw $t0, -4($fp)
    lw $t0, -4($fp)

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall

    # Imprime uma nova linha
    la $a0, _nl
    li $v0, 4
    syscall

    # Limpeza do Stack Frame
    addu $sp, $sp, 0
    li $v0, 10
    syscall
