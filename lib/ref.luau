--!strict
--!optimize 2
local handle = require("./handle")
local jecs = require("./jecs")
local WORLD = require("./world").get

local refs: { [jecs.World]: { [any]: jecs.Entity } } = {}

--- Gets an entity the given key references to.
--- If the key is nil, an entirely new entity is created and returned.
--- If the key doesn't reference an entity, a new entity is made for it to reference and returned.
--- @param key any
--- @return handle
local function ref(key: any): handle.handle
    local world = WORLD()
    if not key then
        return handle(world:entity())
    end

    if not refs[world] then
        refs[world] = {}
    end

    local entity = refs[world][key]
    if not entity then
        entity = world:entity()
        refs[world][key] = entity
    end

    return handle(entity)
end

return ref
