type
    OperatorKind = enum
        opPLUS, opMINUS, opTIMES, opDIVIDE
        opLESS, opGREATER, opEQUAL, opGREATEREQUAL, opLESSEQUAL, opNOTEQUAL

    NodeKind = enum
        nodeVAR, nodeNUMBER, nodeSTRING
        nodePRINT, nodeIF, nodeGOTO, nodeINPUT, nodeLET, nodeGOSUB, nodeRETURN, nodeCLEAR, nodeLIST, nodeRUN, nodeEND
        nodeEXPR, nodeTERM, nodeFACTOR

    ASTNode* = ref object
        case kind: NodeKind
        of nodeNUMBER:
            INTvalue: int
        of nodeSTRING:
            STRvalue: string
        of nodeVAR:
            VARname: char
            
        of nodeFACTOR:
            FACTOR: ASTNode # Will be var, number, or expression

        of nodePRINT:
            EXPRlist: seq[ASTNode] # While store ASTNode of kind nodeSTRING or expressions
        of nodeIF:
            condEXPRleft: ASTNode
            condRELOP: OperatorKind
            condEXPRright: ASTNode
            condStatement: ASTNode
        of nodeGOTO, nodeGOSUB:
            goStatement: ASTNode
        of nodeINPUT:
            VARlist: seq[ASTNode] # While store ASTNode of kind nodeVAR
        of nodeLET:
            letVAR: ASTNode # of nodeVAR
            letEXPR: AstNode

        of nodeRETURN, nodeCLEAR, nodeLIST, nodeRUN, nodeEND:
            discard
