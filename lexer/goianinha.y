/* goianinha.y - Syntactic analyzer for Goianinha language */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tokens.h"
#include "symbol_table.h"

extern int yylineno;
extern char* yytext;
extern FILE* yyin;
extern int yylex(void);

void yyerror(const char* msg);
SymbolStack symbol_stack = { .top = -1 }; // Inicializa a pilha
DataType current_type;
SymbolEntry* current_func = NULL;

%}

/* Define union for semantic values */
%union {
    char* str;
    int num;
    DataType type; // Tipo da expressão
    int arg_count; // Contador de argumentos em chamadas de função
}

/* Non-terminal types */
%type <type> Expr AssignExpr OrExpr AndExpr EqExpr DesigExpr AddExpr MulExpr UnExpr PrimExpr
%type <arg_count> ListExpr

/* Tokens with semantic values */
%token <str> TOKEN_ID TOKEN_CARCONST TOKEN_STRING
%token <num> TOKEN_INTCONST

/* Tokens without semantic values */
%token TOKEN_PROGRAMA TOKEN_CAR TOKEN_INT TOKEN_RETORNE TOKEN_LEIA TOKEN_ESCREVA TOKEN_NOVALINHA
%token TOKEN_SE TOKEN_ENTAO TOKEN_SENAO TOKEN_ENQUANTO TOKEN_EXECUTE
%token TOKEN_PLUS TOKEN_MINUS TOKEN_TIMES TOKEN_DIV TOKEN_ASSIGN
%token TOKEN_EQ TOKEN_NEQ TOKEN_LT TOKEN_GT TOKEN_LE TOKEN_GE
%token TOKEN_LPAREN TOKEN_RPAREN TOKEN_LBRACE TOKEN_RBRACE TOKEN_SEMI TOKEN_COMMA
%token TOKEN_OR TOKEN_AND

/* Operator precedence */
%left TOKEN_ASSIGN
%left TOKEN_OR
%left TOKEN_AND
%left TOKEN_EQ TOKEN_NEQ
%left TOKEN_LT TOKEN_GT TOKEN_LE TOKEN_GE
%left TOKEN_PLUS TOKEN_MINUS
%left TOKEN_TIMES TOKEN_DIV

/* Start symbol */
%start Programa

%%

/* Grammar rules */
Programa: DeclFuncVar DeclProg { };

DeclFuncVar: Tipo TOKEN_ID DeclVar TOKEN_SEMI DeclFuncVar {
    if (search_name(&symbol_stack, $2) != NULL) {
        fprintf(stderr, "ERRO: Variável %s redeclarada na linha %d\n", $2, yylineno);
    } else {
        insert_variable(&symbol_stack, $2, current_type, 0);
    }
}
           | Tipo TOKEN_ID DeclFunc DeclFuncVar {
    if (search_name(&symbol_stack, $2) != NULL) {
        fprintf(stderr, "ERRO: Função %s redeclarada na linha %d\n", $2, yylineno);
    } else if (symbol_stack.top < 0) {
        fprintf(stderr, "ERRO: Nenhum escopo ativo na linha %d\n", yylineno);
    } else {
        current_func = insert_function(&symbol_stack, $2, 0, current_type);
        if (current_func == NULL) {
            fprintf(stderr, "ERRO: Falha ao inserir função %s na linha %d\n", $2, yylineno);
        }
    }
}
           | /* vazio */ { };

DeclProg: TOKEN_PROGRAMA Bloco { };

Tipo: TOKEN_INT { current_type = TYPE_INT; }
    | TOKEN_CAR { current_type = TYPE_CHAR; };

DeclVar: TOKEN_COMMA TOKEN_ID DeclVar {
    if (search_name(&symbol_stack, $2) != NULL) {
        fprintf(stderr, "ERRO: Variável %s redeclarada na linha %d\n", $2, yylineno);
    } else {
        insert_variable(&symbol_stack, $2, current_type, 0);
    }
}
       | /* vazio */ { };

DeclFunc: TOKEN_LPAREN ListaParametros TOKEN_RPAREN Bloco {
    current_func = NULL;
};

ListaParametros: /* vazio */ { }
               | ListaParametrosCont { };

