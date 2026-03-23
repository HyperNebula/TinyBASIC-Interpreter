import types/Token, types/ASTNode, types/Error

type
    Parser* = object
        tokens: seq[Token]
        currentPos: int = 0
        AST*: seq[ASTNode]
        errorBag*: seq[Error]


proc setTokenList*(parser: var Parser, tokens: seq[Token]) =
    parser.tokens = tokens

proc peek(parser: Parser): Token =
    return parser.tokens[parser.currentPos]

proc checkMatch(parser: Parser, checkTokenType: TokenType): bool = ## Checks if the current token in the tokens stream matches the inputed token type
    return (checkTokenType == parser.peek().tokenType)

proc advance(parser: var Parser) =
    parser.currentPos.inc()

proc atEnd(parser: Parser): bool =
    return (parser.peek().tokenType == EOF)

proc handleErrorToken(parser: var Parser) =
    let tempToken = parser.peek()
    if (parser.checkMatch(StringERROR)):
        parser.errorBag.add Error(name: "UnterminatedStringError", msg: "at line " & $tempToken.lineNum & " [" & tempToken.content & "]")
    elif (parser.checkMatch(UnknownERROR)):
        parser.errorBag.add Error(name: "UnknownTokenError", msg: "at line " & $tempToken.lineNum & " [" & tempToken.content & "]")




proc print*(parser: Parser) = ## Prints all ASTNodes stored in the Parser.AST sequence
    for astNode in parser.AST:
        echo $astNode
