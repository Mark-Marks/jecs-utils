--!strict
--!optimize 2
local jecs = require("./jecs")

local WORLD: jecs.World

local listeners: { (jecs.World) -> () } = {}

local function get(): jecs.World
    return WORLD
end

local function set(world: jecs.World)
    WORLD = world

    for _, fn in listeners do
        fn(world)
    end
end

local function on_set(fn: (jecs.World) -> ())
    table.insert(listeners, fn)
end

return {
    get = get,
    set = set,
    on_set = on_set,
}
