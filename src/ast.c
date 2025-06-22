#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

ASTNode* create_node(NodeType type, int line) {
    ASTNode* node = (ASTNode*) malloc(sizeof(ASTNode));
    if (node == NULL) {
        fprintf(stderr, "ERRO: Falha na alocação de memória para nó da ASA\n");
        exit(1); // Erro fatal
    }
    node->type = type;
    node->line = line;
    node->next = NULL; // Inicializa o 'next' como nulo por padrão
    return node;
}

// ASTNode* create_op_node(OperatorType op, ASTNode* left, ASTNode* right, int line) { ... } ?
// ASTNode* create_if_node(ASTNode* cond, ASTNode* if_body, ASTNode* else_body, int line) { ... } ?