ListaParametrosCont: Tipo TOKEN_ID {
    if (current_func == NULL) {
        fprintf(stderr, "ERRO: Parâmetro %s fora de uma função na linha %d\n", $2, yylineno);
    } else if (search_name(&symbol_stack, $2) != NULL) {
        fprintf(stderr, "ERRO: Parâmetro %s redeclarado na linha %d\n", $2, yylineno);
    } else {
        SymbolEntry* param = insert_parameter(&symbol_stack, $2, current_type, current_func->num_params + 1, current_func);
        if (param != NULL) {
            current_func->num_params++;
        } else {
            fprintf(stderr, "ERRO: Falha ao inserir parâmetro %s na linha %d\n", $2, yylineno);
        }
    }
}
                   | Tipo TOKEN_ID TOKEN_COMMA ListaParametrosCont {
    if (current_func == NULL) {
        fprintf(stderr, "ERRO: Parâmetro %s fora de uma função na linha %d\n", $2, yylineno);
    } else if (search_name(&symbol_stack, $2) != NULL) {
        fprintf(stderr, "ERRO: Parâmetro %s redeclarado na linha %d\n", $2, yylineno);
    } else {
        SymbolEntry* param = insert_parameter(&symbol_stack, $2, current_type, current_func->num_params + 1, current_func);
        if (param != NULL) {
            current_func->num_params++;
        } else {
            fprintf(stderr, "ERRO: Falha ao inserir parâmetro %s na linha %d\n", $2, yylineno);
        }
    }
};

Bloco: TOKEN_LBRACE { new_scope(&symbol_stack); } ListaDeclVar ListaComando TOKEN_RBRACE { remove_scope(&symbol_stack); };

ListaDeclVar: /* vazio */ { }
            | Tipo TOKEN_ID DeclVar TOKEN_SEMI ListaDeclVar {
    if (search_name(&symbol_stack, $2) != NULL) {
        fprintf(stderr, "ERRO: Variável %s redeclarada na linha %d\n", $2, yylineno);
    } else {
        insert_variable(&symbol_stack, $2, current_type, 0);
    }
};

ListaComando: /* vazio */ { }
            | Comando ListaComando { };

Comando: TOKEN_SEMI { }
       | Expr TOKEN_SEMI { }
       | TOKEN_RETORNE Expr TOKEN_SEMI {
    if (current_func != NULL && $2 != current_func->data_type) {
        fprintf(stderr, "ERRO: Tipo de retorno %s não corresponde ao tipo da função na linha %d\n",
                $2 == TYPE_INT ? "int" : $2 == TYPE_CHAR ? "char" : "unknown", yylineno);
    }
}
       | TOKEN_LEIA TOKEN_ID TOKEN_SEMI {
    if (search_name(&symbol_stack, $2) == NULL) {
        fprintf(stderr, "ERRO: Variável %s não declarada na linha %d\n", $2, yylineno);
    }
    free($2);
}
       | TOKEN_ESCREVA Expr TOKEN_SEMI { }
       | TOKEN_ESCREVA TOKEN_STRING TOKEN_SEMI { }
       | TOKEN_NOVALINHA TOKEN_SEMI { }
       | TOKEN_SE TOKEN_LPAREN Expr TOKEN_RPAREN TOKEN_ENTAO Comando {
    if ($3 != TYPE_INT) {
        fprintf(stderr, "ERRO: Condição do 'se' deve ser do tipo int na linha %d\n", yylineno);
    }
}
       | TOKEN_SE TOKEN_LPAREN Expr TOKEN_RPAREN TOKEN_ENTAO Comando TOKEN_SENAO Comando {
    if ($3 != TYPE_INT) {
        fprintf(stderr, "ERRO: Condição do 'se' deve ser do tipo int na linha %d\n", yylineno);
    }
}
       | TOKEN_ENQUANTO TOKEN_LPAREN Expr TOKEN_RPAREN TOKEN_EXECUTE Comando {
    if ($3 != TYPE_INT) {
        fprintf(stderr, "ERRO: Condição do 'enquanto' deve ser do tipo int na linha %d\n", yylineno);
    }
}
       | Bloco { };

Expr: OrExpr { $$ = $1; }
    | AssignExpr { $$ = $1; };

