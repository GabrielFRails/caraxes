# Makefile para automação de testes do Compilador Goianinha
# Autor: Caraxes (Auxiliado por Gabriel Freitas)

# Caminho relativo para o executável do compilador
COMPILER = ../lexer/goianinha

# Arquivo final de compilação que será entregue/mostrado ao professor
OUTPUT_LOG = resultado_testes.txt

# Arquivo final concatenado das EXECUÇÕES (SPIM)
FULL_EXEC_LOG = relatorio_execucoes.txt

# Nome do arquivo temporário que seu código C gera (hardcoded no goianinha.y)
ASM_TEMP = output.asm

# Diretório onde os arquivos assembly individuais serão salvos
ASM_DIR = assembly_files

# Diretório onde os logs de execução individuais do SPIM serão salvos
EXEC_DIR = execution_outputs

# Busca recursiva por todos os arquivos .g em todos os subdiretórios
SOURCES = $(shell find . -name "*.g")

# Regra padrão
all: clean run

# Compila os arquivos .g para .asm
run:
	@echo "=== Iniciando Bateria de Testes do Caraxes ==="
	@echo "RELATÓRIO DE COMPILAÇÃO - LINGUAGEM GOIANINHA" > $(OUTPUT_LOG)
	@echo "Data de execução: $$(date)" >> $(OUTPUT_LOG)
	@echo "============================================================" >> $(OUTPUT_LOG)
	@echo "" >> $(OUTPUT_LOG)
	@mkdir -p $(ASM_DIR)
	@for file in $(SOURCES); do \
		echo "Compilando: $$file"; \
		echo "############################################################" >> $(OUTPUT_LOG); \
		echo "ARQUIVO FONTE: $$file" >> $(OUTPUT_LOG); \
		echo "############################################################" >> $(OUTPUT_LOG); \
		echo "" >> $(OUTPUT_LOG); \
		echo "--- SAÍDA DO COMPILADOR (AST & LOGS) ---" >> $(OUTPUT_LOG); \
		$(COMPILER) "$$file" >> $(OUTPUT_LOG) 2>&1 || true; \
		echo "" >> $(OUTPUT_LOG); \
		echo "--- CÓDIGO ASSEMBLY MIPS GERADO ---" >> $(OUTPUT_LOG); \
		if [ -f $(ASM_TEMP) ]; then \
			cat $(ASM_TEMP) >> $(OUTPUT_LOG); \
			NAME=$$(basename "$$file" .g); \
			mv $(ASM_TEMP) $(ASM_DIR)/$$NAME.asm; \
		else \
			echo "[ERRO] O arquivo $(ASM_TEMP) não foi gerado." >> $(OUTPUT_LOG); \
		fi; \
		echo "" >> $(OUTPUT_LOG); \
		echo "" >> $(OUTPUT_LOG); \
	done
	
	@# --- GAMBIARRA DE LIMPEZA (ARQUIVOS DE ERRO) ---
	@echo "Removendo assemblies gerados indevidamente para casos de erro..."
	@rm -f $(ASM_DIR)/*Erro*.asm
	@rm -f $(ASM_DIR)/*erro*.asm
	
	@echo "=== Compilação Finalizada ==="
	@echo "O relatório de compilação está em: tests/$(OUTPUT_LOG)"
	@echo "Os arquivos assembly válidos (Corretos) estão em: tests/$(ASM_DIR)/"

# Novo Target: Executa os arquivos .asm gerados usando o SPIM
exec:
	@echo "=== Executando arquivos Assembly no SPIM ==="
	@mkdir -p $(EXEC_DIR)
	@rm -f $(FULL_EXEC_LOG)
	@echo "RELATÓRIO CONCATENADO DE EXECUÇÕES NO SPIM" > $(FULL_EXEC_LOG)
	@echo "Data: $$(date)" >> $(FULL_EXEC_LOG)
	@echo "============================================================" >> $(FULL_EXEC_LOG)
	@echo "" >> $(FULL_EXEC_LOG)
	@if [ -n "$$(ls -A $(ASM_DIR)/*.asm 2>/dev/null)" ]; then \
		for asm in $(ASM_DIR)/*.asm; do \
			NAME=$$(basename "$$asm" .asm); \
			echo "Executando: $$NAME.asm"; \
			spim -file "$$asm" > $(EXEC_DIR)/$$NAME.txt 2>&1; \
			echo "############################################################" >> $(FULL_EXEC_LOG); \
			echo "EXECUÇÃO: $$NAME.asm" >> $(FULL_EXEC_LOG); \
			echo "############################################################" >> $(FULL_EXEC_LOG); \
			echo "" >> $(FULL_EXEC_LOG); \
			cat $(EXEC_DIR)/$$NAME.txt >> $(FULL_EXEC_LOG); \
			echo "" >> $(FULL_EXEC_LOG); \
			echo "" >> $(FULL_EXEC_LOG); \
		done; \
		echo "=== Execução Finalizada ==="; \
		echo "Os outputs individuais estão em: tests/$(EXEC_DIR)/"; \
		echo "O relatório concatenado está em: tests/$(FULL_EXEC_LOG)"; \
	else \
		echo "[AVISO] Nenhum arquivo .asm encontrado em $(ASM_DIR). Rode 'make run' primeiro."; \
	fi

# Limpa tudo
clean:
	rm -f $(OUTPUT_LOG) $(ASM_TEMP) $(FULL_EXEC_LOG)
	rm -rf $(ASM_DIR) $(EXEC_DIR)