import types/ASTNode
import std/tables, std/strutils

type
    Evaluator* = object
        AST: seq[ASTNode]
        currentLinePos: int = 0
        varList = initTable[char, int]()
        returnStack: seq[int]

proc setAST*(eval: var Evaluator, ast: seq[ASTNode]) =
    eval.AST = ast
    eval.currentLinePos = 0
    eval.varList = initTable[char, int]()
    eval.returnStack = @[]

    for letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
        eval.varList[letter] = 0

proc isInt(input: string): bool =
    try:
        discard parseInt(input)
        return true
    except ValueError:
        return false

proc evalVar(eval: var Evaluator, astNode: ASTNode): int =
    return eval.varList[astNode.VARname]

proc evalNumber(eval: var Evaluator, astNode: ASTNode): int =
    return astNode.INTvalue

proc evalString(eval: var Evaluator, astNode: ASTNode): string =
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
            result.add eval.evalString(expr)
        else:
            result.add($eval.evalEXPR(expr))

proc evalLine(eval: var Evaluator, astNode: ASTNode) =
    case astNode.nodeKind:
    of nodePRINT:
        for expr in eval.evalEXPRlist(astNode.EXPRlist):
            echo $expr
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
    of nodeGOTO:
        eval.currentLinePos = eval.evalEXPR(astNode.goEXPR) - 2
    of nodeGOSUB:
        eval.returnStack.add(eval.currentLinePos)
        eval.currentLinePos = eval.evalEXPR(astNode.goEXPR) - 2
    of nodeRETURN:
        if eval.returnStack.len > 0:
            eval.currentLinePos = eval.returnStack.pop()
    of nodeLET:
        eval.varList[astNode.letVAR.VARname] = eval.evalEXPR(astNode.letEXPR)
    of nodeINPUT:
        for tempVar in astNode.VARlist:
            var varVal = ""
            while (not isInt(varVal)):
                stdout.write("? ")
                varVal = readLine(stdin)

            eval.varList[tempVar.VARname] = parseInt(varVal)

    of nodeEOL:
        discard
    of nodeEND:
        eval.currentLinePos = eval.AST.len
    of nodeRUN:
        eval.currentLinePos = 0
    of nodeLIST:
        echo $eval.AST
    else:
        echo "ERROR: Unknown token"


proc eval*(eval: var Evaluator) =
    while eval.currentLinePos < eval.AST.len:
        eval.evalLine(eval.AST[eval.currentLinePos])
        eval.currentLinePos += 1
