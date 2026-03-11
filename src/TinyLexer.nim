import Token

type
    Lexer* = object
        source: string
        lineCount: int = 0

proc setSource*(lexer: var Lexer, source: string) =
    lexer.source = source

proc print*(lexer: var Lexer) =
    lexer.lineCount.inc
    echo $lexer.linecount, ": ", lexer.source
