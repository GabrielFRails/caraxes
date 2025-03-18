// main.c
#include <stdio.h>
#include "symbol_table.h"

int main() {
    SymbolStack stack;
    init_stack(&stack);

    // Test 1: Create a scope and insert a function
    new_scope(&stack);
    insert_function(&stack, "soma", 2, TYPE_INT);
    SymbolEntry* func = search_name(&stack, "soma");
    if (func) {
        printf("Function found: %s, %d params, type %d\n", 
               func->name, func->num_params, func->data_type);
    }

    // Test 2: Insert a variable in the same scope
    insert_variable(&stack, "x", TYPE_INT, 1);
    SymbolEntry* var = search_name(&stack, "x");
    if (var) {
        printf("Variable found: %s, type %d, position %d\n", 
               var->name, var->data_type, var->position);
    }

    // Test 3: Create a new scope and insert a parameter
    new_scope(&stack);
    insert_parameter(&stack, "a", TYPE_INT, 1, func);
    SymbolEntry* param = search_name(&stack, "a");
    if (param) {
        printf("Parameter found: %s, type %d, position %d, function %s\n", 
               param->name, param->data_type, param->position, param->func_ptr->name);
    }

    // Test 4: Remove scope and search again
    remove_scope(&stack);
    param = search_name(&stack, "a");
    if (!param) {
        printf("Parameter 'a' not found after scope removal.\n");
    }

    destroy_stack(&stack);
    return 0;
}