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

proc continuePastEOL(parser: var Parser) =
    while (not parser.checkMatch(EOL, EOF)):
        parser.advance()
    parser.advance()

proc handleEOL(parser: var Parser) =
    if not parser.checkMatch(EOL):
        parser.errorBag.add Error(name: "ExtraTokenError", msg: "at line " & $parser.peek().lineNum & " of type " & $parser.peek().tokenType)
        parser.continuePastEOL()
    else:
        parser.advance()

proc handleErrorToken(parser: var Parser): ASTNode =
    let tempToken = parser.peek()
    var errorName: string
    if (parser.checkMatch(StringERROR)):
        errorName = "UnterminatedStringError"
    elif (parser.checkMatch(UnknownERROR)):
        errorName = "UnknownTokenError"

    parser.errorBag.add Error(name: errorName, msg: "at line " & $tempToken.lineNum & " [" & tempToken.content & "]")
    parser.continuePastEOL()
    return ASTNode(nodeKIND: nodeERROR, errorMSG: errorName)

proc handleError(parser: var Parser, errorName: string): ASTNode =
    if (parser.checkMatch(StringERROR, UnknownERROR)):
        return parser.handleErrorToken()
    else:
        parser.errorBag.add Error(name: errorName, msg: "at line " & $parser.peek().lineNum & " of type " & $parser.peek().tokenType)
        parser.continuePastEOL()
        return ASTNode(nodeKIND: nodeERROR, errorMSG: errorName)


proc parseRelop(parser: var Parser): OperatorKind =
    if (parser.checkMatch(LESS, GREATER, EQUAL, GREATEREQUAL, LESSEQUAL, NOTEQUAL)):
        return opLESS

proc parseString(parser: var Parser): ASTNode =
    return ASTNode(nodeKind: nodeSTRING, STRvalue: parser.peek().STRvalue)

proc parseExpression(parser: var Parser): ASTNode =
    return ASTNode(nodeKind: nodeNUMBER) # TEMP

proc parseEXPRList(parser: var Parser): seq[ASTNode] =
    parser.advance()
    if (parser.checkMatch(COMMA)):
        parser.advance()
        if (parser.checkMatch(STRING)):
            return @[ASTNode(nodeKind: nodeSTRING, STRvalue: parser.peek().STRvalue)] & parser.parseEXPRList()
        elif (parser.checkMatch(PLUS, MINUS, VAR, NUMBER, LEFTPAREN)):
            return @[parser.parseExpression()] & parser.parseEXPRList()
        else:
            return @[parser.handleError("MissingExpressionOrString")]
    elif (parser.checkMatch(EOL)):
        return @[]
    else:
        return @[parser.handleError("MissingExpectedComma")]

proc parsePrint(parser: var Parser): ASTNode =
    parser.advance()

    if (parser.checkMatch(STRING)):
        return ASTNode(nodeKind: nodePRINT,
            EXPRlist:  @[parser.parseString()] & parser.parseEXPRList())
    elif (parser.checkMatch(PLUS, MINUS, VAR, NUMBER, LEFTPAREN)):
        return ASTNode(nodeKind: nodePRINT,
            EXPRlist:  @[parser.parseExpression()] & parser.parseEXPRList())
    else:
         return parser.handleError("NonExpressionToken")

proc parseStatement(parser: var Parser): ASTNode

proc parseIF(parser: var Parser): ASTNODE =
    parser.advance()

    var
        leftEXPR, rightEXPR: ASTNode
        relop: OperatorKind

    if (parser.checkMatch(PLUS, MINUS, VAR, NUMBER, LEFTPAREN)):
        leftEXPR = parser.parseExpression()
        parser.advance()
    else:
        return parser.handleError("NonExpressionToken")

    if (parser.checkMatch(LESS, GREATER, EQUAL, GREATEREQUAL, LESSEQUAL, NOTEQUAL)):
        relop = parser.parseRelop()
        parser.advance()
    else:
        return parser.handleError("NotRELOPoperator")

    if (parser.checkMatch(PLUS, MINUS, VAR, NUMBER, LEFTPAREN)):
        rightEXPR = parser.parseExpression()
        parser.advance()
    else:
        return parser.handleError("NonExpressionToken")

    if (parser.checkMatch(THEN)):
        parser.advance()
    else:
        return parser.handleError("MissingTHENtoken")

    let statement: ASTNode = parser.parseStatement()

    parser.advance()

    return ASTNode(nodeKind: nodeIF, condEXPRleft: leftEXPR, condRELOP: relop, condEXPRright: rightEXPR, condStatement: statement)


proc parseStatement(parser: var Parser): ASTNode =
    var returnAstNode: ASTNode = ASTNode(nodeKind: nodeERROR)
    if (parser.checkMatch(EOL)):
        parser.advance()
        return ASTNode(nodeKind: nodeEOL)
    elif (parser.checkMatch(PRINT)):
        return parser.parsePrint()
    elif (parser.checkMatch(IF)):
        return parser.parseIF()

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
