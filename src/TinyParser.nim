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

proc checkMatch(parser: Parser, checkTokenTypes: varargs[TokenType]): bool = ## Checks if the current token in the tokens stream matches the inputed token type
    for type in checkTokenTypes:
        if parser.checkMatch(type):
            return true
    return false

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

proc handleEOL(parser: var Parser) =
    if not parser.checkMatch(EOL):
        parser.errorBag.add Error(name: "ExtraTokenError", msg: "at line " & $parser.peek().lineNum & " of type " & $parser.peek().tokenType)
    parser.advance()

proc continueUntilEOL(parser: var Parser) =
    while (not parser.checkMatch(EOL, EOF)):
        parser.advance()
    parser.advance()


proc parseString(parser: var Parser): ASTNode =
    return ASTNode(nodeKind: nodeSTRING, STRvalue: parser.peek().STRvalue)

proc parseExpression(parser: var Parser): ASTNode =
    return ASTNode()

proc parseEXPRList(parser: var Parser): seq[ASTNode] =
    parser.advance()
    if (parser.checkMatch(COMMA)):
        parser.advance()
        if (parser.checkMatch(STRING)):
            return @[ASTNode(nodeKind: nodeSTRING, STRvalue: parser.peek().STRvalue)] & parser.parseEXPRList()
        elif (parser.checkMatch(PLUS, MINUS, VAR, NUMBER, LEFTPAREN)):
            return @[parser.parseExpression()] & parser.parseEXPRList()
        else:
            parser.errorBag.add Error(name: "MissingExpressionOrString", msg: "at line " & $parser.peek().lineNum & ". Instead is type " & $parser.peek().tokenType)
            parser.continueUntilEOL()
            return @[]
    else:
        parser.errorBag.add Error(name: "MissingExpectedComma", msg: "at line " & $parser.peek().lineNum & ". Instead is type " & $parser.peek().tokenType)
        parser.continueUntilEOL()
        return @[]

proc parsePrint(parser: var Parser): ASTNode =
    parser.advance()

    if (parser.checkMatch(STRING)):
        return ASTNode(nodeKind: nodePRINT,
            EXPRlist:  @[parser.parseString()] & parser.parseEXPRList())
    elif (parser.checkMatch(PLUS, MINUS, VAR, NUMBER, LEFTPAREN)):
        return ASTNode(nodeKind: nodePRINT,
            EXPRlist:  @[parser.parseExpression()] & parser.parseEXPRList())
    else:
         parser.errorBag.add Error(name: "NonExpressionToken", msg: "at line " & $parser.peek().lineNum & " of type " & $parser.peek().tokenType)
         parser.continueUntilEOL()
         return ASTNode(nodeKIND: nodeERROR)

proc parseStatement(parser: var Parser): ASTNode =
    var returnAstNode: ASTNode = ASTNode(nodeKind: nodeERROR)
    if (parser.checkMatch(EOL)):
        parser.advance()
        return ASTNode(nodeKind: nodeEOL)
    elif (parser.checkMatch(PRINT)):
        return parser.parsePrint()

    parser.handleEOL()
    return returnAstNode

proc parseTokens*(parser: var Parser): seq[ASTNode] {.discardable.} =
    var returnSeq: seq[ASTNode]
    while (not parser.atEnd()):
        returnSeq.add parser.parseStatement()

    parser.AST = returnSeq
    return returnSeq


proc print*(parser: Parser) = ## Prints all ASTNodes stored in the Parser.AST sequence
    for astNode in parser.AST:
        echo $astNode
