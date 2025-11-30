/* goianinha.y - Analisador Sintático para a linguagem Goianinha com construção da ASA */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// my libs
#include "symbol_table.h"
#include "ast.h" 
#include "tokens.h"
#include "semantic.h"
#include "codegen.h"


extern int yylineno;
extern char* yytext;
extern FILE* yyin;
extern int yylex(void);

void yyerror(const char* msg);
SymbolStack symbol_stack = { .top = -1 }; // Inicializa a pilha
DataType current_type;
SymbolEntry* current_func = NULL;
ASTNode* ast_root = NULL; // Inicializa a árvore nula

%}

%union {
    char* str_val;
    int num_val;
    struct ASTNode* node;
}

/* não-terminais agora são 'node' */
%type <node> Programa DeclFuncVar DeclProg Bloco ListaDeclVar DeclVar ListaComando Comando DeclFunc
%type <node> Expr AssignExpr OrExpr AndExpr EqExpr DesigExpr AddExpr MulExpr UnExpr PrimExpr ListExpr
%type <node> ListaParametros ListaParametrosCont

/* Tokens com valores semânticos */
%token <str_val> TOKEN_ID TOKEN_CARCONST TOKEN_STRING
%token <num_val> TOKEN_INTCONST

/* Tokens sem valores semânticos */
%token TOKEN_PROGRAMA TOKEN_CAR TOKEN_INT TOKEN_RETORNE TOKEN_LEIA TOKEN_ESCREVA TOKEN_NOVALINHA
%token TOKEN_SE TOKEN_ENTAO TOKEN_SENAO TOKEN_ENQUANTO TOKEN_EXECUTE
%token TOKEN_PLUS TOKEN_MINUS TOKEN_TIMES TOKEN_DIV TOKEN_ASSIGN
%token TOKEN_EQ TOKEN_NEQ TOKEN_LT TOKEN_GT TOKEN_LE TOKEN_GE
%token TOKEN_LPAREN TOKEN_RPAREN TOKEN_LBRACE TOKEN_RBRACE TOKEN_SEMI TOKEN_COMMA
%token TOKEN_OR TOKEN_AND

/* Precedência de operadores */
%left TOKEN_ASSIGN
%left TOKEN_OR
%left TOKEN_AND
%left TOKEN_EQ TOKEN_NEQ
%left TOKEN_LT TOKEN_GT TOKEN_LE TOKEN_GE
%left TOKEN_PLUS TOKEN_MINUS
%left TOKEN_TIMES TOKEN_DIV

/* Símbolo inicial */
%start Programa

%%

Programa: DeclFuncVar DeclProg 
    { 
        if ($1 == NULL) {
            ast_root = $2;
        } else {
            // Vamos encontrar o final da lista de declarações globais/funções ($1)
            ASTNode* current = $1;
            while (current->next != NULL) {
                current = current->next;
            }
            // E conectar o Main ($2) no final dessa lista
            current->next = $2;
            
            // A raiz agora é o começo de tudo
            ast_root = $1; 
        }
    };

DeclFuncVar: 
    /* Opção 1: Variáveis Globais (com correção de tipo via Mid-Rule Action) */
    Tipo TOKEN_ID { $<num_val>$ = current_type; } DeclVar TOKEN_SEMI DeclFuncVar {
        DataType type = (DataType)$<num_val>3; // Recupera o tipo salvo antes da recursão
        
        // 1. Tabela de Símbolos
        if (symbol_table_search_name(&symbol_stack, $2) != NULL) {
            fprintf(stderr, "ERRO: Variável %s redeclarada na linha %d\n", $2, yylineno);
        } else {
            symbol_table_insert_variable(&symbol_stack, $2, type, 0);
        }
        
        // Insere as outras variáveis da lista (x, y, z...)
        ASTNode* node = $4;
        while (node != NULL) {
             if (node->type == NODE_VAR_DECL) {
                 if (symbol_table_search_name(&symbol_stack, node->attr.var_decl.name) != NULL) {
                      fprintf(stderr, "ERRO: Variável %s redeclarada...\n", node->attr.var_decl.name);
                 } else {
                      symbol_table_insert_variable(&symbol_stack, node->attr.var_decl.name, node->attr.var_decl.type, 0);
                 }
             }
             node = node->next;
        }

        // 2. Construção da AST com o TIPO CORRETO
        ASTNode* first = ast_create_var_decl($2, type, yylineno);
        first->next = $4;
        
        // Conecta ao resto das globais ($6)
        ASTNode* current = first;
        while (current->next != NULL) current = current->next;
        current->next = $6; 
        
        $$ = first;
        free($2);
    }
    
    /* Opção 2: Funções (com correção de tipo e nó de 5 argumentos) */
    | Tipo TOKEN_ID { 
        $<num_val>$ = current_type; // Salva o tipo de retorno
        if (symbol_table_search_name(&symbol_stack, $2) != NULL) {
            fprintf(stderr, "ERRO: Função %s redeclarada...\n", $2);
        } else {
            current_func = symbol_table_insert_function(&symbol_stack, $2, 0, current_type);
        }
    } DeclFunc DeclFuncVar { 
        DataType type = (DataType)$<num_val>3; // Recupera o tipo salvo
        
        // $4 agora é o nó FUNC_DEF criado em DeclFunc (que contém Params e Body)
        ASTNode* func_node = $4;
        
        // CORREÇÃO: Atualiza o Nome (que estava "") e o Tipo de Retorno (que estava UNKNOWN)
        if (func_node->attr.func_def.name) free(func_node->attr.func_def.name);
        func_node->attr.func_def.name = strdup($2);
        func_node->attr.func_def.return_type = type;
        
        // Conecta com a próxima função/variável
        func_node->next = $5;
        $$ = func_node;
        
        free($2);
    }
    | /* vazio */ { $$ = NULL; };

