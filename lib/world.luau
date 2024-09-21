--!strict
--!optimize 2
local jecs = require("./jecs")

local WORLD: jecs.World

local function get(): jecs.World
    return WORLD
end

local function set(world: jecs.World)
    WORLD = world
end

return {
    get = get,
    set = set,
}
