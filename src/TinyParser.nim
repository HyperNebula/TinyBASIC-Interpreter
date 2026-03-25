import types/Token, types/ASTNode, types/Error

type
    Parser* = object
        tokens: seq[Token]
        currentPos: int = 0
        AST: seq[ASTNode]
        errorBag: seq[Error]


proc hasError*(parser: Parser): bool =
    return parser.errorBag.len > 0

proc setTokenList*(parser: var Parser, tokens: seq[Token]) =
    parser.tokens = tokens

proc peek(parser: Parser): Token =
    if parser.currentPos >= parser.tokens.len:
        return Token(tokenType: EOF)
    return parser.tokens[parser.currentPos]

proc checkMatch(parser: Parser, checkTokenType: TokenType): bool = ## Checks if the current token in the tokens stream matches the inputed token type
    return (checkTokenType == parser.peek().tokenType)

proc checkMatch(parser: Parser, checkTokenTypes: varargs[TokenType]): bool = ## Checks if the current token in the tokens stream matches the inputed token type
    for type in checkTokenTypes:
        if parser.checkMatch(type):
            return true
    return false

proc advance(parser: var Parser) =
    if parser.currentPos > parser.tokens.len - 1:
        parser.errorBag.add Error(name: "UnexpectedEOF", msg: "Expected more tokens but file ended prematurely")
    else:
        parser.currentPos.inc()

proc atEnd(parser: Parser): bool =
    return parser.checkMatch(EOF)

proc continuePastEOL(parser: var Parser) =
    while (not parser.checkMatch(EOL, EOF)):
        parser.advance()

    if parser.checkMatch(EOL):
        parser.advance()

proc handleEOL(parser: var Parser) =
    if parser.checkMatch(EOL):
        parser.advance()
    elif parser.checkMatch(EOF):
        return
    else:
        parser.errorBag.add Error(name: "ExtraTokenError", msg: "at line " & $parser.peek().lineNum & " of type " & $parser.peek().tokenType)
        parser.continuePastEOL()

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


proc parseString(parser: var Parser): ASTNode =
    result = ASTNode(nodeKind: nodeSTRING, STRvalue: parser.peek().STRvalue)
    parser.advance()

proc parseVAR(parser: var Parser): ASTNode =
    if parser.checkMatch(VAR):
        let returnVAR = ASTNode(nodeKind: nodeVAR, VARname: parser.peek().name)
        parser.advance()
        return returnVAR
    else:
        return parser.handleError("ExpectedVARToken")

proc parseExpression(parser: var Parser): ASTNode

proc parseFactor(parser: var Parser): ASTNode =
    if parser.checkMatch(VAR):
        let returnNode = parser.parseVAR()
        return returnNode
    elif parser.checkMatch(NUMBER):
        let returnNode = ASTNode(nodeKind: nodeNUMBER, INTvalue: parser.peek().INTvalue)
        parser.advance()
        return returnNode
    elif parser.checkMatch(LEFTPAREN):
        parser.advance()
        let returnEXPR: ASTNode = parser.parseExpression()
        if parser.checkMatch(RIGHTPAREN):
            parser.advance()
            return returnEXPR
        else:
            return parser.handleError("MissingClossingParentheses")
    else:
        return parser.handleError("NotValidFactor")

proc parseTerm(parser: var Parser): ASTNode =
    result = parser.parseFactor()

    while parser.checkMatch(TIMES, DIVIDE):
        if parser.checkMatch(TIMES):
            parser.advance()
            result = ASTNode(nodeKind: nodeBINARY, binLEFT: result, binOP: opTIMES, binRIGHT: parser.parseFactor())
        elif parser.checkMatch(DIVIDE):
            parser.advance()
            result = ASTNode(nodeKind: nodeBINARY, binLEFT: result, binOP: opDIVIDE, binRIGHT: parser.parseFactor())

proc parseExpression(parser: var Parser): ASTNode =
    if parser.checkMatch(PLUS):
        parser.advance()
        result = ASTNode(nodeKind: nodeUNARY, unOP: opPLUS, unOPERAND: parser.parseTerm())
    elif parser.checkMatch(MINUS):
        parser.advance()
        result = ASTNode(nodeKind: nodeUNARY, unOP: opMINUS, unOPERAND: parser.parseTerm())
    elif parser.checkMatch(VAR, NUMBER, LEFTPAREN):
        result = parser.parseTerm()
    else:
        return parser.handleError("NotValidExpression")

    while parser.checkMatch(PLUS, MINUS):
        if parser.checkMatch(PLUS):
            parser.advance()
            result = ASTNode(nodeKind: nodeBINARY, binLEFT: result, binOP: opPLUS, binRIGHT: parser.parseTerm())
        elif parser.checkMatch(MINUS):
            parser.advance()
            result = ASTNode(nodeKind: nodeBINARY, binLEFT: result, binOP: opMINUS, binRIGHT: parser.parseTerm())

