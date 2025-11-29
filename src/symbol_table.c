#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

void symbol_table_init_stack(SymbolStack* stack) {
    if (stack == NULL) return;
    stack->top = -1;
}

void symbol_table_new_scope(SymbolStack* stack) {
    if (stack == NULL || stack->top + 1 >= MAX_SCOPES) {
        fprintf(stderr, "ERRO: Não foi possível criar novo escopo\n");
        return;
    }

    SymbolTable* table = (SymbolTable*)malloc(sizeof(SymbolTable));
    if (table == NULL) {
        fprintf(stderr, "ERRO: Falha na alocação de memória para tabela\n");
        return;
    }
    table->entries = NULL;
    stack->tables[++stack->top] = table;
}

SymbolEntry* symbol_table_search_name(SymbolStack* stack, const char *name) {
    if (stack == NULL || stack->top < 0 || name == NULL) return NULL;
    for (int i = stack->top; i >= 0; i--) {
        SymbolEntry* current = stack->tables[i]->entries;
        while (current != NULL) {
            if (strcmp(current->name, name) == 0) {
                return current;
            }
            current = current->next;
        }
    }
    return NULL;
}

void symbol_table_remove_scope(SymbolStack* stack) {
    if (stack == NULL || stack->top < 0) return;
    if (stack == NULL || stack->top < 0) return;
    
    // comentado pois está gerando erros em outras partes do compilador
    /*
    SymbolTable* table = stack->tables[stack->top];
    SymbolEntry* current = table->entries;
    while (current != NULL) {
        SymbolEntry* next = current->next;
        free(current);
        current = next;
    }
    free(table);
    */
    stack->top--;
}

SymbolEntry* symbol_table_insert_function(SymbolStack* stack, const char* name, int num_params, DataType return_type) {
    if (stack == NULL || stack->top < 0 || name == NULL) {
        fprintf(stderr, "ERRO: Escopo inválido ou nome nulo para função\n");
        return NULL;
    }

    SymbolEntry* entry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
    if (entry == NULL) {
        fprintf(stderr, "ERRO: Falha na alocação de memória para entrada de função\n");
        return NULL;
    }

    strncpy(entry->name, name, MAX_NAME - 1);
    entry->name[MAX_NAME - 1] = '\0';
    entry->entry_type = ENTRY_FUNC;
    entry->data_type = return_type;
    entry->num_params = num_params;
    entry->position = 0;
    entry->next = stack->tables[stack->top]->entries;
    entry->func_ptr = NULL;
    stack->tables[stack->top]->entries = entry;

    return entry;
}

void symbol_table_destroy_stack(SymbolStack* stack) {
    if (stack == NULL) return;
    while (stack->top >= 0) {
        symbol_table_remove_scope(stack);
    }
}

SymbolEntry* symbol_table_insert_variable(SymbolStack* stack, const char* name, DataType type, int position) {
    if (stack == NULL || stack->top < 0 || name == NULL) {
        fprintf(stderr, "ERRO: Escopo inválido ou nome nulo para variável\n");
        return NULL;
    }

    SymbolEntry* entry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
    if (entry == NULL) {
        fprintf(stderr, "ERRO: Falha na alocação de memória para entrada de variável\n");
        return NULL;
    }

    strncpy(entry->name, name, MAX_NAME - 1);
    entry->name[MAX_NAME - 1] = '\0';
    entry->entry_type = ENTRY_VAR;
    entry->data_type = type;
    entry->num_params = 0;
    entry->position = position;
    entry->is_global = (stack->top == 0) ? 1 : 0;
    entry->next = stack->tables[stack->top]->entries;
    entry->func_ptr = NULL;
    stack->tables[stack->top]->entries = entry;

    return entry;
}

SymbolEntry* symbol_table_insert_parameter(SymbolStack* stack, const char* name, DataType type, int position, SymbolEntry* func) {
    if (stack == NULL || stack->top < 0 || name == NULL || func == NULL) {
        fprintf(stderr, "ERRO: Escopo inválido, nome nulo ou função nula para parâmetro\n");
        return NULL;
    }

    SymbolEntry* entry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
    if (entry == NULL) {
        fprintf(stderr, "ERRO: Falha na alocação de memória para entrada de parâmetro\n");
        return NULL;
    }

    strncpy(entry->name, name, MAX_NAME - 1);
    entry->name[MAX_NAME - 1] = '\0';
    entry->entry_type = ENTRY_PARAM;
    entry->data_type = type;
    entry->num_params = 0;
    entry->position = position;
    entry->next = stack->tables[stack->top]->entries;
    entry->func_ptr = func;
    stack->tables[stack->top]->entries = entry;

    return entry;
}

void symbol_table_print_stack(SymbolStack* stack) {
    if (stack == NULL || stack->top < 0) {
        printf("Tabela de Símbolos: Vazia\n");
        return;
    }
    printf("Tabela de Símbolos:\n");
    for (int i = stack->top; i >= 0; i--) {
        printf("Escopo %d:\n", i);
        SymbolEntry* current = stack->tables[i]->entries;
        while (current != NULL) {
            printf("  Nome: %s, Tipo: %s, Entrada: %s, Posição: %d, Num Params: %d\n",
                   current->name,
                   current->data_type == TYPE_INT ? "int" : current->data_type == TYPE_CHAR ? "char" : "unknown",
                   current->entry_type == ENTRY_VAR ? "var" : current->entry_type == ENTRY_FUNC ? "func" : "param",
                   current->position,
                   current->num_params);
            current = current->next;
        }
    }
}