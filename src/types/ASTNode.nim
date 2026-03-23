type
    OperatorKind* = enum
        opPLUS, opMINUS, opTIMES, opDIVIDE
        opLESS, opGREATER, opEQUAL, opGREATEREQUAL, opLESSEQUAL, opNOTEQUAL

    NodeKind* = enum
        nodeVAR, nodeNUMBER, nodeSTRING
        nodePRINT, nodeIF, nodeGOTO, nodeINPUT, nodeLET, nodeGOSUB, nodeRETURN, nodeCLEAR, nodeLIST, nodeRUN, nodeEND
        nodeUNARY, nodeBINARY
        nodeERROR

    ASTNode* = ref object
        case nodeKind*: NodeKind
        of nodeNUMBER:
            INTvalue*: int
        of nodeSTRING:
            STRvalue*: string
        of nodeVAR:
            VARname*: char

        of nodeBINARY:
            binLEFT*: ASTNode
            binOP*: OperatorKind
            binRIGHT*: ASTNode
        of nodeUNARY: # For (+|-) term rule
            unOP*: OperatorKind
            unOPERAND*: ASTNode

        of nodePRINT:
            EXPRlist*: seq[ASTNode] # While store ASTNode of kind nodeSTRING or expressions
        of nodeIF:
            condEXPRleft*: ASTNode
            condRELOP*: OperatorKind
            condEXPRright*: ASTNode
            condStatement*: ASTNode
        of nodeGOTO, nodeGOSUB:
            goEXPR*: ASTNode
        of nodeINPUT:
            VARlist*: seq[ASTNode] # While store ASTNode of kind nodeVAR
        of nodeLET:
            letVAR*: ASTNode # of nodeVAR
            letEXPR*: AstNode

        of nodeRETURN, nodeCLEAR, nodeLIST, nodeRUN, nodeEND, nodeERROR:
            discard

proc `$`* (opKind: OperatorKind): string =
    case opKind:
    of opPLUS:
        return "+"
    of opMINUS:
        return "-"
    of opTIMES:
        return "*"
    of opDIVIDE:
        return "/"
    of opLESS:
        return "<"
    of opGREATER:
        return ">"
    of opEQUAL:
        return "="
    of opGREATEREQUAL:
        return "<="
    of opLESSEQUAL:
        return ">="
    of opNOTEQUAL:
        return "!="

proc `$`* (astNode: ASTNode): string =
    var content: string = ": "

    case astNode.nodeKind:
    of nodeNUMBER:
        return $astNode.INTvalue
    of nodeSTRING:
        return astNode.STRvalue
    of nodeVAR:
        return $astNode.VARname

    of nodeBINARY:
        return ($astNode.binLeft & " " & $astNode.binOP & " " & $astNode.binRIGHT)
    of nodeUNARY:
        return ($astNode.unOP & $astNode.unOPERAND)

    of nodePRINT:
        content.add $astNode.EXPRlist
    of nodeIF:
        content.add ($astNode.condEXPRleft & " " & $astNode.condRELOP & " " & $astNode.condEXPRright & " THEN " & $astNode.condStatement)
    of nodeGOTO, nodeGOSUB:
        content.add $astNode.goEXPR
    of nodeINPUT:
        content.add $astNode.VARlist
    of nodeLET:
        content.add ($astNode.letVAR & " = " & $astNode.letEXPR)
    else:
        content = ""
    return $astNode.nodeKind & content
