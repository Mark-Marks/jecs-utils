--!strict
--!optimize 2
local jecs = require("./jecs")

local WORLD = require("./world")
local collect = require("./collect")
export type collect_signal_like<T...> = collect.signal_like<any, T...>
export type collect_verbose_signal_like<D, T...> = collect.signal_like<D, T...>
local command_buffer = require("./command_buffer")
export type command_buffer = command_buffer.command_buffer
local handle = require("./handle")
export type handle = handle.handle
local ref = require("./ref")
local replicator = require("./replicator")
export type replicator = replicator.replicator
export type changes = replicator.changes

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
