--!strict
local spawn = require("util/spawn")

spawn.start("rojo sourcemap dev.project.json -o sourcemap.json")
spawn.start(
    "luau-lsp analyze --base-luaurc=.luaurc --sourcemap=sourcemap.json --settings=luau_lsp_settings.json --no-strict-dm-types --ignore Packages/**/*.lua --ignore Packages/**/*.luau --ignore lib/jecs.luau lib/"
)
