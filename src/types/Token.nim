type
    TokenType* = enum ## Different possible token types
        PRINT, IF, THEN, GOTO, INPUT, LET, GOSUB, RETURN, CLEAR, LIST, RUN, END
        PLUS, MINUS, TIMES, DIVIDE, LESS, GREATER, EQUAL, GREATEREQUAL, LESSEQUAL, NOTEQUAL
        COMMA, LEFTPAREN, RIGHTPAREN
        VAR, NUMBER, STRING
        EOF, EOL
        UnknownERROR, StringERROR
    Token* = object ## Token object that stores relevant info
        lineNum*: int
        case tokenType*: TokenType
        of VAR:
            name*: char
        of NUMBER:
            INTvalue*: int
        of STRING:
            STRvalue*: string
        of StringERROR, UnknownERROR:
            content*: string
            linePos*: int
        else:
            discard


proc newToken* (lineNum: int, tokenType: TokenType): Token = ## Generic newToken procedure that creates and returns a token
    return Token(lineNum: lineNum, tokenType: tokenType)

proc newToken* (lineNum: int, tokenType: TokenType, STRvalue: string): Token = ## String type newToken procedure that creates and returns a STRING token
    return Token(lineNum: lineNum, tokenType: STRING, STRvalue: STRvalue)

proc newToken* (lineNum: int, tokenType: TokenType, name: char): Token = ## String type newToken procedure that creates and returns a VAR token
    return Token(lineNum: lineNum, tokenType: VAR, name: name)

proc newToken* (lineNum: int, tokenType: TokenType, INTvalue: int): Token = ## Integer type newToken procecdure that creates and returns a NUMBER token
    return Token(lineNum: lineNum, tokenType: NUMBER, INTvalue: INTvalue)

proc newToken* (lineNum: int, tokenType: TokenType, content: string, linePos: int): Token = ## Integer type newToken procecdure that creates and returns a ERROR token
    if tokenType == StringERROR:
        return Token(lineNum: lineNum, tokenType: StringERROR, content: content, linePos: linePos)
    else:
        return Token(lineNum: lineNum, tokenType: UnknownERROR, content: content, linePos: linePos)

# proc to convert tokens to strings
proc `$`* (token: Token): string =
    var content: string = ": "

    case token.tokenType:
    of VAR:
        content.add token.name
    of NUMBER:
        content.add $token.INTvalue
    of STRING:
        content.add token.STRvalue
    of StringERROR, UnknownERROR:
        content.add "Error (" & token.content & ") at position " & $token.linePos
    else:
        content = ""
    return "[" & $token.lineNum & "] " & $token.tokenType & content
