type
    TokenType* = enum
        PRINT, IF, GOTO, INPUT, LET, GOSUB, RETURN, CLEAR, LIST, RUN, END
        PLUS, MINUS, TIMES, DIVIDE, LESS, GREATER, EQUAL, COMMA
        VAR, DIGIT, STRING
        EOF
    Token* = object
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

proc `$`* (token: Token): string =
    var content: string

    case token.tokenType:
    of VAR:
        content = token.name
    of DIGIT:
        content = $token.INTvalue
    of STRING:
        content = token.STRvalue
    else:
        content = ""
    return "[" & $token.lineNum & "] " & $token.tokenType & content
