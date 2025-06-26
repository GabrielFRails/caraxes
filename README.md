# Caraxes Compiler

![Caraxes from HOTD](./etc/img/eou35gg7uqz91.jpg)

A Goianinha Compiler developed during Compilers Course at UFG (CS Course)

## Pre requirements:
macOS or Linux (Ubuntu): Tested on both systems.
GCC/Clang: C compiler (GCC for Ubuntu, Clang for macOS).
Flex: For generating the lexical analyzer. (sudo apt install flex or brew install flex)
Bison: (sudo apt install bison or brew install bison)
Make: To run the Makefile.

## First milestone
This first stage of the Goianinha compiler project implements a symbol table using a stack of scopes to manage identifiers (functions, variables, and parameters) and a lexical analyzer generated with Flex to recognize tokens from the Goianinha language grammar. It includes basic error handling for memory allocation and lexical errors, with separate test programs for each component.

### How to use:
```
$ cd caraxes
$ make
$ ./lexer/goianinha ./tests/test.g
$ ./lexer/goianinha ./tests/test_error.g
$ ./lexer/goianinha ./tests/erroLin6Caractereinvalido%.g
$ ./lexer/goianinha ./tests/expressao1ErroLin4CadeiaNaoTermina.g
$ ./lexer/goianinha ./tests/expressao1Correto.g
$ ./lexer/goianinha ./tests/fatorialErroLin1ComentarioNtermina.g
$ ./lexer/goianinha ./tests/fatorialErroLin15String2linhas.g
```

### targets
```
- all: Builds everything (symbol table, tests, lexical/syntax analyzer and semantic analyzer).

- table: Compiles the symbol table test program (symbol_main) from tests/.

- lexico: Compiles the lexical analyzer executable (lexer/goianinha) using Flex.

- clean: Removes all generated files (objects, executables, and goianinha.c).
```

## The Evolution of the  Goianinha Compiler

The development followed an incremental approach, mirroring the classic phases of a compiler.

### Phase 1: The Foundation - Understanding "Words" and "Memory"

The first step was to build the foundation upon which everything else would be built. (symbol table and flex for lexical analysis)

#### Lexical Analysis (The Reader)
* **Responsibility:** To convert the source code text into a sequence of "tokens" (the basic words of the language), such as keywords (`programa`, `se`), identifiers (`x`, `fatorial`), operators (`+`, `=`), and constants.

* **Implementation:** Using the `Flex` tool, rules were created to recognize the patterns for each token. In this phase, the compiler also learned to ignore whitespace and comments (`/* ... */`), as per the language specification.

#### Symbol Table (The Memory)
* **Responsibility:** To manage all identifiers declared in the program, storing information such as their type, scope, and nature (variable, function, or parameter).

* **Implementation:** A **stack of scopes** (`SymbolStack`) data structure was implemented. Each time a new scope (`{...}`) is opened, a new table is pushed onto the stack. The search for a name (`search_name`) begins from the top of the stack (local scope) to the bottom (global scope), which naturally implements the variable shadowing rule.

### Phase 2: The Structure - Validating the "Grammar"

With the ability to read words and store information, the next evolution was to check if the program's "sentences" were grammatically correct. This is Syntactic Analysis. (bison)

#### Syntactic Analysis (The Grammar Checker)
* **Responsibility:** To verify if the sequence of tokens from the lexical analyzer adheres to the grammatical rules of the Goianinha language.

* **Implementation:** Using the `Bison` tool, the formal grammar of the language was defined in the `goianinha.y` file. At this stage, the compiler became capable of identifying structural errors, such as a missing parenthesis or semicolon, through the `yyerror` function.

### Phase 3: The Crucial Evolution - The Intermediate Representation (AST)

This was the project's biggest evolutionary leap: transforming the syntactic analyzer from a simple validator into a **constructor**.

#### The Abstract Syntax Tree (The Code's Blueprint)
* **Responsibility:** To create a hierarchical and structured representation of the source code in memory. The AST is focused on meaning and operations, discarding syntactic noise.

* **Implementation:** The rules in `goianinha.y` were expanded with **semantic actions**. Upon recognizing a grammatical structure, the syntactic analyzer now calls helper functions (`ast_create_*` in `ast.c`) to allocate and connect nodes, building the tree step-by-step. The `ast_print` function was an essential debugging tool for visualizing and validating the AST's structure.

### Phase 4: The Intelligence - Understanding the "Meaning"

With the code's blueprint (the AST) in hand, the final step of the front-end was to give "intelligence" to the compiler.

#### Semantic Analysis (The Brain)
* **Responsibility:** To traverse the AST to check if the program, while syntactically correct, makes sense according to the language's rules.
* **Implementation:** A separate module (`semantic.c`) was created that recursively traverses the tree. This module uses the Symbol Table intensively to perform its checks.
* **Implemented Capabilities:**
    * **Declaration Checking:** Ensures that every variable or function used has been previously declared in a valid scope.
    * **Type Checking:** Validates type compatibility in operations (`int + char`), assignments (`int x = 'a';`), and `if`/`while` conditions.
    * **Function Call Validation:** Ensures the number of arguments in a function call matches its declaration.

	* **Function Return Type Validation**: Ensure that the return matches the function specification (TODO)

## Demonstrating the Separation of Phases

A practical demonstration is the best way to illustrate the separation of phases.

1.  **Lexical Error:** A file with `int x = 5 # 2;` fails in the first phase.
2.  **Syntactic Error:** A file with `se x > 5 entao ...` (missing parentheses) passes lexical analysis but fails during the syntactic phase.
3.  **Semantic Error:** A file with `int x = 'a';` is syntactically perfect but is caught by the semantic analyzer.
4.  **Success:** A fully correct program passes through all analysis phases, ready for code generation.

## Next Steps (TODO)

1. After success in all steps above, translate goianinha to MIPS Assembly.
2. Implement function return semantic value validation
3. Improve project organization

## Expected organization

- proper dirs to '.h' files
- proper dirs to each compiler phase
- uncouple semantic analysis from goiaininha.y
...
- sugestions?