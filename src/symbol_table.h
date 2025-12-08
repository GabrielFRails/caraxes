#ifndef SYMBLE_TABLE_H
#define SYMBLE_TABLE_H

#define MAX_NAME 50
#define MAX_SCOPES 100 // max scope stack number

// Goianinha Types
typedef enum {
    TYPE_INT,
    TYPE_CHAR,
    TYPE_UNKNOWN
} DataType;

// symbol table entry type
typedef enum {
    ENTRY_VAR,
    ENTRY_FUNC,
    ENTRY_PARAM
} EntryType;

typedef struct SymbolEntry {
    char name[MAX_NAME];        // Nome do identificador (lexema)
    EntryType entry_type;       // Tipo: variável, função ou parâmetro
    DataType data_type;         // Tipo de dado (int, char)
    DataType* param_types;      // isso é pra tentar pegar erro de passar parametro de tipo diferente em funções
    int position;               // Posição na lista de declaração (vars ou params)
    int num_params;             // Só para funções: número de parâmetros
    int is_global;              // apenas para controle melhor futuro
    struct SymbolEntry* next;   // Próxima entrada na tabela (lista encadeada)
    struct SymbolEntry* func_ptr; // Só para parâmetros: ponteiro para a função
} SymbolEntry;

// table struct for one scope
typedef struct SymbolTable {
    SymbolEntry* entries;       // scope entries stack
} SymbolTable;

typedef struct SymbolStack {
    SymbolTable* tables[MAX_SCOPES]; // table pointers
    int top;
} SymbolStack;

// function prototypes
void symbol_table_init_stack(SymbolStack* stack);
void symbol_table_new_scope(SymbolStack* stack);
SymbolEntry* symbol_table_search_name(SymbolStack* stack, const char* name);
void symbol_table_remove_scope(SymbolStack* stack);
SymbolEntry* symbol_table_insert_function(SymbolStack* stack, const char* name, int num_params, DataType return_type);
SymbolEntry* symbol_table_insert_variable(SymbolStack* stack, const char* name, DataType type, int position);
SymbolEntry* symbol_table_insert_parameter(SymbolStack* stack, const char* name, DataType type, int position, SymbolEntry* func);
void symbol_table_destroy_stack(SymbolStack* stack);
void symbol_table_print_stack(SymbolStack* stack);

#endif