// Em um novo arquivo: ast.h

#ifndef AST_H
#define AST_H

// Enum para todos os tipos de nós possíveis na ASA
typedef enum {
    // Nós de Comando
    NODE_SEQ,           // Sequência de comandos (usando o ponteiro 'next')
    NODE_IF,            // Comando 'se'
    NODE_WHILE,         // Comando 'enquanto'
    NODE_ASSIGN,        // Atribuição (id = Expr)
    NODE_WRITE,         // Comando 'escreva'
    NODE_READ,          // Comando 'leia'
    NODE_RETURN,        // Comando 'retorne'
    NODE_FUNCCALL,      // Chamada de função

    // Nós de Expressão
    NODE_OP_BIN,        // Operador binário (+, -, *, /, E, OU, ==, !=, <, <=, >, >=)
    NODE_OP_UN,         // Operador unário (-, !)
    NODE_INTCONST,      // Constante inteira
    NODE_CHARCONST,     // Constante caractere
    NODE_ID,            // Identificador
    NODE_ARGLIST,       // Lista de argumentos de uma função

    NODE_STRINGCONST,   // Constante string
    NODE_NOVALINHA,     // Comando 'novalinha'
    
    // vamos ver se mais nós serão necessários depois
} NodeType;

// Enum para os operadores, para clareza
typedef enum {
    OP_ADD, OP_SUB, OP_MUL, OP_DIV, // Aritméticos
    OP_EQ, OP_NEQ, OP_LT, OP_LE, OP_GT, OP_GE, // Relacionais
    OP_AND, OP_OR, // Lógicos
    OP_NEG, OP_NOT // Unários
} OperatorType;


// A estrutura principal do nó da ASA
typedef struct ASTNode {
    NodeType type;
    int line;
    struct ASTNode *next; // Ponteiro para o próximo comando em uma sequência

    // União marcada para os atributos específicos de cada tipo de nó
    union {
        // Para operadores binários
        struct {
            OperatorType op;
            struct ASTNode *left;
            struct ASTNode *right;
        } op_bin;

        // Para operadores unários
        struct {
            OperatorType op;
            struct ASTNode *operand;
        } op_un;

        // Para IF
        struct {
            struct ASTNode *condition;
            struct ASTNode *if_body;
            struct ASTNode *else_body; // Pode ser NULL
        } if_stmt;

        // Para WHILE
        struct {
            struct ASTNode *condition;
            struct ASTNode *loop_body;
        } while_stmt;

        // Para atribuição
        struct {
            struct ASTNode *lvalue; // O identificador
            struct ASTNode *rvalue; // A expressão
        } assign_stmt;

        // Para leitura
        struct {
            struct ASTNode *id;
        } read_stmt;

        // Para escrita e retorno
        struct {
            struct ASTNode *expression;
        } write_ret_stmt;
        
        // Para chamada de função e lista de argumentos
        struct {
            struct ASTNode *id;
            struct ASTNode *args; // Ponteiro para o primeiro argumento (NODE_ARGLIST)
        } func_call;

        // Para constantes e identificadores
        int int_val;
        char char_val;
        char *id_name; // O lexema do identificador
    } attr;
} ASTNode;

// Nós de Expressão
ASTNode* ast_create_op_bin(OperatorType op, ASTNode* left, ASTNode* right, int line);
ASTNode* ast_create_op_un(OperatorType op, ASTNode* operand, int line);
ASTNode* ast_create_int(int value, int line);
ASTNode* ast_create_id(char* name, int line);

// Nós de Comando
ASTNode* ast_create_if(ASTNode* condition, ASTNode* if_body, ASTNode* else_body, int line);
ASTNode* ast_create_while(ASTNode* condition, ASTNode* loop_body, int line);
ASTNode* ast_create_assign(ASTNode* lvalue, ASTNode* rvalue, int line);
ASTNode* ast_create_write(ASTNode* expression, int line);

// Protótipo da função construtora (helper function)
ASTNode* ast_create_node(NodeType type, int line);

// print tree
void ast_print(ASTNode* root);

// construção
ASTNode* ast_create_return(ASTNode* expression, int line);
ASTNode* ast_create_string(char* value, int line);
ASTNode* ast_create_novalinha(int line);
ASTNode* ast_create_char(char value, int line);
ASTNode* ast_create_funccall(ASTNode* id, ASTNode* args, int line);
ASTNode* ast_create_read(ASTNode* id, int line);

#endif