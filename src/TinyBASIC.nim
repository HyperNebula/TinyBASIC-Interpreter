import std/strutils

import TinyLexer

var 
    lexer: TinyLexer.Lexer = TinyLexer.Lexer()

proc run(line: string) =
    lexer.setSource(line)

    lexer.print()

proc runFile*(fileName: string) =
    for l in splitLines(readFile(fileName)):
        run(l)

proc runLine*() =
    while (true):
        stdout.write("> ")
        let source = readLine(stdin)

        if (source == "" or source == "exit"):
            break

        run(source)