proc parseRelop(parser: var Parser): OperatorKind =
    if parser.checkMatch(LESS):
        parser.advance()
        return opLESS
    elif parser.checkMatch(GREATER):
        parser.advance()
        return opGREATER
    elif parser.checkMatch(GREATEREQUAL):
        parser.advance()
        return opGREATEREQUAL
    elif parser.checkMatch(LESSEQUAL):
        parser.advance()
        return opLESSEQUAL
    elif parser.checkMatch(NOTEQUAL):
        parser.advance()
        return opNOTEQUAL
    elif parser.checkMatch(EQUAL):
        parser.advance()
        return opEQUAL
    else:
        discard parser.handleError("NotRELOPoperator")
        return opERROR

proc parseVARList(parser: var Parser): seq[ASTNode] =
    result.add(parser.parseVAR())

    while parser.checkMatch(COMMA):
        parser.advance()
        result.add(parser.parseVAR())

proc parseEXPRList(parser: var Parser): seq[ASTNode] =
    if (parser.checkMatch(COMMA)):
        parser.advance()
        if (parser.checkMatch(STRING)):
            return @[parser.parseString()] & parser.parseEXPRList()
        elif (parser.checkMatch(PLUS, MINUS, VAR, NUMBER, LEFTPAREN)):
            return @[parser.parseExpression()] & parser.parseEXPRList()
        else:
            return @[parser.handleError("MissingExpressionOrString")]
    elif (parser.checkMatch(EOL)):
        return @[]
    else:
        return @[parser.handleError("MissingExpectedComma")]

proc parsePRINT(parser: var Parser): ASTNode =
    if (parser.checkMatch(STRING)):
        return ASTNode(nodeKind: nodePRINT,
            EXPRlist:  @[parser.parseString()] & parser.parseEXPRList())
    elif (parser.checkMatch(PLUS, MINUS, VAR, NUMBER, LEFTPAREN)):
        return ASTNode(nodeKind: nodePRINT,
            EXPRlist:  @[parser.parseExpression()] & parser.parseEXPRList())
    else:
         return parser.handleError("NonPrintableToken")

proc parseStatement(parser: var Parser): ASTNode

proc parseIF(parser: var Parser): ASTNode =
    var
        leftEXPR, rightEXPR: ASTNode
        relop: OperatorKind

    leftEXPR = parser.parseExpression()

    relop = parser.parseRelop()

    rightEXPR = parser.parseExpression()

    if (parser.checkMatch(THEN)):
        parser.advance()
    else:
        return parser.handleError("MissingTHENtoken")

    let statement: ASTNode = parser.parseStatement()

    return ASTNode(nodeKind: nodeIF, condEXPRleft: leftEXPR, condRELOP: relop, condEXPRright: rightEXPR, condStatement: statement)

proc parseLET(parser: var Parser): ASTNode =
    let varReturn = parser.parseVAR()

    if parser.checkMatch(EQUAL):
        parser.advance()
    else:
        return parser.handleError("MissingEQUALtoken")

    let exprReturn = parser.parseExpression()

    return ASTNode(nodeKind: nodeLET, letVAR: varReturn, letEXPR: exprReturn)

proc parseStatement(parser: var Parser): ASTNode =
    if parser.checkMatch(EOF):
        return
    elif parser.checkMatch(EOL):
        return ASTNode(nodeKind: nodeEOL)
    elif parser.checkMatch(PRINT):
        parser.advance()
        return parser.parsePRINT()
    elif parser.checkMatch(IF):
        parser.advance()
        return parser.parseIF()
    elif parser.checkMatch(GOTO):
        parser.advance()
        return ASTNode(nodeKind: nodeGOTO, goEXPR: parser.parseExpression())
    elif parser.checkMatch(INPUT):
        parser.advance()
        return ASTNode(nodeKind: nodeINPUT, VARlist: parser.parseVARList())
    elif parser.checkMatch(LET):
        parser.advance()
        return parser.parseLET()
    elif parser.checkMatch(GOSUB):
        parser.advance()
        return ASTNode(nodeKind: nodeGOSUB, goEXPR: parser.parseExpression())
    elif parser.checkMatch(RETURN):
        return ASTNode(nodeKind: nodeRETURN)
    elif parser.checkMatch(CLEAR):
        return ASTNode(nodeKind: nodeCLEAR)
    elif parser.checkMatch(LIST):
        return ASTNode(nodeKind: nodeLIST)
    elif parser.checkMatch(RUN):
        return ASTNode(nodeKind: nodeRUN)
    elif parser.checkMatch(END):
        return ASTNode(nodeKind: nodeEND)
    else:
        parser.handleError("UnknownToken")


proc parseTokens*(parser: var Parser): seq[ASTNode] {.discardable.} =
    while (not parser.atEnd()):
        result.add parser.parseStatement()
        parser.handleEOL()

    parser.AST = result


proc print*(parser: Parser) = ## Prints all ASTNodes stored in the Parser.AST sequence
    for astNode in parser.AST:
        echo $astNode

proc printERRORS*(parser: Parser) =
    for error in parser.errorBag:
        echo $error
