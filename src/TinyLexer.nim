import Token

type
    Lexer* = object
        source: string
        lineCount: int = 1
        currentPos: int = 0
        startPos: int = 0
        tokens: seq[Token]

# used to set the source for the lexer
proc setSource*(lexer: var Lexer, source: string) =
    lexer.source = source


# addToken procs to create tokens and then add it to the token sequence
proc addToken(lexer: var Lexer, tokenType: TokenType) =
    lexer.tokens.add(newToken(lexer.lineCount, tokenType))

proc addToken(lexer: var Lexer, tokenType: TokenType, value: string) =
    if tokenType == STRING or tokenType == VAR:
        lexer.tokens.add(newToken(lexer.lineCount, tokenType, value))
    else:
        echo "Error in lexer"

proc addToken(lexer: var Lexer, tokenType: TokenType, INTvalue: int) =
    if tokenType == DIGIT:
        lexer.tokens.add(newToken(lexer.lineCount, tokenType, INTvalue))
    else:
        echo "Error in lexer"


# checks if lexer is at the end of the file
proc atEnd(lexer: Lexer): bool =
    return (lexer.currentPos >= lexer.source.len)

# scans and extracts a single token from the source
proc scanToken(lexer: var Lexer) =
    if (lexer.source[lexer.startPos .. lexer.currentPos] == "\n"):
        lexer.addToken(EOL)
        lexer.lineCount.inc
    lexer.addToken(STRING, lexer.source)

# loops through the source and scans all tokes
proc scanTokens*(lexer: var Lexer): seq[Token] =
    while(not lexer.atEnd()):
        lexer.startPos = lexer.currentPos
        lexer.scanToken()

    lexer.tokens.add(newToken(lexer.lineCount + 1, EOF))
    return lexer.tokens

# prints all tokens stored in the lexer.tokens sequence
proc print*(lexer: Lexer) =
    for token in lexer.tokens:
        echo $token
