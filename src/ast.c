#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

ASTNode* ast_create_node(NodeType type, int line) {
    ASTNode* node = (ASTNode*) malloc(sizeof(ASTNode));
    if (node == NULL) {
        fprintf(stderr, "ERRO: Falha na alocação de memória para nó da ASA\n");
        exit(1); // Erro fatal
    }
    node->type = type;
    node->line = line;
    node->next = NULL; // Inicializa o 'next' como nulo por padrão
    //node->type = TYPE_UNKNOWN; FEITO EM SEMANTIC.C
    return node;
}

// Nós de Expressão
ASTNode* ast_create_op_bin(OperatorType op, ASTNode* left, ASTNode* right, int line) {
    ASTNode* node = ast_create_node(NODE_OP_BIN, line);
    node->attr.op_bin.op = op;
    node->attr.op_bin.left = left;
    node->attr.op_bin.right = right;
    return node;
}

ASTNode* ast_create_op_un(OperatorType op, ASTNode* operand, int line) {
    ASTNode* node = ast_create_node(NODE_OP_UN, line);
    node->attr.op_un.op = op;
    node->attr.op_un.operand = operand;
    return node;
}

ASTNode* ast_create_int(int value, int line) {
    ASTNode* node = ast_create_node(NODE_INTCONST, line);
    node->attr.int_val = value;
    node->type_info = TYPE_INT; // Define o tipo do nó
    return node;
}

ASTNode* ast_create_id(char* name, int line) {
    ASTNode* node = ast_create_node(NODE_ID, line);
    // Usamos strdup para alocar uma nova string para o nome,
    // pois o yytext pode ser sobrescrito pelo lexer.
    node->attr.id.name = strdup(name); 
    return node;
}

// Nós de Comando
ASTNode* ast_create_if(ASTNode* condition, ASTNode* if_body, ASTNode* else_body, int line) {
    ASTNode* node = ast_create_node(NODE_IF, line);
    node->attr.if_stmt.condition = condition;
    node->attr.if_stmt.if_body = if_body;
    node->attr.if_stmt.else_body = else_body;
    return node;
}

ASTNode* ast_create_while(ASTNode* condition, ASTNode* loop_body, int line) {
    ASTNode* node = ast_create_node(NODE_WHILE, line);
    node->attr.while_stmt.condition = condition;
    node->attr.while_stmt.loop_body = loop_body;
    return node;
}

ASTNode* ast_create_assign(ASTNode* lvalue, ASTNode* rvalue, int line) {
    ASTNode* node = ast_create_node(NODE_ASSIGN, line);
    node->attr.assign_stmt.lvalue = lvalue;
    node->attr.assign_stmt.rvalue = rvalue;
    return node;
}

ASTNode* ast_create_write(ASTNode* expression, int line) {
    ASTNode* node = ast_create_node(NODE_WRITE, line);
    node->attr.write_ret_stmt.expression = expression;
    return node;
}

// construção
ASTNode* ast_create_return(ASTNode* expression, int line) {
    ASTNode* node = ast_create_node(NODE_RETURN, line);
    node->attr.write_ret_stmt.expression = expression; // Reutilizando a struct
    return node;
}

ASTNode* ast_create_string(char* value, int line) {
    ASTNode* node = ast_create_node(NODE_STRINGCONST, line);
    node->attr.id.name = strdup(value); // Reutilizando o id_name para guardar a string
    //node->type_info = TYPE_CHAR;
    return node;
}

ASTNode* ast_create_novalinha(int line) {
    return ast_create_node(NODE_NOVALINHA, line);
}

ASTNode* ast_create_char(char value, int line) {
    ASTNode* node = ast_create_node(NODE_CHARCONST, line);
    node->attr.char_val = value;
    node->type_info = TYPE_CHAR;
    return node;
}

ASTNode* ast_create_funccall(ASTNode* id, ASTNode* args, int line) {
    ASTNode* node = ast_create_node(NODE_FUNCCALL, line);
    node->attr.func_call.id = id;
    node->attr.func_call.args = args;
    return node;
}

