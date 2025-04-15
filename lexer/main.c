#include <stdio.h>

extern FILE *yyin;  // Declarar como extern, não definir
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
    while (1) {
        token = yylex();
        //fprintf(stderr, "DEBUG: yylex returned %d\n", token);
        if (token == 0) break;  // EOF
        if (token == -1) break;  // Error
        if (token > 0) {
            printf("Encontrado o lexema %s pertencente ao token de codigo %d linha %d\n",
                   yytext, token, yylineno);
        }
    }

    fclose(yyin);
    return 0;
}