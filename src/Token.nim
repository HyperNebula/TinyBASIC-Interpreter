type
    TokenType* = enum ## Different possible token types
        PRINT, IF, GOTO, INPUT, LET, GOSUB, RETURN, CLEAR, LIST, RUN, END
        PLUS, MINUS, TIMES, DIVIDE, LESS, GREATER, EQUAL, COMMA
        VAR, DIGIT, STRING
        EOF, EOL
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


proc newToken* (lineNum: int, tokenType: TokenType): Token = ## Generic newToken procedure that creates and returns a token
    return Token(lineNum: lineNum, tokenType: tokenType)

proc newToken* (lineNum: int, tokenType: TokenType, value: string): Token = ## String type newToken procedure that creates and returns either a VAR or STRING token
    if tokenType == VAR:
        return Token(lineNum: lineNum, tokenType: VAR, name: value)
    elif tokenType == STRING:
        return Token(lineNum: lineNum, tokenType: STRING, STRvalue: value)
    else:
        echo "Error in token"

proc newToken* (lineNum: int, tokenType: TokenType, INTvalue: int): Token = ## Integer type newToken procecdure that creates and returns a DIGIT token
    return Token(lineNum: lineNum, tokenType: DIGIT, INTvalue: INTvalue)

# proc to convert tokens to strings
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