ASTNode* ast_create_read(ASTNode* id, int line) {
    ASTNode* node = ast_create_node(NODE_READ, line);
    node->attr.read_stmt.id = id;
    return node;
}

// prints
void ast_print_recursive(ASTNode* node, int level) {
    if (node == NULL) {
        //printf("ast_print_recursive: node null\n");
        return;
    }

    // Imprime a indentação
    for (int i = 0; i < level; i++) {
        printf("  ");
    }

    // Imprime o tipo do nó e seus atributos
    switch (node->type) {
        case NODE_OP_BIN:
            printf("OP_BIN (Op: %d, Linha: %d)\n", node->attr.op_bin.op, node->line);
            ast_print_recursive(node->attr.op_bin.left, level + 1);
            ast_print_recursive(node->attr.op_bin.right, level + 1);
            break;
        case NODE_OP_UN:
            printf("OP_UN (Op: %d, Linha: %d)\n", node->attr.op_un.op, node->line);
            ast_print_recursive(node->attr.op_un.operand, level + 1);
            break;
        case NODE_INTCONST:
            printf("INTCONST (Valor: %d, Linha: %d)\n", node->attr.int_val, node->line);
            break;
        case NODE_ID:
            printf("ID (Nome: %s, Linha: %d)\n", node->attr.id.name, node->line);
            break;
        case NODE_IF:
            printf("IF (Linha: %d)\n", node->line);
            ast_print_recursive(node->attr.if_stmt.condition, level + 1);
            ast_print_recursive(node->attr.if_stmt.if_body, level + 1);
            if (node->attr.if_stmt.else_body != NULL) {
                 for (int i = 0; i < level; i++) printf("  ");
                 printf("ELSE\n");
                 ast_print_recursive(node->attr.if_stmt.else_body, level + 1);
            }
            break;
        case NODE_WHILE:
            printf("WHILE (Linha: %d)\n", node->line);
            ast_print_recursive(node->attr.while_stmt.condition, level + 1);
            ast_print_recursive(node->attr.while_stmt.loop_body, level + 1);
            break;
        case NODE_ASSIGN:
            printf("ASSIGN (Linha: %d)\n", node->line);
            ast_print_recursive(node->attr.assign_stmt.lvalue, level + 1);
            ast_print_recursive(node->attr.assign_stmt.rvalue, level + 1);
            break;
        case NODE_WRITE:
            printf("WRITE (Linha: %d)\n", node->line);
            ast_print_recursive(node->attr.write_ret_stmt.expression, level + 1);
            break;
        case NODE_STRINGCONST:
            // Reutilizamos o id_name para guardar a string
            printf("STRINGCONST (Valor: \"%s\", Linha: %d)\n", node->attr.id.name, node->line);
            break;
        case NODE_NOVALINHA:
            printf("NOVALINHA (Linha: %d)\n", node->line);
            break;
        case NODE_RETURN:
            printf("RETURN (Linha: %d)\n", node->line);
            ast_print_recursive(node->attr.write_ret_stmt.expression, level + 1);
            break;
        case NODE_FUNCCALL:
            printf("FUNCCALL (Linha: %d)\n", node->line);
            ast_print_recursive(node->attr.func_call.id, level + 1);
            if (node->attr.func_call.args != NULL) {
                 for (int i = 0; i < level + 1; i++) printf("  ");
                 printf("ARGS:\n");
                 ast_print_recursive(node->attr.func_call.args, level + 2);
            }
            break;
        default:
            printf("Nó Desconhecido (Tipo: %d)\n", node->type);
            break;
    }

    // Se houver um próximo comando na sequência, imprime-o no mesmo nível
    ast_print_recursive(node->next, level);
}

// Função pública que inicia a impressão
void ast_print(ASTNode* root) {
    printf("--- INÍCIO DA ÁRVORE SINTÁTICA ABSTRATA ---\n");
    ast_print_recursive(root, 0);
    printf("--- FIM DA ÁRVORE SINTÁTICA ABSTRATA ---\n");
}
