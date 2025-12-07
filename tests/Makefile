# Makefile para automação de testes do Compilador Goianinha
# Autor: Caraxes (Auxiliado por Gabriel Freitas)

# Caminho relativo para o executável do compilador
COMPILER = ../lexer/goianinha

# Arquivo final que será entregue/mostrado ao professor
OUTPUT_LOG = resultado_testes.txt

# Nome do arquivo temporário que seu código C gera (hardcoded no goianinha.y)
ASM_TEMP = output.asm

# Diretório onde os arquivos assembly individuais serão salvos
ASM_DIR = assembly_files

# Busca recursiva por todos os arquivos .g em todos os subdiretórios
SOURCES = $(shell find . -name "*.g")

# Regra padrão
all: clean run

run:
	@echo "=== Iniciando Bateria de Testes do Caraxes ==="
	@echo "RELATÓRIO DE COMPILAÇÃO - LINGUAGEM GOIANINHA" > $(OUTPUT_LOG)
	@echo "Data de execução: $$(date)" >> $(OUTPUT_LOG)
	@echo "============================================================" >> $(OUTPUT_LOG)
	@echo "" >> $(OUTPUT_LOG)
	@mkdir -p $(ASM_DIR)
	@for file in $(SOURCES); do \
		echo "Testando: $$file"; \
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
	@echo "=== Testes Finalizados ==="
	@echo "O relatório completo está em: tests/$(OUTPUT_LOG)"
	@echo "Os arquivos assembly individuais estão em: tests/$(ASM_DIR)/"

clean:
	rm -f $(OUTPUT_LOG) $(ASM_TEMP)
	rm -rf $(ASM_DIR)