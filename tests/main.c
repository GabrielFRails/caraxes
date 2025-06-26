// teste para tabelas
#include <stdio.h>
#include "../src/symbol_table.h"

int main() {
    SymbolStack stack;
    symbol_table_init_stack(&stack);

    // Test 1: Create a scope and insert a function
    symbol_table_new_scope(&stack);
    symbol_table_insert_function(&stack, "soma", 2, TYPE_INT);
    SymbolEntry* func = symbol_table_search_name(&stack, "soma");
    if (func) {
        printf("Function found: %s, %d params, type %d\n", 
               func->name, func->num_params, func->data_type);
    }

    // Test 2: Insert a variable in the same scope
    symbol_table_insert_variable(&stack, "x", TYPE_INT, 1);
    SymbolEntry* var = symbol_table_search_name(&stack, "x");
    if (var) {
        printf("Variable found: %s, type %d, position %d\n", 
               var->name, var->data_type, var->position);
    }

    // Test 3: Create a new scope and insert a parameter
    symbol_table_new_scope(&stack);
    symbol_table_insert_parameter(&stack, "a", TYPE_INT, 1, func);
    SymbolEntry* param = symbol_table_search_name(&stack, "a");
    if (param) {
        printf("Parameter found: %s, type %d, position %d, function %s\n", 
               param->name, param->data_type, param->position, param->func_ptr->name);
    }

    // Test 4: Remove scope and search again
    symbol_table_remove_scope(&stack);
    param = symbol_table_search_name(&stack, "a");
    if (!param) {
        printf("Parameter 'a' not found after scope removal.\n");
    }

    symbol_table_destroy_stack(&stack);
    return 0;
}