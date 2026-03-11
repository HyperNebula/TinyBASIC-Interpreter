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
    while (true):
        stdout.write("> ")
        source = readLine(stdin)

        if (source == "" or source == "exit"):
            break

        runLine(source)
