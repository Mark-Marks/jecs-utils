--!strict
local spawn = require("util/spawn")

spawn.start("wally install")
spawn.start("rojo sourcemap dev.project.json -o sourcemap.json")
spawn.start("wally-package-types --sourcemap sourcemap.json Packages/")
