type
    TokenType* = enum ## Different possible token types
        PRINT, IF, THEN, GOTO, INPUT, LET, GOSUB, RETURN, CLEAR, LIST, RUN, END
        PLUS, MINUS, TIMES, DIVIDE, LESS, GREATER, EQUAL, COMMA, GREATEREQUAL, LESSEQUAL, NOTEQUAL
        VAR, DIGIT, STRING
        EOF, EOL
    Token* = object ## Token object that stores relevant info
        lineNum: int
        case tokenType: TokenType
        of VAR:
            name: char
        of DIGIT:
            INTvalue: int
        of STRING:
            STRvalue: string
        else:
            discard
    UnknownTokenException* = object of CatchableError


proc newToken* (lineNum: int, tokenType: TokenType): Token = ## Generic newToken procedure that creates and returns a token
    return Token(lineNum: lineNum, tokenType: tokenType)

proc newToken* (lineNum: int, tokenType: TokenType, STRvalue: string): Token = ## String type newToken procedure that creates and returns a STRING token
    return Token(lineNum: lineNum, tokenType: STRING, STRvalue: STRvalue)

proc newToken* (lineNum: int, tokenType: TokenType, name: char): Token = ## String type newToken procedure that creates and returns a VAR token
    return Token(lineNum: lineNum, tokenType: VAR, name: name)

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
