# Makefile for symbol table, lexical, and syntactic analyzer

UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
	CC = clang
	FLEX = flex
	BISON = bison
else
	CC = gcc
	FLEX = flex
	BISON = bison
endif

CFLAGS = -Wall -g -I./src -I./lexer

ifeq ($(UNAME), Darwin)
	LDFLAGS :=
else
	LDFLAGS := -lfl
endif

SRC_DIR = src
TEST_DIR = tests
LEXER_DIR = lexer

# Symbol table sources
SYMBOL_SOURCES = $(wildcard $(SRC_DIR)/*.c)
SYMBOL_OBJECTS = $(SYMBOL_SOURCES:.c=.o)

# Symbol table tests
TEST_SOURCES = $(wildcard $(TEST_DIR)/*.c)
TEST_TARGETS = $(patsubst $(TEST_DIR)/%.c, symbol_%, $(TEST_SOURCES))

# Lexer sources
LEXER_SRC = $(LEXER_DIR)/goianinha.c
LEXER_OBJ = $(LEXER_SRC:.c=.o)

# Parser sources
PARSER_SRC = $(LEXER_DIR)/goianinha.tab.c
PARSER_OBJ = $(PARSER_SRC:.c=.o)
PARSER_HEADER = $(LEXER_DIR)/goianinha.tab.h

# Main program
TARGET = $(LEXER_DIR)/goianinha

# Arquivo de log
LOGFILE = caraxes.log

# Default target: build everything + log
all: clean-log parser | log-banner
	@echo "=== COMPILAÇÃO FINALIZADA ===" | tee -a $(LOGFILE)
	@echo "   Log completo salvo em: $(LOGFILE)" | tee -a $(LOGFILE)

# Limpa o log antes de começar
clean-log:
	@echo "=== INICIANDO COMPILAÇÃO - $(shell date) ===" > $(LOGFILE)
	@echo "Projeto: Compilador Goianinha - Caraxes" >> $(LOGFILE)
	@echo "Aluno: Gabriel Freitas (@GabrielFRails)" >> $(LOGFILE)
	@echo "====================================================" >> $(LOGFILE)

# Banner bonito no início do log
log-banner:
	@echo >> $(LOGFILE)

# Target for symbol table tests
table: $(TEST_TARGETS)

# Target for parser (lexer + parser)
parser: $(TARGET)

# Symbol table test targets
symbol_%: $(TEST_DIR)/%.o $(SYMBOL_OBJECTS)
	$(CC) -o $@ $^

$(SRC_DIR)/%.o: $(SRC_DIR)/%.c $(SRC_DIR)/%.h
	$(CC) $(CFLAGS) -c $< -o $@ 2>&1 | tee -a $(LOGFILE)

$(TEST_DIR)/%.o: $(TEST_DIR)/%.c $(SRC_DIR)/symbol_table.h
	$(CC) $(CFLAGS) -c $< -o $@ 2>&1 | tee -a $(LOGFILE)

# Lexer targets
$(LEXER_SRC): $(LEXER_DIR)/goianinha.l $(LEXER_DIR)/tokens.h
	@echo "[FLEX] Gerando lexer..." | tee -a $(LOGFILE)
	$(FLEX) -o $(LEXER_SRC) $(LEXER_DIR)/goianinha.l 2>&1 | tee -a $(LOGFILE)

$(LEXER_OBJ): $(LEXER_SRC) $(PARSER_HEADER)
	@echo "[CC] Compilando lexer..." | tee -a $(LOGFILE)
	$(CC) $(CFLAGS) -c $< -o $@ 2>&1 | tee -a $(LOGFILE)

# Parser targets
$(PARSER_SRC) $(PARSER_HEADER): $(LEXER_DIR)/goianinha.y
	@echo "[BISON] Gerando parser..." | tee -a $(LOGFILE)
	$(BISON) -d -v $(LEXER_DIR)/goianinha.y -o $(PARSER_SRC) 2>&1 | tee -a $(LOGFILE)

$(PARSER_OBJ): $(PARSER_SRC)
	@echo "[CC] Compilando parser..." | tee -a $(LOGFILE)
	$(CC) $(CFLAGS) -c $< -o $@ 2>&1 | tee -a $(LOGFILE)

# Main program
$(TARGET): $(LEXER_OBJ) $(PARSER_OBJ) $(SYMBOL_OBJECTS)
	@echo "[LINK] Linkando executável $(TARGET)..." | tee -a $(LOGFILE)
	$(CC) -o $@ $^ $(LDFLAGS) 2>&1 | tee -a $(LOGFILE)

# Clean up generated files
clean:
	rm -f $(SRC_DIR)/*.o $(TEST_DIR)/*.o $(LEXER_DIR)/*.o $(LEXER_SRC) $(PARSER_SRC) $(PARSER_HEADER) $(TEST_TARGETS) $(TARGET)
	@echo "Limpeza concluída." | tee -a $(LOGFILE)

.PHONY: all table parser clean clean-log log-banner