import std/strutils

import Token

type
    Lexer* = object
        source: string
        lineCount: int = 1
        currentPos: int = 0
        startPos: int = 0
        tokens: seq[Token]

proc setSource*(lexer: var Lexer, source: string) = ## Used to set the source for the lexer
    lexer.source = source


proc addToken(lexer: var Lexer, tokenType: TokenType) = ## addToken procs to create tokens and then add it to the token sequence
    lexer.tokens.add(newToken(lexer.lineCount, tokenType))

proc addToken(lexer: var Lexer, tokenType: TokenType, value: string) = ## Adds STRING or VAR token to lexer tokens sequence
    if tokenType == STRING or tokenType == VAR:
        lexer.tokens.add(newToken(lexer.lineCount, tokenType, value))
    else:
        echo "Error in lexer"

proc addToken(lexer: var Lexer, tokenType: TokenType, INTvalue: int) = ## Adds DIGIT token to lexer tokens sequence
    if tokenType == DIGIT:
        lexer.tokens.add(newToken(lexer.lineCount, tokenType, INTvalue))
    else:
        echo "Error in lexer"


proc atEnd(lexer: Lexer): bool = ## Checks if lexer is at the end of the file
    return (lexer.currentPos >= lexer.source.len)

proc advance(lexer: var Lexer): char {.discardable.} = ## Advances the lexer by one character and returns the next character
    lexer.currentPos.inc
    return lexer.source[lexer.currentPos - 1]

proc peek(lexer: Lexer): char = ## looks at the next character without
    if (lexer.atEnd()):
        return '\0'
    return lexer.source[lexer.currentPos]

proc scanString(lexer: var Lexer) =
    while (not lexer.atEnd and lexer.peek != '"'):
        lexer.advance()

    if lexer.atEnd:
        echo "Error unfinished string"

    lexer.advance()
    lexer.addToken(STRING, lexer.source[lexer.startPos .. lexer.currentPos])


proc scanToken(lexer: var Lexer) = ## scans and extracts a single token from the source
    let c: char = lexer.advance()
    case c:
    of '\n':
        lexer.addToken(EOL)
        lexer.lineCount.inc
    of '+':
        lexer.addToken(PLUS)
    of '-':
        lexer.addToken(MINUS)
    of '*':
        lexer.addToken(TIMES)
    of '/':
        lexer.addToken(DIVIDE)
    of '<':
        lexer.addToken(LESS)
    of '>':
        lexer.addToken(GREATER)
    of '=':
        lexer.addToken(EQUAL)
    of ',':
        lexer.addToken(COMMA)
    of '\r', '\t', ' ':
        discard
    of '"':
        lexer.scanString()
    else:
        if isDigit(c):
            lexer.addToken(DIGIT, int(c))
        lexer.addToken(STRING, lexer.source)

proc scanTokens*(lexer: var Lexer): seq[Token] {.discardable.} = ## Loops through the source and scans all tokens
    while(not lexer.atEnd()):
        lexer.startPos = lexer.currentPos
        lexer.scanToken()

    lexer.tokens.add(newToken(lexer.lineCount + 1, EOF))
    return lexer.tokens

proc print*(lexer: Lexer) = ## Prints all tokens stored in the lexer.tokens sequence
    for token in lexer.tokens:
        echo $token
