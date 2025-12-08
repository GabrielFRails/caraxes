.data
_nl: .asciiz "\n"
x: .word 0

.text
.globl main
    j main


duplicado:
    subu $sp, $sp, 32
    sw $ra, 20($sp)
    sw $fp, 16($sp)
    addu $fp, $sp, 32
    sw $a0, -4($fp)
    lw $t0, -4($fp)

    # Escreve um inteiro
    move $a0, $t0
    li $v0, 1
    syscall
    li $t0, 0
    move $v0, $t0
    lw $ra, 20($sp)
    lw $fp, 16($sp)
    addu $sp, $sp, 32
    jr $ra
    li $t0, 0
    move $v0, $t0
    lw $ra, 20($sp)
    lw $fp, 16($sp)
    addu $sp, $sp, 32
    jr $ra
    lw $ra, 20($sp)
    lw $fp, 16($sp)
    addu $sp, $sp, 32
    jr $ra
main:

    # Setup do Stack Frame para main
    subu $sp, $sp, 128
    move $fp, $sp

    li $t0, 2
    sw $t0, -4($fp)
    lw $t1, -4($fp)
    move $a0, $t1
    jal duplicado
    move $t0, $v0

    # Encerramento do programa
    li $v0, 10
    syscall
