import types/ASTNode

type
    Evaluator* = object
        AST: seq[ASTNode]
        currentLinePos: int = 0
        varList: seq[tuple[name: char, value: int]]

proc setAST*(eval: var Evaluator, ast: seq[ASTNode]) =
    eval.AST = ast
    eval.currentLinePos = 0
    eval.varList = @[]

proc evalVar(eval: var Evaluator, astNode: ASTNode): int =
    for varT in eval.varList:
        if varT.name == astNode.VARname:
            return varT.value
    echo "ERROR"

proc evalNumber(eval: var Evaluator, astNode: ASTNode): int =
    return astNode.INTvalue

proc evalSring(eval: var Evaluator, astNode: ASTNode): string =
    return astNode.STRvalue

proc evalEXPR(eval: var Evaluator, astNode: ASTNode): int

proc evalUnary(eval: var Evaluator, astNode: ASTNode): int =
    if astNode.unOP == opMINUS:
        return - eval.evalEXPR(astNode.unOPERAND)
    elif astNode.unOP == opPLUS:
        return eval.evalEXPR(astNode.unOPERAND)
    else:
        echo "ERROR"

proc evalBinary(eval: var Evaluator, astNode: ASTNode): int =
    if astNode.binOP == opPLUS:
        return eval.evalEXPR(astNode.binLEFT) + eval.evalEXPR(astNode.binRIGHT)
    elif astNode.binOP == opMINUS:
        return eval.evalEXPR(astNode.binLEFT) - eval.evalEXPR(astNode.binRIGHT)
    elif astNode.binOP == opTIMES:
        return eval.evalEXPR(astNode.binLEFT) * eval.evalEXPR(astNode.binRIGHT)
    elif astNode.binOP == opDIVIDE:
        return eval.evalEXPR(astNode.binLEFT) div eval.evalEXPR(astNode.binRIGHT)
    else:
        echo "ERROR"

proc evalEXPR(eval: var Evaluator, astNode: ASTNode): int =
    if astNode.nodeKind == nodeUNARY:
        return eval.evalUnary(astNode)
    elif astNode.nodeKind == nodeBINARY:
        return eval.evalBinary(astNode)
    elif astNode.nodeKind == nodeVAR:
        return eval.evalVar(astNode)
    elif astNode.nodeKind == nodeNUMBER:
        return eval.evalNumber(astNode)
    elif astNode.nodeKind == nodeGROUPING:
        return eval.evalEXPR(astNode.groupEXPR)
    else:
        echo "ERROR"

proc evalEXPRlist(eval: var Evaluator, astNodeList: seq[ASTNode]): seq[string] =
    for expr in astNodeList:
        if expr.nodeKind == nodeSTRING:
            result.add eval.evalSring(expr)
        else:
            result.add($eval.evalEXPR(expr))

proc evalLine(eval: var Evaluator, astNode: ASTNode) =
    case astNode.nodeKind:
    of nodePRINT:
        echo "PRINT: " & $eval.evalEXPRlist(astNode.EXPRlist)

        eval.currentLinePos += 1
    of nodeIF:
        case astNode.condRELOP:
        of opLESS:
            if eval.evalEXPR(astNode.condEXPRleft) < eval.evalEXPR(astNode.condEXPRright):
                eval.evalLine(astNode.condStatement)
        of opGREATER:
            if eval.evalEXPR(astNode.condEXPRleft) > eval.evalEXPR(astNode.condEXPRright):
                eval.evalLine(astNode.condStatement)
        of opLESSEQUAL:
            if eval.evalEXPR(astNode.condEXPRleft) <= eval.evalEXPR(astNode.condEXPRright):
                eval.evalLine(astNode.condStatement)
        of opGREATEREQUAL:
            if eval.evalEXPR(astNode.condEXPRleft) >= eval.evalEXPR(astNode.condEXPRright):
                eval.evalLine(astNode.condStatement)
        of opNOTEQUAL:
            if eval.evalEXPR(astNode.condEXPRleft) != eval.evalEXPR(astNode.condEXPRright):
                eval.evalLine(astNode.condStatement)
        of opEQUAL:
            if eval.evalEXPR(astNode.condEXPRleft) == eval.evalEXPR(astNode.condEXPRright):
                eval.evalLine(astNode.condStatement)
        else:
            echo "ERROR: Unknown RELOP"

        eval.currentLinePos += 1

    of nodeGOTO:
        eval.currentLinePos = eval.evalEXPR(astNode.goEXPR) - 1

    else:
        echo "ERROR: Unknown token"


proc eval*(eval: var Evaluator) =
    while eval.currentLinePos < eval.AST.len:
        eval.evalLine(eval.AST[eval.currentLinePos])
