#include <stdio.h>
#include <stdlib.h>
#include "codegen.h"

#define NUM_TEMP_REGS 10
static int temp_regs[NUM_TEMP_REGS] = {0}; // 0 = livre, 1 = em uso
static FILE* out;

static int get_temp_reg() {
    for (int i = 0; i < NUM_TEMP_REGS; i++) {
        if (temp_regs[i] == 0) {
            temp_regs[i] = 1; // Marca como em uso
            return i;
        }
    }
    fprintf(stderr, "ERRO: Nenhum registrador temporário livre!\n");
    exit(1);
}

static void free_temp_reg(int reg_num) {
    if (reg_num >= 0 && reg_num < NUM_TEMP_REGS) {
        temp_regs[reg_num] = 0;
    }
}

static void generate_node_code(ASTNode* node) {
    if (node == NULL) {
        return;
    }
    // TODO: implement switch(node->type)
}

void generate_code(ASTNode* ast_root, const char* output_filename) {
    out = fopen(output_filename, "w");
    if (out == NULL) {
        fprintf(stderr, "ERRO: Não foi possível abrir o arquivo de saída %s\n", output_filename);
        return;
    }

	// begin mips
    fprintf(out, ".text\n");
    fprintf(out, ".globl main\n\n");
    fprintf(out, "main:\n");

	// start recursion in ast tree
    generate_node_code(ast_root);

	// end mips
    fprintf(out, "li $v0, 10\n");
    fprintf(out, "syscall\n");

    fclose(out);
    printf("Código MIPS gerado com sucesso em %s\n", output_filename);
}