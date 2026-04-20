# TinyBASIC Interpreter

A lightweight, educational implementation of a TinyBASIC interpreter written in [Nim](https://nim-lang.org/).

This project was built from scratch and features a complete interpretation pipeline, including a custom lexer, parser, and evaluator to execute TinyBASIC code. It supports both a file-execution mode and an interactive REPL (Read-Eval-Print Loop).

## Features

* **Custom Lexer and Parser:** Tokenizes and parses TinyBASIC source into an Abstract Syntax Tree (AST).
* **Tree-Walk Evaluator:** Executes the generated AST.
* **Interactive REPL:** Write and evaluate scode line-by-line interactively in the terminal.
* **File Execution:** Run existing TinyBASIC scripts directly.
* **Error Handling:** Displays syntax and evaluation errors to the user gracefully.

## Prerequisites

To compile and run this project, you will need the Nim compiler installed on your system.
* [Download and install Nim](https://nim-lang.org/install.html)

## Building the Project

You can compile the project using the standard Nim compiler:

```bash
nim c -d:release TinyBasic.nim
```

## Usage

### Interactive REPL Mode
Start the compiled interpreter to enter the REPL mode. Once inside, you can type your TinyBASIC instructions and use the following REPL commands:

* `RUN`: Executes the currently stored program.
* `LIST`: Displays the currently stored program code.
* `CLEAR`: Clears the stored program from memory.
* `EXIT`: Closes the REPL and exits the interpreter.

### Running a File
You can evaluate scripts directly by passing a file path to the interpreter:

```bash
./TinyBasic your_script.txt
```

## Architecture

* `TinyLexer`: Scans the raw source string and breaks it down into a sequence of Tokens.
* `TinyParser`: Processes the Tokens to generate an Abstract Syntax Tree (AST).
* `TinyEvaluator`: Walks through the AST to evaluate and execute instructions.
* `TinyCoordinator`: Connects the lexer, parser, and evaluator, and manages the interactive REPL state.
