.data
_nl: .asciiz "\n"

.text
.globl main

main:

    # Setup do Stack Frame para main
    subu $sp, $sp, 12
    move $fp, $sp


    # Limpeza do Stack Frame
    addu $sp, $sp, 12
    li $v0, 10
    syscall
