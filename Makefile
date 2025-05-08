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
LDFLAGS = -lfl

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

# Default target: build everything
all: table parser

# Target for symbol table tests
table: $(TEST_TARGETS)

# Target for parser (lexer + parser)
parser: $(TARGET)

# Symbol table test targets
symbol_%: $(TEST_DIR)/%.o $(SYMBOL_OBJECTS)
	$(CC) -o $@ $^

$(SRC_DIR)/%.o: $(SRC_DIR)/%.c $(SRC_DIR)/%.h
	$(CC) $(CFLAGS) -c $< -o $@

$(TEST_DIR)/%.o: $(TEST_DIR)/%.c $(SRC_DIR)/symbol_table.h
	$(CC) $(CFLAGS) -c $< -o $@

# Lexer targets
$(LEXER_SRC): $(LEXER_DIR)/goianinha.l $(LEXER_DIR)/tokens.h
	$(FLEX) -o $(LEXER_SRC) $(LEXER_DIR)/goianinha.l

$(LEXER_OBJ): $(LEXER_SRC) $(PARSER_HEADER)
	$(CC) $(CFLAGS) -c $< -o $@

# Parser targets
$(PARSER_SRC) $(PARSER_HEADER): $(LEXER_DIR)/goianinha.y
	$(BISON) -d $(LEXER_DIR)/goianinha.y -o $(PARSER_SRC)

$(PARSER_OBJ): $(PARSER_SRC)
	$(CC) $(CFLAGS) -c $< -o $@

# Main program
$(TARGET): $(LEXER_OBJ) $(PARSER_OBJ) $(SYMBOL_OBJECTS)
	$(CC) -o $@ $^ $(LDFLAGS)

# Clean up generated files
clean:
	rm -f $(SRC_DIR)/*.o $(TEST_DIR)/*.o $(LEXER_DIR)/*.o $(LEXER_SRC) $(PARSER_SRC) $(PARSER_HEADER) $(TEST_TARGETS) $(TARGET)

.PHONY: all table parser clean