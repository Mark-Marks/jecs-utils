--!nocheck
local process = require("@lune/process")

local function start_process(cmd: string)
    local arguments = string.split(cmd, " ")
    local command = arguments[1]
    table.remove(arguments, 1)

    process.spawn(command, arguments, { stdio = "forward" })
end

start_process("lune run analyze")
start_process("stylua lib/")
start_process("selene lib/")
start_process("luau test/tests.luau")
