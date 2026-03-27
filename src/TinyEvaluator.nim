import types/ASTNode

type
    Evaluator* = object
        AST: seq[ASTNode]
        currentLinePos: int = 0
        varList: seq[tuple[name: char, value: int]]


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

proc evalFactor(eval: var Evaluator, astNode: ASTNode): int =
    if astNode.nodeKind == nodeVAR:
        return eval.evalVar(astNode)
    elif astNode.nodeKind == nodeNUMBER:
        return eval.evalNumber(astNode)
    elif astNode.nodeKind == nodeGROUPING:
        return eval.evalEXPR(astNode.groupEXPR)
    else:
        echo "ERROR"

proc evalUnary(eval: var Evaluator, astNode: ASTNode): int =
    return

proc evalBinary(eval: var Evaluator, astNode: ASTNode): int =
    return

proc evalEXPR(eval: var Evaluator, astNode: ASTNode): int =
    return

proc evalEXPRlist(eval: var Evaluator): string =
    return

proc evalLine(eval: var Evaluator) =
    case eval.AST[eval.currentLinePos].nodeKind:
    of nodePRINT:
        return
    else:
         echo "ERROR"
