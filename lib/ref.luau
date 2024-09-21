--!strict
--!optimize 2
local handle = require("./handle")
local WORLD = require("./world").get

local refs = {}

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

    local entity = refs[key]
    if not entity then
        entity = world:entity()
        refs[key] = entity
    end

    return handle(entity)
end

return ref
