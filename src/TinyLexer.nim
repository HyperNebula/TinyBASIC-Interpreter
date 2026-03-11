type
    Lexer* = object
        source: string

proc setSource*(lexer: var Lexer, source: string) =
    lexer.source = source

proc print*(lexer: Lexer) =
    for l in lexer.source:
        echo l
