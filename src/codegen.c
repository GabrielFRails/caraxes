#include <stdio.h>
#include <stdlib.h>
#include "codegen.h"

#define NUM_TEMP_REGS 10
static int temp_regs[NUM_TEMP_REGS] = {0}; // 0 = livre, 1 = em uso
static FILE* out;

static int get_temp_reg() {
    for (int i = 0; i < NUM_TEMP_REGS; i++) {
        if (temp_regs[i] == 0) {
            temp_regs[i] = 1; // Marca como em uso
            return i;
        }
    }
    fprintf(stderr, "ERRO: Nenhum registrador temporário livre!\n");
    exit(1);
}

static void free_temp_reg(int reg_num) {
    if (reg_num >= 0 && reg_num < NUM_TEMP_REGS) {
        temp_regs[reg_num] = 0;
    }
}

static int generate_node_code(ASTNode* node) {
    if (node == NULL) {
        return -1;
    }

    int reg1, reg2;
    switch (node->type) {
        case NODE_INTCONST: {
            int reg = get_temp_reg();
            fprintf(out, "    li $t%d, %d\n", reg, node->attr.int_val);
            return reg;
        }

        case NODE_WRITE: {
            reg1 = generate_node_code(node->attr.write_ret_stmt.expression);
            fprintf(out, "\n    # Escreve um inteiro\n");
            fprintf(out, "    move $a0, $t%d\n", reg1);
            fprintf(out, "    li $v0, 1\n");
            fprintf(out, "    syscall\n");

            free_temp_reg(reg1);
            break;
        }

		case NODE_OP_BIN: {
            // generate mips code for both children
            reg1 = generate_node_code(node->attr.op_bin.left);
            reg2 = generate_node_code(node->attr.op_bin.right);

            switch (node->attr.op_bin.op) {
                case OP_ADD:
                    fprintf(out, "    add $t%d, $t%d, $t%d\n", reg1, reg1, reg2);
                    break;
                case OP_SUB:
                    fprintf(out, "    sub $t%d, $t%d, $t%d\n", reg1, reg1, reg2);
                    break;
                case OP_MUL:
                    fprintf(out, "    mul $t%d, $t%d, $t%d\n", reg1, reg1, reg2);
                    break;
                case OP_DIV:
                    fprintf(out, "    div $t%d, $t%d\n", reg1, reg2);
                    fprintf(out, "    mflo $t%d\n", reg1);
                    break;
                default:
                    fprintf(stderr, "AVISO: Operador binário não implementado para geração de código.\n");
                    break;
            }

            free_temp_reg(reg2);
            return reg1;
        }

		case NODE_ID: {
            // Lógica para carregar o valor de uma variável da pilha
            SymbolEntry* entry = node->attr.id.entry;
            if (entry == NULL || entry->entry_type != ENTRY_VAR) {
                fprintf(stderr, "ERRO de Geração: ID sem entrada na tabela ou não é variável.\n");
                return -1;
            }
            
            // Calcula o offset na pilha. Assumindo que a posição 1 está no topo.
            int offset = entry->position * 4; 
            int reg = get_temp_reg();
            fprintf(out, "    lw $t%d, %d($fp)\n", reg, offset); // lw reg, offset(base)
            return reg;
        }

        case NODE_ASSIGN: {
            SymbolEntry* entry = node->attr.assign_stmt.lvalue->attr.id.entry;
            if (entry == NULL || entry->entry_type != ENTRY_VAR) {
                fprintf(stderr, "ERRO de Geração: L-value da atribuição inválido.\n");
                break;
            }

            reg1 = generate_node_code(node->attr.assign_stmt.rvalue);
            int offset = entry->position * 4;

            fprintf(out, "    sw $t%d, %d($fp)\n", reg1, offset);
            free_temp_reg(reg1);
            break;
        }
        
        default:
            fprintf(stderr, "AVISO: Geração de código não implementada para o nó tipo %d\n", node->type);
            break;
    }

    // recursion
    generate_node_code(node->next);

    return -1; // if the node is not a command
}

static int count_local_vars(SymbolStack* symbol_stack) {
    if (symbol_stack == NULL || symbol_stack->top < 0) {
        return 0;
    }
    int count = 0;
    SymbolEntry* entry = symbol_stack->tables[symbol_stack->top]->entries;
    while (entry != NULL) {
        if (entry->entry_type == ENTRY_VAR) {
            count++;
        }
        entry = entry->next;
    }
    return count;
}

void generate_code(ASTNode* ast_root, SymbolStack* symbol_stack, const char* output_filename) {
    out = fopen(output_filename, "w");
    if (out == NULL) { /* ... erro ... */ return; }

	// begin mips
    fprintf(out, ".text\n");
    fprintf(out, ".globl main\n\n");
    fprintf(out, "main:\n");

    int num_vars = count_local_vars(symbol_stack);
    int stack_size = num_vars * 4; // 4 bytes por inteiro/char

    fprintf(out, "\n    # Setup do Stack Frame para main\n");
    fprintf(out, "    subu $sp, $sp, %d\n", stack_size);
    fprintf(out, "    move $fp, $sp\n\n");

	// recursion
    generate_node_code(ast_root);

	// end mips
    fprintf(out, "\n    # Limpeza do Stack Frame\n");
    fprintf(out, "    addu $sp, $sp, %d\n", stack_size);
    fprintf(out, "li $v0, 10\n");
    fprintf(out, "syscall\n");

    fclose(out);
    printf("Código MIPS gerado com sucesso em %s\n", output_filename);
}