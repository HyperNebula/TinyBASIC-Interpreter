import std/os

import TinyBASIC

let args = commandLineParams()
var source: string

if args.len > 1:
    echo "Usage: TinyBASIC [source]"
    quit()
elif args.len == 1:
    runFile(args[0])
else:
    runLine()
