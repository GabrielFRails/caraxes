/* goianinha.y - Syntactic analyzer for Goianinha language */

%{
#include <stdio.h>
#include <stdlib.h>
#include "tokens.h"

extern int yylineno;
extern char* yytext;
extern FILE* yyin;
extern int yylex(void);

void yyerror(const char* msg);
%}

/* Define union for semantic values */
%union {
    char* str;
    int num;
}

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
Programa: DeclFuncVar DeclProg { printf("Programa reconhecido\n"); };

DeclFuncVar: Tipo TOKEN_ID DeclVar TOKEN_SEMI DeclFuncVar { printf("DeclFuncVar: var\n"); }
           | Tipo TOKEN_ID DeclFunc DeclFuncVar { printf("DeclFuncVar: func\n"); }
           | /* vazio */ { printf("DeclFuncVar: vazio\n"); };

DeclProg: TOKEN_PROGRAMA Bloco { printf("DeclProg reconhecido\n"); };

Tipo: TOKEN_INT { printf("Tipo: int\n"); }
    | TOKEN_CAR { printf("Tipo: car\n"); };

DeclVar: TOKEN_COMMA TOKEN_ID DeclVar { printf("DeclVar: id\n"); }
       | /* vazio */ { printf("DeclVar: vazio\n"); };

DeclFunc: TOKEN_LPAREN ListaParametros TOKEN_RPAREN Bloco { printf("DeclFunc reconhecida\n"); };

ListaParametros: /* vazio */ { printf("ListaParametros: vazio\n"); }
               | ListaParametrosCont { printf("ListaParametros: cont\n"); };

ListaParametrosCont: Tipo TOKEN_ID { printf("Parametro: id\n"); }
                   | Tipo TOKEN_ID TOKEN_COMMA ListaParametrosCont { printf("Parametro: id, cont\n"); };

Bloco: TOKEN_LBRACE ListaDeclVar ListaComando TOKEN_RBRACE { printf("Bloco reconhecido\n"); };

ListaDeclVar: /* vazio */ { printf("ListaDeclVar: vazio\n"); }
            | Tipo TOKEN_ID DeclVar TOKEN_SEMI ListaDeclVar { printf("ListaDeclVar: var\n"); };

ListaComando: /* vazio */ { printf("ListaComando: vazio\n"); }
            | Comando ListaComando { printf("ListaComando: comando\n"); };

Comando: TOKEN_SEMI { printf("Comando: ;\n"); }
       | Expr TOKEN_SEMI { printf("Comando: expr\n"); }
       | TOKEN_RETORNE Expr TOKEN_SEMI { printf("Comando: retorne\n"); }
       | TOKEN_LEIA TOKEN_ID TOKEN_SEMI { printf("Comando: leia\n"); }
       | TOKEN_ESCREVA Expr TOKEN_SEMI { printf("Comando: escreva expr\n"); }
       | TOKEN_ESCREVA TOKEN_STRING TOKEN_SEMI { printf("Comando: escreva string\n"); }
       | TOKEN_NOVALINHA TOKEN_SEMI { printf("Comando: novalinha\n"); }
       | TOKEN_SE TOKEN_LPAREN Expr TOKEN_RPAREN TOKEN_ENTAO Comando { printf("Comando: se\n"); }
       | TOKEN_SE TOKEN_LPAREN Expr TOKEN_RPAREN TOKEN_ENTAO Comando TOKEN_SENAO Comando { printf("Comando: se senao\n"); }
       | TOKEN_ENQUANTO TOKEN_LPAREN Expr TOKEN_RPAREN TOKEN_EXECUTE Comando { printf("Comando: enquanto\n"); }
       | Bloco { printf("Comando: bloco\n"); };

Expr: OrExpr { printf("Expr: or\n"); }
    | TOKEN_ID TOKEN_ASSIGN Expr { printf("Expr: assign\n"); };

OrExpr: OrExpr TOKEN_OR AndExpr { printf("OrExpr: or\n"); }
      | AndExpr { printf("OrExpr: and\n"); };

AndExpr: AndExpr TOKEN_AND EqExpr { printf("AndExpr: and\n"); }
       | EqExpr { printf("AndExpr: eq\n"); };

EqExpr: EqExpr TOKEN_EQ DesigExpr { printf("EqExpr: eq\n"); }
      | EqExpr TOKEN_NEQ DesigExpr { printf("EqExpr: neq\n"); }
      | DesigExpr { printf("EqExpr: desig\n"); };

DesigExpr: DesigExpr TOKEN_LT AddExpr { printf("DesigExpr: lt\n"); }
         | DesigExpr TOKEN_GT AddExpr { printf("DesigExpr: gt\n"); }
         | DesigExpr TOKEN_LE AddExpr { printf("DesigExpr: le\n"); }
         | DesigExpr TOKEN_GE AddExpr { printf("DesigExpr: ge\n"); }
         | AddExpr { printf("DesigExpr: add\n"); };

AddExpr: AddExpr TOKEN_PLUS MulExpr { printf("AddExpr: plus\n"); }
       | AddExpr TOKEN_MINUS MulExpr { printf("AddExpr: minus\n"); }
       | MulExpr { printf("AddExpr: mul\n"); };

MulExpr: MulExpr TOKEN_TIMES UnExpr { printf("MulExpr: times\n"); }
       | MulExpr TOKEN_DIV UnExpr { printf("MulExpr: div\n"); }
       | UnExpr { printf("MulExpr: un\n"); };

UnExpr: TOKEN_MINUS PrimExpr { printf("UnExpr: minus\n"); }
      | PrimExpr { printf("UnExpr: prim\n"); };

PrimExpr: TOKEN_ID TOKEN_LPAREN ListExpr TOKEN_RPAREN { printf("PrimExpr: func call\n"); }
        | TOKEN_ID TOKEN_LPAREN TOKEN_RPAREN { printf("PrimExpr: func call vazio\n"); }
        | TOKEN_ID { printf("PrimExpr: id\n"); }
        | TOKEN_CARCONST { printf("PrimExpr: carconst\n"); }
        | TOKEN_INTCONST { printf("PrimExpr: intconst\n"); }
        | TOKEN_LPAREN Expr TOKEN_RPAREN { printf("PrimExpr: expr\n"); };

ListExpr: Expr { printf("ListExpr: expr\n"); }
        | Expr TOKEN_COMMA ListExpr { printf("ListExpr: expr, cont\n"); };

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

    yyparse();
    fclose(yyin);
    return 0;
}