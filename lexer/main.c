// generate by LLM
#include <stdio.h>

FILE *yyin;
extern int yylineno;
extern char* yytext;
extern int yylex();

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Uso: %s <arquivo>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        printf("Erro ao abrir %s\n", argv[1]);
        return 1;
    }

    int token;
    while ((token = yylex()) != -1) {  // EOF is -1
        if (token > 0) {  // Valid token
            printf("Encontrado o lexema %s pertencente ao token de codigo %d linha %d\n",
                   yytext, token, yylineno);
        }
    }

    fclose(yyin);
    return 0;
}