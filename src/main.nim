import std/os

import TinyBASIC

let args = commandLineParams()

if args.len > 1:
    echo "Usage: TinyBASIC [source]"
    quit(2)
elif args.len == 1:
    runFile(args[0])
else:
    runLine()
