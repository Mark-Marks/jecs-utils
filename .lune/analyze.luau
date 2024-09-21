--!nocheck
local process = require("@lune/process")

local function start_process(cmd: string)
    local arguments = string.split(cmd, " ")
    local command = arguments[1]
    table.remove(arguments, 1)

    process.spawn(command, arguments, { stdio = "forward" })
end

start_process("rojo sourcemap dev.project.json -o sourcemap.json")
start_process(
    "luau-lsp analyze --base-luaurc=.luaurc --sourcemap=sourcemap.json --settings=luau_lsp_settings.json --no-strict-dm-types --ignore Packages/**/*.lua --ignore Packages/**/*.luau --ignore lib/jecs.luau lib/"
)
