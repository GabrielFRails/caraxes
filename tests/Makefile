# Makefile para automação de testes do Compilador Goianinha
# Autor: Caraxes (Auxiliado por Gabriel Freitas)

# Caminho relativo para o executável do compilador
COMPILER = ../lexer/goianinha

# Arquivo final que será entregue/mostrado ao professor
OUTPUT_LOG = resultado_testes.txt

# Nome do arquivo temporário que seu código C gera (hardcoded no goianinha.y)
ASM_TEMP = output.asm

# Define quais arquivos testar. 
# O padrão pega todos os .g da pasta de geração de código (etapa final)
# Se quiser testar sintático, mude para: sintatico/Corretos/*.g
SOURCES = $(wildcard geracaoCodigo/Corretos/*.g)

# Regra padrão
all: clean run

run:
	@echo "=== Iniciando Bateria de Testes do Caraxes ==="
	@echo "RELATÓRIO DE COMPILAÇÃO - LINGUAGEM GOIANINHA" > $(OUTPUT_LOG)
	@echo "Data de execução: $$(date)" >> $(OUTPUT_LOG)
	@echo "============================================================" >> $(OUTPUT_LOG)
	@echo "" >> $(OUTPUT_LOG)
	
	@for file in $(SOURCES); do \
		echo "Testando: $$file"; \
		echo "############################################################" >> $(OUTPUT_LOG); \
		echo "ARQUIVO FONTE: $$file" >> $(OUTPUT_LOG); \
		echo "############################################################" >> $(OUTPUT_LOG); \
		echo "" >> $(OUTPUT_LOG); \
		\
		echo "--- SAÍDA DO COMPILADOR (AST & LOGS) ---" >> $(OUTPUT_LOG); \
		$(COMPILER) $$file >> $(OUTPUT_LOG) 2>&1; \
		\
		echo "" >> $(OUTPUT_LOG); \
		echo "--- CÓDIGO ASSEMBLY MIPS GERADO ---" >> $(OUTPUT_LOG); \
		if [ -f $(ASM_TEMP) ]; then \
			cat $(ASM_TEMP) >> $(OUTPUT_LOG); \
			rm $(ASM_TEMP); \
		else \
			echo "[ERRO] O arquivo $(ASM_TEMP) não foi gerado." >> $(OUTPUT_LOG); \
		fi; \
		\
		echo "" >> $(OUTPUT_LOG); \
		echo -e "\n\n" >> $(OUTPUT_LOG); \
	done
	
	@echo "=== Testes Finalizados ==="
	@echo "O relatório completo está em: tests/$(OUTPUT_LOG)"

clean:
	rm -f $(OUTPUT_LOG) $(ASM_TEMP)