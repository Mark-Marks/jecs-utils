--!strict
--!optimize 2
local WORLD = require("./world")
local collect = require("./collect")
local command_buffer = require("./command_buffer")
local handle = require("./handle")
local jecs = require("@pkg/jecs")
local ref = require("./ref")
local replicator = require("./replicator")

--- Set the world for all utilities.
--- Should be called once per context before any utility is used.
--- @param world jecs.World
local function initialize(world: jecs.World)
    WORLD.set(world)
end

return {
    initialize = initialize,

    collect = collect,
    handle = handle,
    replicator = replicator,
    ref = ref,
    command_buffer = command_buffer,
}
