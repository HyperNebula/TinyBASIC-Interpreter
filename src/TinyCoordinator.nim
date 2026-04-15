import TinyLexer, TinyParser, TinyEvaluator, types/Token, types/ASTNode
import std/strutils

var
    lexer: TinyLexer.Lexer = TinyLexer.Lexer()
    parser: TinyParser.Parser = TinyParser.Parser()
    evaluator: TinyEvaluator.Evaluator = TinyEvaluator.Evaluator()

proc run(source: string) =
    lexer.setSource(source)
    var tokens: seq[Token] = lexer.scanTokens()

    parser.setTokenList(tokens)
    var ast: seq[ASTNode] = parser.parseTokens()

    echo "\nTOKENS:"
    lexer.print()

    echo "\nTREE:"
    parser.print()

    if (parser.hasError()):
        echo "\nERRORS:"
        parser.printERRORS()
        return

    echo "\nEvaluated:"
    evaluator.setAST(ast)
    evaluator.eval()


proc runFile*(fileName: string) =
    run(readFile(fileName))
    if (parser.hasError()):
        echo "\nERRORS:"
        parser.printERRORS()
        quit(65)

proc runLine*() =
    var commandStored: string = ""
    while (true):
        stdout.write("> ")
        let source = readLine(stdin)

        case source.toLowerAscii:
        of "exit":
            break
        of "clear":
            commandStored = ""
        of "list":
            echo $commandStored
        of "run":
            run(commandStored)
        else:
            commandStored.add source & $'\n'
