import std/strutils

import TinyLexer

var
    lexer: TinyLexer.Lexer = TinyLexer.Lexer()

proc run(line: string) =
    lexer.setSource(line)
    lexer.scanTokens()

    lexer.print()

proc runFile*(fileName: string) =
    run(readFile(fileName))

proc runLine*() =
    while (true):
        stdout.write("> ")
        let source = readLine(stdin)

        if (source == "" or source == "exit"):
            break

        run(source)
