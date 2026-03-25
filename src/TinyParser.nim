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
    if parser.currentPos > parser.tokens.len:
        parser.errorBag.add Error(name: "UnexpectedEOF", msg: "Expected more tokens but file ended prematurely")
    else:
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



proc parseExpression(parser: var Parser): ASTNode

proc parseFactor(parser: var Parser): ASTNode =
    if parser.checkMatch(VAR):
        let returnNode = ASTNode(nodeKind: nodeVAR, VARname: parser.peek().name)
        parser.advance()
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
    var returnTerm: ASTNode = parser.parseFactor()

    while parser.checkMatch(TIMES, DIVIDE):
        if parser.checkMatch(TIMES):
            parser.advance()
            returnTerm = ASTNode(nodeKind: nodeBINARY, binLEFT: returnTerm, binOP: opTIMES, binRIGHT: parser.parseFactor())
        elif parser.checkMatch(DIVIDE):
            parser.advance()
            returnTerm = ASTNode(nodeKind: nodeBINARY, binLEFT: returnTerm, binOP: opDIVIDE, binRIGHT: parser.parseFactor())

    return returnTerm

proc parseExpression(parser: var Parser): ASTNode =
    var returnEXPR: ASTNode

    if parser.checkMatch(PLUS):
        parser.advance()
        returnEXPR = ASTNode(nodeKind: nodeUNARY, unOP: opPLUS, unOPERAND: parser.parseTerm())
    elif parser.checkMatch(MINUS):
        parser.advance()
        returnEXPR = ASTNode(nodeKind: nodeUNARY, unOP: opMINUS, unOPERAND: parser.parseTerm())
    elif parser.checkMatch(VAR, NUMBER, LEFTPAREN):
        returnEXPR = parser.parseTerm()
    else:
        return parser.handleError("NotValidExpression")

    while parser.checkMatch(PLUS, MINUS):
        if parser.checkMatch(PLUS):
            parser.advance()
            returnEXPR = ASTNode(nodeKind: nodeBINARY, binLEFT: returnEXPR, binOP: opPLUS, binRIGHT: parser.parseTerm())
        elif parser.checkMatch(MINUS):
            parser.advance()
            returnEXPR = ASTNode(nodeKind: nodeBINARY, binLEFT: returnEXPR, binOP: opMINUS, binRIGHT: parser.parseTerm())

    return returnEXPR

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

proc parseString(parser: var Parser): ASTNode =
    let returnString = ASTNode(nodeKind: nodeSTRING, STRvalue: parser.peek().STRvalue)
    parser.advance()
    return returnString

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

proc parsePrint(parser: var Parser): ASTNode =
    if (parser.checkMatch(STRING)):
        return ASTNode(nodeKind: nodePRINT,
            EXPRlist:  @[parser.parseString()] & parser.parseEXPRList())
    elif (parser.checkMatch(PLUS, MINUS, VAR, NUMBER, LEFTPAREN)):
        return ASTNode(nodeKind: nodePRINT,
            EXPRlist:  @[parser.parseExpression()] & parser.parseEXPRList())
    else:
         return parser.handleError("NonPrintableToken")

proc parseStatement(parser: var Parser): ASTNode

proc parseIF(parser: var Parser): ASTNODE =
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


proc parseStatement(parser: var Parser): ASTNode =
    var returnAstNode: ASTNode = ASTNode(nodeKind: nodeERROR)
    if (parser.checkMatch(EOL)):
        parser.advance()
        return ASTNode(nodeKind: nodeEOL)
    elif (parser.checkMatch(PRINT)):
        parser.advance()
        return parser.parsePrint()
    elif (parser.checkMatch(IF)):
        parser.advance()
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
