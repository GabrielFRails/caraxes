#ifndef CODEGEN_H
#define CODEGEN_H

#include "ast.h"

void generate_code(ASTNode* ast_root, SymbolStack* symbol_stack, const char* output_filename);

#endif