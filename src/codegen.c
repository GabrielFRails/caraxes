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
        case NODE_BLOCK: {
            ASTNode* stmt = node->attr.block.stats;
            while (stmt != NULL) {
                int res = generate_node_code(stmt);
                
                // Se o comando retornou um registrador (ex: uma atribuição x=1 solta no código),
                // precisamos liberá-lo, senão o registrador fica "preso" para sempre.
                if (res != -1) {
                    free_temp_reg(res);
                }
                
                stmt = stmt->next;
            }
            break; 
        }
        
        case NODE_FUNC_DEF: {
            fprintf(out, "\n%s:\n", node->attr.func_def.name);
            // Prólogo...
             fprintf(out, "    subu $sp, $sp, 32\n");
             fprintf(out, "    sw $ra, 20($sp)\n");
             fprintf(out, "    sw $fp, 16($sp)\n");
             fprintf(out, "    addu $fp, $sp, 32\n");
             
             // TRUQUE PARA PARÂMETROS NO MIPS (Convenção simples)
             // Assumindo que quem chamou colocou args em $a0, $a1...
             // Vamos salvar $a0 na pilha como se fosse variável local declarada.
             ASTNode* param = node->attr.func_def.params;
             int arg_idx = 0;
             while(param != NULL && arg_idx < 4) {
                 // Salva $a0...$a3 no stack frame local para ser usado como variável
                 // Assumindo offsets locais 4, 8, 12...
                 int offset = (arg_idx + 1) * 4; 
                 fprintf(out, "    sw $a%d, -%d($fp)\n", arg_idx, offset);
                 
                 // IMPORTANTE: Precisamos "enganar" a tabela de símbolos para dizer
                 // que esse parametro está nessa posição?
                 // O symbol_table_insert_variable no semantic.c define a posição?
                 // Se não, você precisa garantir que a posição do parametro bata com esse offset.
                 
                 param = param->next;
                 arg_idx++;
             }

            generate_node_code(node->attr.func_def.body);
            
            // Epílogo de segurança...
            fprintf(out, "    lw $ra, 20($sp)\n");
            fprintf(out, "    lw $fp, 16($sp)\n");
            fprintf(out, "    addu $sp, $sp, 32\n");
            fprintf(out, "    jr $ra\n");
            break;
        }
            
        case NODE_VAR_DECL:
            // Declaração não gera instrução MIPS, apenas metadados
            break;

        // --- IMPLEMENTAÇÃO DO LEIA ---
        case NODE_READ: {
            ASTNode* id_node = node->attr.read_stmt.id;
            SymbolEntry* entry = id_node->attr.id.entry;
            
            if (entry == NULL) {
                fprintf(stderr, "ERRO Codegen: Tentar ler para variável não declarada/encontrada.\n");
                break;
            }

            if (entry->data_type == TYPE_INT) {
                fprintf(out, "\n    # Leitura de Inteiro\n");
                fprintf(out, "    li $v0, 5\n");       // Syscall read_int
                fprintf(out, "    syscall\n");
                // Salva o lido na variável
                int offset = entry->position * 4; 
                // ATENÇÃO: Se for var global ou local o cálculo de offset pode mudar
                // Assumindo local ($fp) por enquanto como no seu padrão:
                fprintf(out, "    sw $v0, %d($fp)\n", offset);
            } else {
                fprintf(out, "\n    # Leitura de Char\n");
                fprintf(out, "    li $v0, 12\n");      // Syscall read_char
                fprintf(out, "    syscall\n");
                int offset = entry->position * 4;
                fprintf(out, "    sw $v0, %d($fp)\n", offset);
            }
            break;
        }

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

        case NODE_RETURN: {
            if (node->attr.write_ret_stmt.expression != NULL) {
                int reg = generate_node_code(node->attr.write_ret_stmt.expression);
                fprintf(out, "    move $v0, $t%d\n", reg);
                free_temp_reg(reg);
            }
            // Epílogo Padrão (recupera contexto e retorna)
            fprintf(out, "    lw $ra, 20($sp)\n");
            fprintf(out, "    lw $fp, 16($sp)\n");
            fprintf(out, "    addu $sp, $sp, 32\n");
            fprintf(out, "    jr $ra\n");
            break;
        }

        case NODE_ID: {
            SymbolEntry* entry = node->attr.id.entry;
            
            // 1. Erro: O identificador não foi vinculado na análise semântica
            if (entry == NULL) {
                fprintf(stderr, "ERRO de Geração: O identificador '%s' (linha %d) não possui entrada na tabela de símbolos (Erro Semântico anterior?).\n", 
                        node->attr.id.name, node->line);
                return -1;
            }

            // 2. Erro: O identificador existe, mas não é uma variável ou parâmetro
            if (entry->entry_type != ENTRY_VAR && entry->entry_type != ENTRY_PARAM) {
                char* type_str = (entry->entry_type == ENTRY_FUNC) ? "FUNÇÃO" : "DESCONHECIDO";
                fprintf(stderr, "ERRO de Geração: O identificador '%s' (linha %d) é do tipo %s, mas esperava-se uma VARIÁVEL ou PARÂMETRO.\n", 
                        node->attr.id.name, node->line, type_str);
                return -1;
            }
            int offset = entry->position * 4;
            int reg = get_temp_reg();
            if (entry->is_global) {
                // Global: Acessa pelo NOME (Label)
                fprintf(out, "    lw $t%d, %s\n", reg, entry->name);
            } else {
                // Local: Acessa pelo Stack Pointer ($fp)
                // Offset precisa considerar variáveis locais. 
                // Assumindo que position 0 é -4($fp), 1 é -8($fp)...
                int offset = (entry->position + 1) * 4; 
                fprintf(out, "    lw $t%d, -%d($fp)\n", reg, offset);
            }
            return reg;
        }

        case NODE_ASSIGN: {
            SymbolEntry* entry = node->attr.assign_stmt.lvalue->attr.id.entry;
            if (entry == NULL || entry->entry_type != ENTRY_VAR) {
                fprintf(stderr, "ERRO de Geração: L-value da atribuição inválido.\n");
                break;
            }
            // Gera o código do lado direito (Ex: 50) e pega o registrador (Ex: $t0)
            reg1 = generate_node_code(node->attr.assign_stmt.rvalue);
            
            // Gera o SW (Store Word)
            if (entry->is_global) {
                 fprintf(out, "    sw $t%d, %s\n", reg1, entry->name);
            } else {
                 int offset = (entry->position + 1) * 4;
                 fprintf(out, "    sw $t%d, -%d($fp)\n", reg1, offset);
            }
            
            return reg1; // <--- Retorna $t0 para quem chamou
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

        case NODE_FUNCCALL: {
            int reg = get_temp_reg(); // Registrador para o valor de retorno ($v0)
            
            // 1. Passagem de Argumentos (Suporte básico para até 4 args em $a0-$a3)
            ASTNode* arg = node->attr.func_call.args;
            int arg_idx = 0;
            
            while(arg != NULL && arg_idx < 4) {
                // Gera código para avaliar a expressão do argumento
                int r_arg = generate_node_code(arg);
                
                // Move do temporário para o registrador de argumento MIPS ($a0, $a1...)
                fprintf(out, "    move $a%d, $t%d\n", arg_idx, r_arg);
                
                free_temp_reg(r_arg); // Libera o temporário usado
                arg = arg->next;
                arg_idx++;
            }
            
            // 2. Chamada da Função (JAL - Jump And Link)
            // Usa o nome salvo na AST. 
            // Nota: Se 'id' for um NODE_ID, pegamos o nome dele.
            char* func_name = node->attr.func_call.id->attr.id.name;
            fprintf(out, "    jal %s\n", func_name);
            
            // 3. Recupera o Retorno
            fprintf(out, "    move $t%d, $v0\n", reg);
            
            return reg;
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
        case NODE_FUNC_DEF:
            collect_strings(node->attr.func_def.body); // Entrar na função
            break;
        case NODE_BLOCK:
            collect_strings(node->attr.block.stats);   // Entrar no bloco
            break;
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

    // --- NOVO: GERA .DATA PARA VARIÁVEIS GLOBAIS ---
    ASTNode* current = ast_root;
    while (current != NULL) {
        if (current->type == NODE_VAR_DECL) {
             // Gera:  fat: .word 0
             fprintf(out, "%s: .word 0\n", current->attr.var_decl.name);
        }
        // Se entrou numa função ou no main, para de procurar globais
        if (current->type == NODE_FUNC_DEF || current->type == NODE_BLOCK) break;
        current = current->next;
    }

	// Itera sobre a lista de strings e as declara no .data
    StringLabel* s_curr = string_list_head;
    while (s_curr != NULL) {
        fprintf(out, "_str%d: .asciiz \"%s\"\n", s_curr->id, s_curr->content);
        s_curr = s_curr->next;
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