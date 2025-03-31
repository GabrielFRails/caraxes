# Makefile for symbol table and lexical analyzer with separate targets

UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
	CC = clang
	FLEX = flex
else
	CC = gcc
	FLEX = flex
endif

CFLAGS = -Wall -g -I./src

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
LEXER_MAIN = $(LEXER_DIR)/main.c
LEXER_MAIN_OBJ = $(LEXER_MAIN:.c=.o)
LEXER_TARGET = $(LEXER_DIR)/goianinha  # Ajustado para ficar em lexer/

# Default target: build everything
all: table lexico

# Target for symbol table tests
table: $(TEST_TARGETS)

# Target for lexical analyzer
lexico: $(LEXER_TARGET)

# Symbol table test targets
symbol_%: $(TEST_DIR)/%.o $(SYMBOL_OBJECTS)
	$(CC) -o $@ $^

$(SRC_DIR)/%.o: $(SRC_DIR)/%.c $(SRC_DIR)/symbol_table.h
	$(CC) $(CFLAGS) -c $< -o $@

$(TEST_DIR)/%.o: $(TEST_DIR)/%.c $(SRC_DIR)/symbol_table.h
	$(CC) $(CFLAGS) -c $< -o $@

# Lexer targets
$(LEXER_SRC): $(LEXER_DIR)/goianinha.l
	$(FLEX) -o $(LEXER_SRC) $(LEXER_DIR)/goianinha.l

$(LEXER_OBJ): $(LEXER_SRC)
	$(CC) $(CFLAGS) -c $< -o $@

$(LEXER_MAIN_OBJ): $(LEXER_MAIN)
	$(CC) $(CFLAGS) -c $< -o $@

$(LEXER_TARGET): $(LEXER_OBJ) $(LEXER_MAIN_OBJ)
	$(CC) -o $@ $^

# Clean up generated files
clean:
	rm -f $(SRC_DIR)/*.o $(TEST_DIR)/*.o $(LEXER_DIR)/*.o $(LEXER_SRC) $(TEST_TARGETS) $(LEXER_TARGET)

.PHONY: all table lexico clean