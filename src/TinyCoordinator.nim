import TinyLexer, TinyParser, TinyEvaluator, types/Token, types/ASTNode
import std/strutils

proc run(source: string) =
    var
        lexer: TinyLexer.Lexer = TinyLexer.Lexer()
        parser: TinyParser.Parser = TinyParser.Parser()
        evaluator: TinyEvaluator.Evaluator = TinyEvaluator.Evaluator()

    lexer.setSource(source)
    var tokens: seq[Token] = lexer.scanTokens()

    parser.setTokenList(tokens)
    var ast: seq[ASTNode] = parser.parseTokens()

    if (parser.hasError()):
        echo "\nERRORS:"
        parser.printERRORS()
        return

    evaluator.setAST(ast)
    evaluator.eval()

    evaluator.setAST(@[])


proc runFile*(fileName: string) {.exportc.} =
    run(fileName)

proc runLine*(commandStored: var string, source: string) =
    case source.toLowerAscii:
    of "exit":
        when defined(js):
            commandStored = ""
            echo "Session terminated."
            return
        else:
            quit(0)
    of "clear":
        commandStored = ""
    of "list":
        echo commandStored
    of "run":
        run(commandStored)
        commandStored = ""
    else:
        var
            tempCommandStored = commandStored & source & $'\n'
            TEMPlexer: TinyLexer.Lexer = TinyLexer.Lexer()
            TEMPparser: TinyParser.Parser = TinyParser.Parser()

        TEMPlexer.setSource(tempCommandStored)
        var tokens: seq[Token] = TEMPlexer.scanTokens()

        TEMPparser.setTokenList(tokens)
        discard TEMPparser.parseTokens()

        if (TEMPparser.hasError()):
            TEMPparser.printERRORS()
        else:
            commandStored.add source & $'\n'
