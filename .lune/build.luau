--!nocheck
local process = require("@lune/process")

local function start_process(cmd: string, env: { string }?)
    local arguments = string.split(cmd, " ")
    local command = arguments[1]
    table.remove(arguments, 1)

    process.spawn(command, arguments, { stdio = "forward", env = env })
end

start_process("rojo sourcemap dev.project.json -o sourcemap.json")
start_process("darklua process --config .darklua.json lib/ dist/", { "ROBLOX_DEV=false" })
start_process("rojo build build.project.json -o build.rbxm")
