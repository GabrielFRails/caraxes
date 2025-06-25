#include <stdio.h>
#include "semantic.h"

// Função recursiva que percorre a árvore
void check_node(ASTNode* node, SymbolStack* stack) {
    if (node == NULL) {
        return;
    }
    
    switch (node->type) {
        case NODE_ASSIGN: {
            // Visita os filhos primeiro para que seus type_info sejam preenchidos
            ASTNode* lvalue = node->attr.assign_stmt.lvalue;
            ASTNode* rvalue = node->attr.assign_stmt.rvalue;
            
            check_node(lvalue, stack);
            check_node(rvalue, stack);

            // Agora, com os tipos dos filhos calculados, verificamos a semântica da atribuição.
            
            // 1. O tipo da variável que recebe (lvalue) deve ser o mesmo da expressão (rvalue).
            //    Também verificamos se os tipos não são UNKNOWN para evitar erros em cascata.
            if (lvalue->type_info != TYPE_UNKNOWN &&
                rvalue->type_info != TYPE_UNKNOWN &&
                lvalue->type_info != rvalue->type_info) 
            {
                fprintf(stderr, "ERRO SEMÂNTICO: Tipos incompatíveis na atribuição da linha %d. Não é possível atribuir um valor do tipo '%s' a uma variável do tipo '%s'.\n", 
                        node->line, 
                        rvalue->type_info == TYPE_INT ? "int" : "char", 
                        lvalue->type_info == TYPE_INT ? "int" : "char");
            }
            
            // 2. O tipo da expressão de atribuição como um todo é o tipo do lado esquerdo.
            node->type_info = lvalue->type_info;
            break;
        }

        case NODE_ID: {
            SymbolEntry* entry = search_name(stack, node->attr.id.name);
            if (entry == NULL) {
                fprintf(stderr, "ERRO SEMÂNTICO: O identificador '%s' não foi declarado (linha %d)\n", 
                        node->attr.id.name, node->line);
                node->type_info = TYPE_UNKNOWN; // Define o tipo como desconhecido
            } else {
                node->attr.id.entry = entry;
                node->type_info = entry->data_type; // Preenche o tipo do nó com o tipo da variável!
            }
            break;
        }

        case NODE_OP_BIN: {
            // Visita os filhos primeiro para que seus 'type_info' sejam preenchidos
            check_node(node->attr.op_bin.left, stack);
            check_node(node->attr.op_bin.right, stack);

            DataType type_left = node->attr.op_bin.left->type_info;
            DataType type_right = node->attr.op_bin.right->type_info;

            switch (node->attr.op_bin.op) {
                case OP_ADD:
                case OP_SUB:
                case OP_MUL:
                case OP_DIV:
                    // Regra: Operadores aritméticos exigem operandos do tipo int.
                    if (type_left != TYPE_INT || type_right != TYPE_INT) {
                        fprintf(stderr, "ERRO SEMÂNTICO: Operação aritmética na linha %d exige operandos do tipo int.\n", node->line);
                    }
                    // O resultado de uma operação aritmética é sempre int.
                    node->type_info = TYPE_INT;
                    break;
                
                case OP_EQ:
                case OP_NEQ:
                case OP_LT:
                case OP_LE:
                case OP_GT:
                case OP_GE:
                    // Regra: Operadores relacionais exigem operandos do mesmo tipo.
                    if (type_left != type_right) {
                        fprintf(stderr, "ERRO SEMÂNTICO: Operação relacional na linha %d exige operandos do mesmo tipo.\n", node->line);
                    }
                    // O resultado de uma comparação é um valor lógico, representado por int.
                    node->type_info = TYPE_INT;
                    break;
                
                case OP_AND:
                case OP_OR:
                    // Regra: Operadores lógicos exigem operandos "lógicos" (int).
                    if (type_left != TYPE_INT || type_right != TYPE_INT) {
                         fprintf(stderr, "ERRO SEMÂNTICO: Operação lógica na linha %d exige operandos do tipo int.\n", node->line);
                    }
                    node->type_info = TYPE_INT;
                    break;
                default:
                    break;
            }
            break;
        }

        case NODE_IF: {
            check_node(node->attr.if_stmt.condition, stack);
            if (node->attr.if_stmt.condition->type_info != TYPE_INT) {
                fprintf(stderr, "ERRO SEMÂNTICO: A condição do comando 'se' na linha %d deve ser do tipo int.\n", node->line);
            }

            check_node(node->attr.if_stmt.if_body, stack);
            check_node(node->attr.if_stmt.else_body, stack);
            break;
        }

        case NODE_WHILE: {
            check_node(node->attr.while_stmt.condition, stack);
            if (node->attr.while_stmt.condition->type_info != TYPE_INT) {
                fprintf(stderr, "ERRO SEMÂNTICO: A condição do comando 'enquanto' na linha %d deve ser do tipo int.\n", node->line);
            }

            check_node(node->attr.while_stmt.loop_body, stack);
            break;
        }
    }

    // Continua a verificação para o próximo comando na lista
    check_node(node->next, stack);
}

void check_semantics(ASTNode* ast_root, SymbolStack* symbol_stack) {
    printf("\n--- INICIANDO ANÁLISE SEMÂNTICA ---\n");
    check_node(ast_root, symbol_stack);
    printf("--- FIM DA ANÁLISE SEMÂNTICA ---\n");
}