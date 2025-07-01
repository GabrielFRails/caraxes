#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "codegen.h"

typedef struct StringLabel {
    char* content;
    int id;
    struct StringLabel* next;
} StringLabel;

static StringLabel* string_list_head = NULL;
static int next_string_id = 0;

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

static int get_new_label_id() {
    static int label_count = 0;
    return label_count++;
}

static int generate_node_code(ASTNode* node) {
    if (node == NULL) {
        return -1;
    }

    int reg1, reg2, label1, label2;
    switch (node->type) {
        case NODE_INTCONST: {
            int reg = get_temp_reg();
            fprintf(out, "    li $t%d, %d\n", reg, node->attr.int_val);
            return reg;
        }

        case NODE_CHARCONST: {
            int reg = get_temp_reg();
            // Caracteres em MIPS são tratados como seus valores ASCII
            fprintf(out, "    li $t%d, %d\n", reg, node->attr.char_val);
            return reg;
        }

        case NODE_ID: {
            SymbolEntry* entry = node->attr.id.entry;
            if (entry == NULL || entry->entry_type != ENTRY_VAR) {
                fprintf(stderr, "ERRO de Geração: ID sem entrada na tabela ou não é variável.\n");
                return -1;
            }
            int offset = entry->position * 4;
            int reg = get_temp_reg();
            fprintf(out, "    lw $t%d, %d($fp)\n", reg, offset);
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

        case NODE_WRITE: {
            ASTNode* expr = node->attr.write_ret_stmt.expression;
            reg1 = generate_node_code(expr);
			
            if (expr->type == NODE_STRINGCONST) {
                fprintf(out, "\n    # Escreve uma string\n");
                fprintf(out, "    la $a0, _str%d\n", expr->attr.string.label_id);
                fprintf(out, "    li $v0, 4\n");
                fprintf(out, "    syscall\n");
            } else if (expr->type_info == TYPE_INT) {
                fprintf(out, "\n    # Escreve um inteiro\n");
                fprintf(out, "    move $a0, $t%d\n", reg1);
                fprintf(out, "    li $v0, 1\n");
                fprintf(out, "    syscall\n");
                free_temp_reg(reg1);
            } else if (expr->type_info == TYPE_CHAR) {
                fprintf(out, "\n    # Escreve um caractere\n");
                fprintf(out, "    move $a0, $t%d\n", reg1);
                fprintf(out, "    li $v0, 11\n");
                fprintf(out, "    syscall\n");
                free_temp_reg(reg1);
            }
            break;
        }

        case NODE_STRINGCONST: {
            fprintf(out, "    li $v0, 4\n");
            fprintf(out, "    syscall\n");
            break;
        }

        case NODE_NOVALINHA: {
            fprintf(out, "\n    # Imprime uma nova linha\n");
            fprintf(out, "    la $a0, _nl\n");
            fprintf(out, "    li $v0, 4\n");
            fprintf(out, "    syscall\n");
            break;
        }

        case NODE_IF: {
            label1 = get_new_label_id(); // Label para o 'else'
            label2 = get_new_label_id(); // Label para o fim do 'if'

            reg1 = generate_node_code(node->attr.if_stmt.condition);
            fprintf(out, "    beq $t%d, $zero, _L_else_%d\n", reg1, label1);
            free_temp_reg(reg1);

            generate_node_code(node->attr.if_stmt.if_body);
            fprintf(out, "    j _L_endif_%d\n", label2);

            fprintf(out, "_L_else_%d:\n", label1);
            if (node->attr.if_stmt.else_body != NULL) {
                generate_node_code(node->attr.if_stmt.else_body);
            }

            fprintf(out, "_L_endif_%d:\n", label2);
            break;
        }

        case NODE_WHILE: {
            label1 = get_new_label_id(); // Label para o início do loop
            label2 = get_new_label_id(); // Label para o fim do loop

            fprintf(out, "_L_startwhile_%d:\n", label1);
            reg1 = generate_node_code(node->attr.while_stmt.condition);
            fprintf(out, "    beq $t%d, $zero, _L_endwhile_%d\n", reg1, label2);
            free_temp_reg(reg1);

            generate_node_code(node->attr.while_stmt.loop_body);
            fprintf(out, "    j _L_startwhile_%d\n", label1);

            fprintf(out, "_L_endwhile_%d:\n", label2);
            break;
        }

        case NODE_OP_BIN: {
            reg1 = generate_node_code(node->attr.op_bin.left);
            reg2 = generate_node_code(node->attr.op_bin.right);

            switch (node->attr.op_bin.op) {
                case OP_ADD: fprintf(out, "    add $t%d, $t%d, $t%d\n", reg1, reg1, reg2); break;
                case OP_SUB: fprintf(out, "    sub $t%d, $t%d, $t%d\n", reg1, reg1, reg2); break;
                case OP_MUL: fprintf(out, "    mul $t%d, $t%d, $t%d\n", reg1, reg1, reg2); break;
                case OP_DIV: 
                    fprintf(out, "    div $t%d, $t%d\n", reg1, reg2);
                    fprintf(out, "    mflo $t%d\n", reg1);
                    break;
                case OP_EQ:  fprintf(out, "    seq $t%d, $t%d, $t%d\n", reg1, reg1, reg2); break;
                case OP_NEQ: fprintf(out, "    sne $t%d, $t%d, $t%d\n", reg1, reg1, reg2); break;
                case OP_LT:  fprintf(out, "    slt $t%d, $t%d, $t%d\n", reg1, reg1, reg2); break;
                case OP_LE:  fprintf(out, "    sle $t%d, $t%d, $t%d\n", reg1, reg1, reg2); break;
                case OP_GT:  fprintf(out, "    sgt $t%d, $t%d, $t%d\n", reg1, reg1, reg2); break;
                case OP_GE:  fprintf(out, "    sge $t%d, $t%d, $t%d\n", reg1, reg1, reg2); break;
                default:
                    fprintf(stderr, "AVISO: Operador binário não implementado para geração de código.\n");
                    break;
            }
            free_temp_reg(reg2);
            return reg1;
        }
        
        default:
            fprintf(stderr, "AVISO: Geração de código não implementada para o nó tipo %d\n", node->type);
            break;
    }

    // recursion
    generate_node_code(node->next);
    return -1; // if the node is not a command
}

static int add_string_to_list(char* str) {
    StringLabel* current = string_list_head;
    while (current != NULL) {
        if (strcmp(current->content, str) == 0) {
            return current->id; // String já existe, retorna o ID dela
        }
        current = current->next;
    }

    StringLabel* new_label = (StringLabel*) malloc(sizeof(StringLabel));
    new_label->content = strdup(str);
    new_label->id = next_string_id++;
    new_label->next = string_list_head;
    string_list_head = new_label;
    return new_label->id;
}

static void collect_strings(ASTNode* node) {
    if (node == NULL) {
        return;
    }
    if (node->type == NODE_STRINGCONST) {
        node->attr.string.label_id = add_string_to_list(node->attr.string.value);
    }

    switch (node->type) {
        case NODE_OP_BIN:
            collect_strings(node->attr.op_bin.left);
            collect_strings(node->attr.op_bin.right);
            break;
        case NODE_ASSIGN:
            collect_strings(node->attr.assign_stmt.rvalue);
            break;
        case NODE_WRITE:
            collect_strings(node->attr.write_ret_stmt.expression);
            break;
        case NODE_IF:
            collect_strings(node->attr.if_stmt.condition);
            collect_strings(node->attr.if_stmt.if_body);
            collect_strings(node->attr.if_stmt.else_body);
            break;
        case NODE_WHILE:
            collect_strings(node->attr.while_stmt.condition);
            collect_strings(node->attr.while_stmt.loop_body);
            break;
    }
    
    collect_strings(node->next);
}

static int count_local_vars(SymbolStack* symbol_stack) {
    if (symbol_stack == NULL || symbol_stack->top < 0) return 0;
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

	collect_strings(ast_root);

    // Seção .data
    fprintf(out, ".data\n");
    fprintf(out, "_nl: .asciiz \"\\n\"\n");

	// Itera sobre a lista de strings e as declara no .data
    StringLabel* current = string_list_head;
    while (current != NULL) {
        fprintf(out, "_str%d: .asciiz \"%s\"\n", current->id, current->content);
        current = current->next;
    }

    // Seção .text
    fprintf(out, "\n.text\n");
    fprintf(out, ".globl main\n\n");
    fprintf(out, "main:\n");

    int num_vars = count_local_vars(symbol_stack);
    int stack_size = num_vars * 4;

    fprintf(out, "\n    # Setup do Stack Frame para main\n");
    fprintf(out, "    subu $sp, $sp, %d\n", stack_size);
    fprintf(out, "    move $fp, $sp\n\n");

    generate_node_code(ast_root);

    fprintf(out, "\n    # Limpeza do Stack Frame\n");
    fprintf(out, "    addu $sp, $sp, %d\n", stack_size);
    fprintf(out, "    li $v0, 10\n");
    fprintf(out, "    syscall\n");

    fclose(out);
    printf("Código MIPS gerado com sucesso em %s\n", output_filename);
}