import types/Token

type
    Parser* = object
        tokens: seq[Token]
        currentPos: int = 0
        hasError*: bool = false

proc setTokenList*(parser: var Parser, tokens: seq[Token]) =
    parser.tokens = tokens
