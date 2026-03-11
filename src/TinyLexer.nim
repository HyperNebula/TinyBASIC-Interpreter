import Token

type
    Lexer* = object
        source: string
        lineCount: int = 0
        tokens: seq[Token]

proc setSource*(lexer: var Lexer, source: string) =
    lexer.source = source

proc print*(lexer: var Lexer) =
    lexer.lineCount.inc

    let sampleToken: Token = newToken(lexer.lineCount, STRING, lexer.source)

    echo $lexer.linecount, ": ", $sampleToken
