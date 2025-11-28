#ifndef SEMANTIC_H
#define SEMANTIC_H

#include "ast.h"
#include "symbol_table.h"

// Def de cabeçalho da função que inicia a checagem semântica na árvore
void semantic_check_semantics(ASTNode* ast_root, SymbolStack* symbol_stack);
int is_declared_in_current_scope(SymbolStack* stack, const char* name);

#endif