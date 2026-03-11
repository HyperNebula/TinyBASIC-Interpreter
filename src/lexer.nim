type
    Lexer = object
        source: string

proc print(lexer: Lexer) = 
    echo lexer.source

        
var lexer: Lexer = Lexer(source: readLine(stdin))

lexer.print