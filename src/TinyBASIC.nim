import TinyLexer

var lexer: TinyLexer.Lexer = TinyLexer.Lexer()

proc runFile*(fileName: string) =
    lexer.setSource(readFile(fileName))

    lexer.print()

proc runLine*(line: string) =
    lexer.setSource(line)

    lexer.print()
