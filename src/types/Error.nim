type
    Error* = object
        name: string
        msg: string

proc `$`* (error: Error): string =
    "Error: (" & error.name & ") " & error.msg