AssignExpr: TOKEN_ID TOKEN_ASSIGN Expr {
    SymbolEntry* entry = search_name(&symbol_stack, $1);
    if (entry == NULL) {
        fprintf(stderr, "ERRO: Variável %s não declarada na linha %d\n", $1, yylineno);
        $$ = TYPE_UNKNOWN;
    } else if (entry->data_type != $3) {
        fprintf(stderr, "ERRO: Tipos incompatíveis na atribuição na linha %d\n", yylineno);
        $$ = TYPE_UNKNOWN;
    } else {
        $$ = entry->data_type;
    }
    free($1);
};

OrExpr: OrExpr TOKEN_OR AndExpr {
    if ($1 != TYPE_INT || $3 != TYPE_INT) {
        fprintf(stderr, "ERRO: Operação 'ou' exige operandos int na linha %d\n", yylineno);
        $$ = TYPE_UNKNOWN;
    } else {
        $$ = TYPE_INT;
    }
}
      | AndExpr { $$ = $1; };

AndExpr: AndExpr TOKEN_AND EqExpr {
    if ($1 != TYPE_INT || $3 != TYPE_INT) {
        fprintf(stderr, "ERRO: Operação 'e' exige operandos int na linha %d\n", yylineno);
        $$ = TYPE_UNKNOWN;
    } else {
        $$ = TYPE_INT;
    }
}
       | EqExpr { $$ = $1; };

EqExpr: EqExpr TOKEN_EQ DesigExpr {
    if ($1 != $3 || ($1 != TYPE_INT && $1 != TYPE_CHAR)) {
        fprintf(stderr, "ERRO: Operação '==' exige operandos do mesmo tipo (int ou char) na linha %d\n", yylineno);
        $$ = TYPE_UNKNOWN;
    } else {
        $$ = TYPE_INT;
    }
}
      | EqExpr TOKEN_NEQ DesigExpr {
    if ($1 != $3 || ($1 != TYPE_INT && $1 != TYPE_CHAR)) {
        fprintf(stderr, "ERRO: Operação '!=' exige operandos do mesmo tipo (int ou char) na linha %d\n", yylineno);
        $$ = TYPE_UNKNOWN;
    } else {
        $$ = TYPE_INT;
    }
}
      | DesigExpr { $$ = $1; };

DesigExpr: DesigExpr TOKEN_LT AddExpr {
    if ($1 != $3 || ($1 != TYPE_INT && $1 != TYPE_CHAR)) {
        fprintf(stderr, "ERRO: Operação '<' exige operandos do mesmo tipo (int ou char) na linha %d\n", yylineno);
        $$ = TYPE_UNKNOWN;
    } else {
        $$ = TYPE_INT;
    }
}
         | DesigExpr TOKEN_GT AddExpr {
    if ($1 != $3 || ($1 != TYPE_INT && $1 != TYPE_CHAR)) {
        fprintf(stderr, "ERRO: Operação '>' exige operandos do mesmo tipo (int ou char) na linha %d\n", yylineno);
        $$ = TYPE_UNKNOWN;
    } else {
        $$ = TYPE_INT;
    }
}
         | DesigExpr TOKEN_LE AddExpr {
    if ($1 != $3 || ($1 != TYPE_INT && $1 != TYPE_CHAR)) {
        fprintf(stderr, "ERRO: Operação '<=' exige operandos do mesmo tipo (int ou char) na linha %d\n", yylineno);
        $$ = TYPE_UNKNOWN;
    } else {
        $$ = TYPE_INT;
    }
}
         | DesigExpr TOKEN_GE AddExpr {
    if ($1 != $3 || ($1 != TYPE_INT && $1 != TYPE_CHAR)) {
        fprintf(stderr, "ERRO: Operação '>=' exige operandos do mesmo tipo (int ou char) na linha %d\n", yylineno);
        $$ = TYPE_UNKNOWN;
    } else {
        $$ = TYPE_INT;
    }
}
         | AddExpr { $$ = $1; };