DeclProg: TOKEN_PROGRAMA Bloco { $$ = $2; };

Tipo: TOKEN_INT { current_type = TYPE_INT; }
    | TOKEN_CAR { current_type = TYPE_CHAR; };

DeclVar: TOKEN_COMMA TOKEN_ID DeclVar {
        // Agora retorna uma lista de nós de declaração
        ASTNode* node = ast_create_var_decl($2, current_type, yylineno);
        node->next = $3; // Encadeia
        $$ = node;
        free($2);
    }
    | /* vazio */ { $$ = NULL; };

ListaDeclVar: /* vazio */ { $$ = NULL; }
    |
    Tipo TOKEN_ID { $<num_val>$ = current_type; } DeclVar TOKEN_SEMI ListaDeclVar {
        DataType type = (DataType)$<num_val>3; // Recupera o tipo salvo
        
        ASTNode* first = ast_create_var_decl($2, type, yylineno);
        first->next = $4; // Liga com DeclVar (x, y...)
        
        ASTNode* current = first;
        while(current->next != NULL) current = current->next;
        current->next = $6; // Liga com ListaDeclVar (próxima linha)
        
        $$ = first;
        free($2);
    };

Bloco: TOKEN_LBRACE ListaDeclVar ListaComando TOKEN_RBRACE 
    { 
        // Cria um nó de BLOCO contendo declarações E comandos
        // Removemos symbol_table_new/remove_scope daqui!
        $$ = ast_create_block($2, $3, yylineno);
    };

DeclFunc: TOKEN_LPAREN ListaParametros TOKEN_RPAREN Bloco {
        current_func = NULL;
        /* Cria o nó FUNC_DEF aqui pois temos acesso aos parâmetros ($2).
           O nome ("") e o tipo (TYPE_UNKNOWN) serão corrigidos pela regra pai (DeclFuncVar). */
        $$ = ast_create_func_def("", TYPE_UNKNOWN, $2, $4, yylineno);
    };

ListaParametros: /* vazio */ { $$ = NULL; }
    | ListaParametrosCont { $$ = $1; };

ListaParametrosCont: 
    Tipo TOKEN_ID {
        // Caso base: não tem recursão, current_type é seguro
        if (current_func != NULL) symbol_table_insert_parameter(&symbol_stack, $2, current_type, ++(current_func->num_params), current_func);
        $$ = ast_create_var_decl($2, current_type, yylineno);
        free($2);
    }
    | Tipo TOKEN_ID { $<num_val>$ = current_type; } TOKEN_COMMA ListaParametrosCont {
        DataType type = (DataType)$<num_val>3; // Recupera o tipo salvo
        
        if (current_func != NULL) symbol_table_insert_parameter(&symbol_stack, $2, type, ++(current_func->num_params), current_func);
        
        ASTNode* node = ast_create_var_decl($2, type, yylineno);
        node->next = $5;
        $$ = node;
        free($2);
    };

ListaComando: /* vazio */ { $$ = NULL; }
    | Comando ListaComando 
        { 
            $1->next = $2; /* Encadeia os comandos */
            $$ = $1;
        };

Comando: TOKEN_SEMI { $$ = NULL; /* Comando vazio */ }
    | Expr TOKEN_SEMI { $$ = $1; }
    | TOKEN_RETORNE Expr TOKEN_SEMI { $$ = ast_create_return($2, yylineno); }
    | TOKEN_LEIA TOKEN_ID TOKEN_SEMI 
        { 
            $$ = ast_create_read(ast_create_id($2, yylineno), yylineno); 
            free($2); 
        }
    | TOKEN_ESCREVA Expr TOKEN_SEMI { $$ = ast_create_write($2, yylineno); }
    | TOKEN_ESCREVA TOKEN_STRING TOKEN_SEMI { $$ = ast_create_string($2, yylineno); }
    | TOKEN_NOVALINHA TOKEN_SEMI { $$ = ast_create_novalinha(yylineno); }
    | TOKEN_SE TOKEN_LPAREN Expr TOKEN_RPAREN TOKEN_ENTAO Comando { $$ = ast_create_if($3, $6, NULL, yylineno); }
    | TOKEN_SE TOKEN_LPAREN Expr TOKEN_RPAREN TOKEN_ENTAO Comando TOKEN_SENAO Comando { $$ = ast_create_if($3, $6, $8, yylineno); }
    | TOKEN_ENQUANTO TOKEN_LPAREN Expr TOKEN_RPAREN TOKEN_EXECUTE Comando { $$ = ast_create_while($3, $6, yylineno); }
    | Bloco { $$ = $1; };

