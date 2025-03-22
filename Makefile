# Makefile for testing the symbol table implementation with support for multiple tests

# Detect the operating system
UNAME := $(shell uname)

# Set compiler based on OS
ifeq ($(UNAME), Darwin)  # macOS
	CC = clang
else                     # Linux (Ubuntu)
	CC = gcc
endif

# Compiler flags: warnings and debug info
CFLAGS = -Wall -g -I./src  # Include src/ for header files

# Directories
SRC_DIR = src
TEST_DIR = tests

# Source files from src/
SOURCES = $(wildcard $(SRC_DIR)/*.c)
OBJECTS = $(SOURCES:.c=.o)

# Test files from tests/
TEST_SOURCES = $(wildcard $(TEST_DIR)/*.c)
TEST_TARGETS = $(patsubst $(TEST_DIR)/%.c, symbol_%, $(TEST_SOURCES))

# Default target: build all test executables
all: $(TEST_TARGETS)

# Rule to link each test executable
symbol_%: $(TEST_DIR)/%.o $(OBJECTS)
	$(CC) -o $@ $^

# Compile source files in src/
$(SRC_DIR)/%.o: $(SRC_DIR)/%.c $(SRC_DIR)/symbol_table.h
	$(CC) $(CFLAGS) -c $< -o $@

# Compile test files in tests/
$(TEST_DIR)/%.o: $(TEST_DIR)/%.c $(SRC_DIR)/symbol_table.h
	$(CC) $(CFLAGS) -c $< -o $@

# Clean up generated files
clean:
	rm -f $(SRC_DIR)/*.o $(TEST_DIR)/*.o $(TEST_TARGETS)

# Phony targets (not real files)
.PHONY: all clean