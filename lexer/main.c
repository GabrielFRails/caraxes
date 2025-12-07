int main(int argc, char* argv[]) {
    if (argc != 2) {
        printf("Uso: %s <arquivo>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        printf("Erro ao abrir %s\n", argv[1]);
        return 1;
    }

    // 1. Fase do Parser (Léxico + Sintático)
    symbol_table_init_stack(&symbol_stack);
    symbol_table_new_scope(&symbol_stack); // Escopo Global

    if (yyparse() != 0) {
        printf("Falha na análise lexico-sintática.\n");
        fclose(yyin);
        symbol_table_destroy_stack(&symbol_stack);
        return 1;
    }
    printf("Análise léxico-sintática concluída com sucesso.\n");

    symbol_table_destroy_stack(&symbol_stack);
    
    // Reiniciamos a tabela limpa
    symbol_table_init_stack(&symbol_stack);
    symbol_table_new_scope(&symbol_stack); // Novo Escopo Global Limpo
    // ---------------------------------------

    semantic_check_semantics(ast_root, &symbol_stack);
    generate_code(ast_root, &symbol_stack, "output.asm");

    // ast_print(ast_root); 

    fclose(yyin);
    symbol_table_destroy_stack(&symbol_stack);
    return 0;
}