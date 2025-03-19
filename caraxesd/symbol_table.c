#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

void init_stack(SymbolStack* stack) {
    stack->top = -1;
}

void new_scope(SymbolStack* stack) {
    if (stack->top + 1 >= MAX_SCOPES) {
        printf("Max number of scopes!");
        return;
    }

    SymbolTable* table = (SymbolTable*) malloc (sizeof(SymbolTable));
    table->entries = NULL;
    stack->tables[++stack->top] = table;
}

SymbolEntry* search_name(SymbolStack* stack, const char * name) {
    for (int i = stack->top; i>=0; i--) {
        SymbolEntry* current = stack->tables[i]->entries;
        while (current != NULL) {
            if (strcmp(current->name, name) == 0) {
                return current; // Encontrou
            }
            current = current->next;
        }
    }
    return NULL;
}

void remove_scope(SymbolStack* stack) {
    if (stack->top < 0) return; // empty stack
    SymbolTable* table = stack->tables[stack->top];
    SymbolEntry* current = table->entries;
    while (current != NULL) {
        SymbolEntry* next = current->next;
        free(current);
        current = next;
    }
    free(table);
    stack->top--;
}

SymbolEntry* insert_function(SymbolStack* stack, const char* name, int num_params, DataType return_type) {
    if (stack->top < 0) {
        printf("Erro: Nenhum escopo ativo!\n");
        return NULL;
    }

    SymbolEntry* entry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
	if (entry == NULL) {
		printf("Error: Memory allocation failed!\n");
		return NULL;
	}

    strncpy(entry->name, name, MAX_NAME - 1);
    entry->entry_type = ENTRY_FUNC;
    entry->data_type = return_type;
    entry->num_params = num_params;
    entry->position = 0; // Não usado para funções
    entry->next = stack->tables[stack->top]->entries;
    entry->func_ptr = NULL; // Não usado
    stack->tables[stack->top]->entries = entry;

	return entry
}

// Libera toda a pilha
void destroy_stack(SymbolStack* stack) {
    while (stack->top >= 0) {
        remove_scope(stack);
    }
}

void insert_variable(SymbolStack* stack, const char* name, DataType type, int position) {
    if  (stack->top < 0) {
        printf("Error: No active scope!\n");
        return;
    }

    SymbolEntry* entry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
    strncpy(entry->name, name, MAX_NAME - 1);
    entry->entry_type = ENTRY_VAR;
    entry->data_type = type;
    entry->num_params = 0; //
    entry->position = position;
    entry->next = stack->tables[stack->top]->entries;
    entry->func_ptr = NULL;
    stack->tables[stack->top]->entries = entry;
}

void insert_parameter(SymbolStack* stack, const char* name, DataType type, int position, SymbolEntry* func) {
    if  (stack->top < 0) {
        printf("Error: No active scope!\n");
        return;
    }

    SymbolEntry* entry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
    strncpy(entry->name, name, MAX_NAME - 1);
    entry->entry_type = ENTRY_PARAM;
    entry->data_type = type;
    entry->num_params = 0;
    entry->position = position;
    entry->next = stack->tables[stack->top]->entries;
    entry->func_ptr = func;
    stack->tables[stack->top]->entries = entry;
}