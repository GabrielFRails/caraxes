#include <stdio.h>
#include "semantic.h"

// Função recursiva que percorre a árvore
void check_node(ASTNode* node, SymbolStack* stack) {
    if (node == NULL) {
        return;
    }

    // A estratégia geral é verificar os filhos primeiro (pós-ordem)
    // e depois verificar o nó atual.
    
    switch (node->type) {
        case NODE_ASSIGN:
            // Visita os filhos primeiro
            check_node(node->attr.assign_stmt.lvalue, stack);
            check_node(node->attr.assign_stmt.rvalue, stack);

            // TODO: Agora, verifique a semântica da atribuição.
            // 1. O filho da esquerda (lvalue) é um ID?
            // 2. Os tipos dos dois filhos são compatíveis?
            // Ex: if (lvalue->type_info != rvalue->type_info) { fprintf(stderr, "ERRO: Tipos incompativeis..."); }
            break;

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
    }

    // Continua a verificação para o próximo comando na lista
    check_node(node->next, stack);
}

void check_semantics(ASTNode* ast_root, SymbolStack* symbol_stack) {
    printf("--- INICIANDO ANÁLISE SEMÂNTICA ---\n");
    check_node(ast_root, symbol_stack);
    printf("--- FIM DA ANÁLISE SEMÂNTICA ---\n");
}