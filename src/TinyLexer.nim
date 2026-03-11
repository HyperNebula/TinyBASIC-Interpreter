import std/strutils

type
    Lexer* = object
        source: string
        lineCount: int = 0

proc setSource*(lexer: var Lexer, source: string) =
    lexer.source = source

proc print*(lexer: var Lexer) =
    for l in splitLines(lexer.source):
        lexer.lineCount.inc
        echo $lexer.linecount, ": ", $l
