import ../src/TinyCoordinator

proc runBasic*(rawCode: cstring) {.exportc.} =
  let code = $rawCode & '\n'

  runFile(code)
