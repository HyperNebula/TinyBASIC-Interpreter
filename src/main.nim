import std/os

import TinyLexer

let args = commandLineParams()
var
    source: string
    lexer: TinyLexer.Lexer = TinyLexer.Lexer()

if args.len > 1:
    echo "Usage: TinyBASIC [source]"
    quit()
elif args.len == 1:
    source = readFile(args[0])

    lexer.setSource(source)
    lexer.print()
else:
    while (true):
        source = readLine(stdin)

        if (source == "" or source == "exit"):
            break

        lexer.setSource(source)
        lexer.print()
