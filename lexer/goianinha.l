/* goianinha.l - Lexical analyzer for Goianinha language */

%{
#include <stdio.h>
#include <string.h>
#include "tokens.h"

/* External variables used by Flex */
extern int yylineno;
extern char* yytext;
extern YYSTYPE yylval;

%}

%option noyywrap
%option yylineno

LETTER    [a-zA-Z]
DIGIT     [0-9]
ID        ({LETTER}|_)({LETTER}|{DIGIT}|_)*
INTCONST  {DIGIT}+
CARCONST  '([^'\\]|\\.)'
STRING    \"([^\"\n\\]|\\.)*\"

%%

"programa"    { return TOKEN_PROGRAMA; }
"car"         { return TOKEN_CAR; }
"int"         { return TOKEN_INT; }
"retorne"     { return TOKEN_RETORNE; }
"leia"        { return TOKEN_LEIA; }
"escreva"     { return TOKEN_ESCREVA; }
"novalinha"   { return TOKEN_NOVALINHA; }
"se"          { return TOKEN_SE; }
"entao"       { return TOKEN_ENTAO; }
"senao"       { return TOKEN_SENAO; }
"enquanto"    { return TOKEN_ENQUANTO; }
"execute"     { return TOKEN_EXECUTE; }
"ou"          { return TOKEN_OR; }
"e"           { return TOKEN_AND; }

{ID}          { 
    yylval.str_val = strdup(yytext); 
    if (yylval.str_val == NULL) {
        fprintf(stderr, "ERRO: Falha de alocação de memória na linha %d\n", yylineno);
        return -1;
    }
    return TOKEN_ID; 
}
{INTCONST}    { yylval.num_val = atoi(yytext); return TOKEN_INTCONST; }
{CARCONST}    { 
    yylval.str_val = strdup(yytext); 
    if (yylval.str_val == NULL) {
        fprintf(stderr, "ERRO: Falha de alocação de memória na linha %d\n", yylineno);
        return -1;
    }
    return TOKEN_CARCONST; 
}
{STRING}      { 
    yylval.str_val = strdup(yytext); 
    if (yylval.str_val == NULL) {
        fprintf(stderr, "ERRO: Falha de alocação de memória na linha %d\n", yylineno);
        return -1;
    }
    return TOKEN_STRING; 
}

"+"           { return TOKEN_PLUS; }
"-"           { return TOKEN_MINUS; }
"*"           { return TOKEN_TIMES; }
"/"           { return TOKEN_DIV; }
"="           { return TOKEN_ASSIGN; }
"=="          { return TOKEN_EQ; }
"!="          { return TOKEN_NEQ; }
"<"           { return TOKEN_LT; }
">"           { return TOKEN_GT; }
"<="          { return TOKEN_LE; }
">="          { return TOKEN_GE; }
"("           { return TOKEN_LPAREN; }
")"           { return TOKEN_RPAREN; }
"{"           { return TOKEN_LBRACE; }
"}"           { return TOKEN_RBRACE; }
";"           { return TOKEN_SEMI; }
","           { return TOKEN_COMMA; }

"/*"          { /* Skip comments */
                int c;
                while (1) {
                    c = input();
                    if (c == EOF || c == 0) {
                        fprintf(stderr, "ERRO: COMENTÁRIO NAO TERMINA %d\n", yylineno);
                        return -1;
                    }
                    if (c == '*') {
                        c = input();
                        if (c == EOF || c == 0) {
                            fprintf(stderr, "ERRO: COMENTÁRIO NAO TERMINA %d\n", yylineno);
                            return -1;
                        }
                        if (c == '/') {
                            break;
                        }
                    }
                }
              }

[ \t\n]+      { /* Ignore whitespace */ }

{STRING}\n    { fprintf(stderr, "ERRO: CADEIA DE CARACTERES OCUPA MAIS DE UMA LINHA %d\n", yylineno);
                return -1; }

.             { fprintf(stderr, "ERRO: CARACTERE INVÁLIDO %d\n", yylineno);
                return -1; }

<<EOF>>       { return 0; }

%%