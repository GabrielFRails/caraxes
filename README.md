# Caraxes Compiler

![Caraxes from HOTD](./etc/img/eou35gg7uqz91.jpg)

A Goianinha Compiler developed during Compilers Course at UFG (CS Course)

## First milestone
This first stage of the Goianinha compiler project implements a symbol table using a stack of scopes to manage identifiers (functions, variables, and parameters) and a lexical analyzer generated with Flex to recognize tokens from the Goianinha language grammar. It includes basic error handling for memory allocation and lexical errors, with separate test programs for each component.

### How to use:
```
$ cd caraxes
$ make
$ ./lexer/goianinha ./tests/test.g
```

### targets
```
- all: Builds both the symbol table tests and the lexical analyzer.

- table: Compiles the symbol table test program (symbol_main) from tests/.

- lexico: Compiles the lexical analyzer executable (lexer/goianinha) using Flex.

- clean: Removes all generated files (objects, executables, and goianinha.c).
```