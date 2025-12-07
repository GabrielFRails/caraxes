.data
_nl: .asciiz "\n"

.text
.globl main

main:

    # Setup do Stack Frame para main
    subu $sp, $sp, 16
    move $fp, $sp


    # Limpeza do Stack Frame
    addu $sp, $sp, 16
    li $v0, 10
    syscall
