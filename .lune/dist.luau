--!strict
local fs = require("@lune/fs")
local spawn = require("util/spawn")

spawn.start("rojo sourcemap dev.project.json -o sourcemap.json")
spawn.start("lune run install-packages")
spawn.start("darklua process --config .darklua.json lib/ dist/", { env = { ROBLOX_DEV = "false" } })

for _, path in fs.readDir("dist") do
    path = `dist/{path}`
    if not fs.isFile(path) then
        continue
    end

    print("found working file")

    local file = fs.readFile(path)
    local new_contents =
        string.gsub(file, `require%("%.%./jecs"%)`, `require(script.Parent.Parent:FindFirstChild('jecs'))`)
    fs.writeFile(path, new_contents)
end