Expr: OrExpr { $$ = $1; }
    | AssignExpr { $$ = $1; };

AssignExpr: TOKEN_ID TOKEN_ASSIGN Expr 
    { 
        $$ = ast_create_assign(ast_create_id($1, yylineno), $3, yylineno); 
        free($1); 
    };

OrExpr: OrExpr TOKEN_OR AndExpr { $$ = ast_create_op_bin(OP_OR, $1, $3, yylineno); }
    | AndExpr { $$ = $1; };

AndExpr: AndExpr TOKEN_AND EqExpr { $$ = ast_create_op_bin(OP_AND, $1, $3, yylineno); }
    | EqExpr { $$ = $1; };

EqExpr: EqExpr TOKEN_EQ DesigExpr { $$ = ast_create_op_bin(OP_EQ, $1, $3, yylineno); }
    | EqExpr TOKEN_NEQ DesigExpr { $$ = ast_create_op_bin(OP_NEQ, $1, $3, yylineno); }
    | DesigExpr { $$ = $1; };

DesigExpr: DesigExpr TOKEN_LT AddExpr { $$ = ast_create_op_bin(OP_LT, $1, $3, yylineno); }
    | DesigExpr TOKEN_GT AddExpr { $$ = ast_create_op_bin(OP_GT, $1, $3, yylineno); }
    | DesigExpr TOKEN_LE AddExpr { $$ = ast_create_op_bin(OP_LE, $1, $3, yylineno); }
    | DesigExpr TOKEN_GE AddExpr { $$ = ast_create_op_bin(OP_GE, $1, $3, yylineno); }
    | AddExpr { $$ = $1; };

AddExpr: AddExpr TOKEN_PLUS MulExpr { $$ = ast_create_op_bin(OP_ADD, $1, $3, yylineno); }
    | AddExpr TOKEN_MINUS MulExpr { $$ = ast_create_op_bin(OP_SUB, $1, $3, yylineno); }
    | MulExpr { $$ = $1; };

MulExpr: MulExpr TOKEN_TIMES UnExpr { $$ = ast_create_op_bin(OP_MUL, $1, $3, yylineno); }
    | MulExpr TOKEN_DIV UnExpr { $$ = ast_create_op_bin(OP_DIV, $1, $3, yylineno); }
    | UnExpr { $$ = $1; };

UnExpr: TOKEN_MINUS PrimExpr { $$ = ast_create_op_un(OP_NEG, $2, yylineno); }
    | PrimExpr { $$ = $1; };

PrimExpr: TOKEN_ID TOKEN_LPAREN ListExpr TOKEN_RPAREN 
        { 
            $$ = ast_create_funccall(ast_create_id($1, yylineno), $3, yylineno); 
            free($1); 
        }
    | TOKEN_ID TOKEN_LPAREN TOKEN_RPAREN 
        { 
            $$ = ast_create_funccall(ast_create_id($1, yylineno), NULL, yylineno); 
            free($1); 
        }
    | TOKEN_ID 
        { 
            $$ = ast_create_id($1, yylineno); 
            free($1); 
        }
    | TOKEN_CARCONST { $$ = ast_create_char($1[1], yylineno); free($1); } // Pega o caractere de dentro das aspas
    | TOKEN_INTCONST { $$ = ast_create_int($1, yylineno); }
    | TOKEN_LPAREN Expr TOKEN_RPAREN { $$ = $2; };

ListExpr: Expr { $$ = $1; }
    | Expr TOKEN_COMMA ListExpr 
        { 
            $1->next = $3; /* Encadeia os argumentos */
            $$ = $1; 
        };

%%

/* Função de tratamento de erro */
void yyerror(const char* msg) {
    fprintf(stderr, "ERRO SINTÁTICO: %s na linha %d\n", msg, yylineno);
}

/* Função principal */
int main(int argc, char* argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Uso: %s <arquivo>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "Erro ao abrir o arquivo %s\n", argv[1]);
        return 1;
    }

    symbol_table_init_stack(&symbol_stack);
    symbol_table_new_scope(&symbol_stack);
    
    if (yyparse() == 0) {
        printf("Análise léxico-sintática concluída com sucesso.\n");
    } else {
        printf("Falha na análise lexico-sintática, relatório a seguir:\n");
    }
    
    semantic_check_semantics(ast_root, &symbol_stack);
    generate_code(ast_root, &symbol_stack, "output.asm");
    ast_print(ast_root); // Imprime a árvore gerada

    fclose(yyin);
    //symbol_table_print_stack(&symbol_stack);
    symbol_table_destroy_stack(&symbol_stack);
    return 0;
}