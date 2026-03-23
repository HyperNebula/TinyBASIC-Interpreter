import types/Token, types/ASTNode

type
    Parser* = object
        tokens: seq[Token]
        currentPos: int = 0
        hasError*: bool = false

proc setTokenList*(parser: var Parser, tokens: seq[Token]) =
    parser.tokens = tokens

proc testPrint*(): string =
    let testExpression: ASTNode = ASTNode(nodeKind: nodeNumber, INTvalue: 5)

    return $testExpression
