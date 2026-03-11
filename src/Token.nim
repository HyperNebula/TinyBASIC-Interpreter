type
    TokenType* = enum ## Different possible token types
        PRINT, IF, GOTO, INPUT, LET, GOSUB, RETURN, CLEAR, LIST, RUN, END
        PLUS, MINUS, TIMES, DIVIDE, LESS, GREATER, EQUAL, COMMA
        VAR, DIGIT, STRING
        EOF
    Token* = object ## Token object that stores relevant info
        lineNum: int
        case tokenType: TokenType
        of VAR:
            name: string
        of DIGIT:
            INTvalue: int
        of STRING:
            STRvalue: string
        else:
            discard

## Generic newToken procedure that creates and returns a token
proc newToken* (lineNum: int, tokenType: TokenType): Token =
    return Token(lineNum: lineNum, tokenType: tokenType)

## String type newToken procedure that creates and returns either a VAR or STRING token
proc newToken* (lineNum: int, tokenType: TokenType, value: string): Token =
    if tokenType == VAR:
        return Token(lineNum: lineNum, tokenType: VAR, name: value)
    else:
        return Token(lineNum: lineNum, tokenType: STRING, STRvalue: value)

## Integer type newToken procecdure that creates and returns a DIGIT token
proc newToken* (lineNum: int, tokenType: TokenType, INTvalue: int): Token =
    return Token(lineNum: lineNum, tokenType: DIGIT, INTvalue: INTvalue)

proc `$`* (token: Token): string =
    var content: string = ": "

    case token.tokenType:
    of VAR:
        content.add token.name
    of DIGIT:
        content.add $token.INTvalue
    of STRING:
        content.add token.STRvalue
    else:
        content = ""
    return "[" & $token.lineNum & "] " & $token.tokenType & content
