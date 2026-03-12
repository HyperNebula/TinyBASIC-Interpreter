import TinyLexer, Error

var
    errorBag: seq[Error]
    lexer: TinyLexer.Lexer = TinyLexer.Lexer()

proc run(source: string) =
    lexer.setSource(source)
    lexer.scanTokens()

    #if (lexer.hasError):
    #    return

    lexer.print()

proc runFile*(fileName: string) =
    run(readFile(fileName))
    if (lexer.hasError):
        quit(65)

proc runLine*() =
    while (true):
        stdout.write("> ")
        let source = readLine(stdin)

        if (source == "" or source == "exit"):
            break

        run(source & $'\n')
