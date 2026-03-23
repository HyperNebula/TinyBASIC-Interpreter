import std/strutils

import types/Token

type
    Lexer* = object
        source: string
        lineCount: int = 1
        currentPos: int = 0
        startPos: int = 0
        linePos: int = 0
        hasError*: bool = false
        tokens: seq[Token]


proc setSource*(lexer: var Lexer, source: string) = ## Used to set the source for the lexer
    lexer.source = source

    lexer.currentPos = 0
    lexer.startPos = 0
    lexer.linePos = 0
    lexer.hasError = false


proc addToken(lexer: var Lexer, tokenType: TokenType) = ## addToken procs to create tokens and then add it to the token sequence
    lexer.tokens.add(newToken(lexer.lineCount, tokenType))

proc addToken(lexer: var Lexer, tokenType: TokenType, STRvalue: string) = ## Adds STRING token to lexer tokens sequence
    lexer.tokens.add(newToken(lexer.lineCount, tokenType, STRvalue))

proc addToken(lexer: var Lexer, tokenType: TokenType, name: char) = ## Adds VAR token to lexer tokens sequence
    lexer.tokens.add(newToken(lexer.lineCount, tokenType, name))

proc addToken(lexer: var Lexer, tokenType: TokenType, INTvalue: int) = ## Adds NUMBER token to lexer tokens sequence
    lexer.tokens.add(newToken(lexer.lineCount, tokenType, INTvalue))

proc addToken(lexer: var Lexer, tokenType: TokenType, content: string, linePos: int) = ## Adds StringERROR or UnknownERROR tokens to lexer tokens sequence
    lexer.hasError = true # move this to parser eventually
    lexer.tokens.add(newToken(lexer.lineCount, tokenType, content, linePos))


proc atEnd(lexer: Lexer): bool = ## Checks if lexer is at the end of the file
    return (lexer.currentPos >= lexer.source.len)

proc advance(lexer: var Lexer): char {.discardable.} = ## Advances the lexer by one character and returns the next character
    lexer.currentPos.inc
    lexer.linePos.inc
    return lexer.source[lexer.currentPos - 1]

proc peek(lexer: Lexer): char = ## looks at the next character without
    if (lexer.atEnd()):
        return '\0'
    return lexer.source[lexer.currentPos]

proc scanString(lexer: var Lexer) = ## Tokenizes strings contained within quotation marks
    while (not lexer.atEnd and lexer.peek != '"'):
        lexer.advance()

    if lexer.atEnd:
        lexer.addToken(StringERROR, multiReplace($lexer.source[lexer.startPos .. lexer.currentPos-1], (Newlines, '\0')), lexer.linePos - (lexer.currentPos - lexer.startPos) + 1)
        return

    lexer.advance()
    lexer.addToken(STRING, lexer.source[lexer.startPos+1 .. lexer.currentPos-2])

proc scanNumber(lexer: var Lexer) = ## Tokenizes strings contained within quotation marks
    while (not lexer.atEnd and isDigit(lexer.peek)):
        lexer.advance()

    lexer.addToken(NUMBER, parseInt(lexer.source[lexer.startPos .. lexer.currentPos-1]))

proc scanIdentifier(lexer: var Lexer) =
    while (not lexer.atEnd and isAlphaAscii(lexer.peek)):
        lexer.advance()

    let text: string = lexer.source[lexer.startPos .. lexer.currentPos-1]
    case text:
    of "PRINT", "print":
        lexer.addToken(PRINT)
    of "IF", "if":
        lexer.addToken(IF)
    of "THEN", "then":
        lexer.addToken(THEN)
    of "GOTO", "goto":
        lexer.addToken(GOTO)
    of "INPUT", "input":
        lexer.addToken(INPUT)
    of "LET", "let":
        lexer.addToken(LET)
    of "GOSUB", "gosub":
        lexer.addToken(GOSUB)
    of "RETURN", "return":
        lexer.addToken(RETURN)
    of "CLEAR", "clear":
        lexer.addToken(CLEAR)
    of "LIST", "list":
        lexer.addToken(LIST)
    of "RUN", "run":
        lexer.addToken(RUN)
    of "END", "end":
        lexer.addToken(END)
    else:
        lexer.addToken(UnknownERROR, text, lexer.linePos - (lexer.currentPos - lexer.startPos) + 1)
        #raise UnknownTokenException.newException("Unknown token [$3] at line $1, position $2" %
        #    [$lexer.lineCount, $(lexer.linePos - (lexer.currentPos - lexer.startPos) + 1), $text])

proc scanToken(lexer: var Lexer) = ## scans and extracts a single token from the source
    let c: char = lexer.advance()
    case c:
    of '\n':
        lexer.addToken(EOL)
        lexer.lineCount.inc
        lexer.linePos = 0
    of '+':
        lexer.addToken(PLUS)
    of '-':
        lexer.addToken(MINUS)
    of '*':
        lexer.addToken(TIMES)
    of '/':
        lexer.addToken(DIVIDE)
    of '<':
        case lexer.peek:
        of '>':
            lexer.advance
            lexer.addToken(NOTEQUAL)
        of '=':
            lexer.advance
            lexer.addToken(LESSEQUAL)
        else:
            lexer.addToken(LESS)
    of '>':
        case lexer.peek:
        of '<':
            lexer.advance
            lexer.addToken(NOTEQUAL)
        of '=':
            lexer.advance
            lexer.addToken(GREATEREQUAL)
        else:
            lexer.addToken(GREATER)
    of '=':
        lexer.addToken(EQUAL)
    of ',':
        lexer.addToken(COMMA)
    of '(':
        lexer.addToken(LEFTPAREN)
    of ')':
        lexer.addToken(RIGHTPAREN)
    of '\r', '\t', ' ':
        discard
    of '"':
        lexer.scanString()
    else:
        if isDigit(c):
            lexer.scanNumber()
        elif isUpperAscii(c) and not isUpperAscii(lexer.peek):
            lexer.addToken(VAR, c)
        elif isAlphaAscii(c):
            lexer.scanIdentifier()
        else:
            lexer.addToken(UnknownERROR, $c, lexer.linePos)
            #raise UnknownTokenException.newException("Unknown token [$3] at line $1, position $2" %
            #    [$lexer.lineCount, $lexer.linePos, $c])

proc scanTokens*(lexer: var Lexer): seq[Token] {.discardable.} = ## Loops through the source and scans all tokens
    while(not lexer.atEnd()):
        lexer.startPos = lexer.currentPos
        lexer.scanToken()

    lexer.tokens.add(newToken(lexer.lineCount + 1, EOF))
    return lexer.tokens

proc print*(lexer: Lexer) = ## Prints all tokens stored in the lexer.tokens sequence
    for token in lexer.tokens:
        echo $token
