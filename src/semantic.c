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

        case NODE_ID: { // Abrimos um bloco para poder declarar uma variável local
            // 1. Procurar o nome do ID na pilha de tabelas de símbolos
            SymbolEntry* entry = search_name(stack, node->attr.id.name);

            // 2. Verificar se foi encontrado
            if (entry == NULL) {
                // ERRO: O símbolo não foi encontrado em nenhum escopo visível.
                fprintf(stderr, "ERRO SEMÂNTICO: O identificador '%s' não foi declarado (linha %d)\n", 
                        node->attr.id.name, node->line);
                // Futuramente, podemos ter um contador de erros para parar a compilação.
            } else {
                // 3. SUCESSO: O ID foi declarado. Agora vamos "decorar" o nó.
                // Guardamos um ponteiro para a entrada da tabela dentro do próprio nó da ASA.
                node->attr.id.entry = entry;
                // Agora, em qualquer outra fase, para saber o tipo deste ID,
                // basta acessar node->attr.id.entry->data_type.
            }
            break;
        }

        case NODE_OP_BIN:
            // Visita os filhos primeiro
            check_node(node->attr.op_bin.left, stack);
            check_node(node->attr.op_bin.right, stack);

            // TODO: Verificar se os tipos dos filhos são válidos para a operação.
            // Ex: Para OP_ADD, ambos devem ser do tipo inteiro.
            break;

        // ... Adicionar 'case' para todos os outros tipos de nós (IF, WHILE, WRITE, etc.)
        
        default:
            // Nós que não precisam de checagem ou ainda não foram implementados
            break;
    }

    // Continua a verificação para o próximo comando na lista
    check_node(node->next, stack);
}

// Função principal que é chamada pelo main
void check_semantics(ASTNode* ast_root, SymbolStack* symbol_stack) {
    printf("--- INICIANDO ANÁLISE SEMÂNTICA ---\n");
    check_node(ast_root, symbol_stack);
    printf("--- FIM DA ANÁLISE SEMÂNTICA ---\n");
}