AddExpr: AddExpr TOKEN_PLUS MulExpr {
    if ($1 != TYPE_INT || $3 != TYPE_INT) {
        fprintf(stderr, "ERRO: Operação '+' exige operandos int na linha %d\n", yylineno);
        $$ = TYPE_UNKNOWN;
    } else {
        $$ = TYPE_INT;
    }
}
       | AddExpr TOKEN_MINUS MulExpr {
    if ($1 != TYPE_INT || $3 != TYPE_INT) {
        fprintf(stderr, "ERRO: Operação '-' exige operandos int na linha %d\n", yylineno);
        $$ = TYPE_UNKNOWN;
    } else {
        $$ = TYPE_INT;
    }
}
       | MulExpr { $$ = $1; };

MulExpr: MulExpr TOKEN_TIMES UnExpr {
    if ($1 != TYPE_INT || $3 != TYPE_INT) {
        fprintf(stderr, "ERRO: Operação '*' exige operandos int na linha %d\n", yylineno);
        $$ = TYPE_UNKNOWN;
    } else {
        $$ = TYPE_INT;
    }
}
       | MulExpr TOKEN_DIV UnExpr {
    if ($1 != TYPE_INT || $3 != TYPE_INT) {
        fprintf(stderr, "ERRO: Operação '/' exige operandos int na linha %d\n", yylineno);
        $$ = TYPE_UNKNOWN;
    } else {
        $$ = TYPE_INT;
    }
}
       | UnExpr { $$ = $1; };

UnExpr: TOKEN_MINUS PrimExpr {
    if ($2 != TYPE_INT) {
        fprintf(stderr, "ERRO: Operação unária '-' exige operando int na linha %d\n", yylineno);
        $$ = TYPE_UNKNOWN;
    } else {
        $$ = TYPE_INT;
    }
}
      | PrimExpr { $$ = $1; };

PrimExpr: TOKEN_ID TOKEN_LPAREN ListExpr TOKEN_RPAREN {
    SymbolEntry* entry = search_name(&symbol_stack, $1);
    if (entry == NULL || entry->entry_type != ENTRY_FUNC) {
        fprintf(stderr, "ERRO: Função %s não declarada na linha %d\n", $1, yylineno);
        $$ = TYPE_UNKNOWN;
    } else if ($3 != entry->num_params) {
        fprintf(stderr, "ERRO: Número de argumentos incorreto para função %s na linha %d\n", $1, yylineno);
        $$ = TYPE_UNKNOWN;
    } else {
        $$ = entry->data_type;
    }
    free($1);
}
        | TOKEN_ID TOKEN_LPAREN TOKEN_RPAREN {
    SymbolEntry* entry = search_name(&symbol_stack, $1);
    if (entry == NULL || entry->entry_type != ENTRY_FUNC) {
        fprintf(stderr, "ERRO: Função %s não declarada na linha %d\n", $1, yylineno);
        $$ = TYPE_UNKNOWN;
    } else if (entry->num_params != 0) {
        fprintf(stderr, "ERRO: Número de argumentos incorreto para função %s na linha %d\n", $1, yylineno);
        $$ = TYPE_UNKNOWN;
    } else {
        $$ = entry->data_type;
    }
    free($1);
}
        | TOKEN_ID {
    SymbolEntry* entry = search_name(&symbol_stack, $1);
    if (entry == NULL) {
        fprintf(stderr, "ERRO: Variável %s não declarada na linha %d\n", $1, yylineno);
        $$ = TYPE_UNKNOWN;
    } else {
        $$ = entry->data_type;
    }
    free($1);
}
        | TOKEN_CARCONST { $$ = TYPE_CHAR; }
        | TOKEN_INTCONST { $$ = TYPE_INT; }
        | TOKEN_LPAREN Expr TOKEN_RPAREN { $$ = $2; };

ListExpr: Expr { $$ = 1; }
        | Expr TOKEN_COMMA ListExpr { $$ = 1 + $3; };

%%

/* Error handling */
void yyerror(const char* msg) {
    fprintf(stderr, "ERRO: %s na linha %d\n", msg, yylineno);
}

/* Main program */
int main(int argc, char* argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Uso: %s <arquivo>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "Erro ao abrir %s\n", argv[1]);
        return 1;
    }

    init_stack(&symbol_stack);
    new_scope(&symbol_stack);
    yyparse();
    fclose(yyin);

    print_stack(&symbol_stack);
    printf("Análise léxico-sintática concluída\n");
    destroy_stack(&symbol_stack);

    return 0;
}