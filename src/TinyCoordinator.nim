import TinyLexer, TinyParser, types/Token

var
    lexer: TinyLexer.Lexer = TinyLexer.Lexer()
    parser: TinyParser.Parser = TinyParser.Parser()

proc run(source: string) =
    lexer.setSource(source)
    var tokens: seq[Token] = lexer.scanTokens()
    lexer.print()

    parser.setTokenList(tokens)
    parser.AST.add parser.parseStatement()
    parser.print()


    #if (lexer.hasError):
    #    return



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
