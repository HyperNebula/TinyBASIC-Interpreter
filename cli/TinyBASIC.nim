import std/os

import ../src/TinyCoordinator

let args = commandLineParams()

if args.len > 1:
    echo "Usage: TinyBASIC [source]"
    quit(2)
elif args.len == 1:
    runFile(readFile(args[0]))
else:
    var commandStored: string = ""
    while (true):
        stdout.write("> ")
        let source = readLine(stdin)
        runLine(commandStored, source)
