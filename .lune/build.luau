--!strict
local spawn = require("util/spawn")

spawn.start("rojo sourcemap dev.project.json -o sourcemap.json")
spawn.start("darklua process --config .darklua.json lib/ dist/", { env = { ROBLOX_DEV = "false" } })
spawn.start("rojo build build.project.json -o build.rbxm")
