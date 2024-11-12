--!strict
--!optimize 2
local handle = require("./handle")
local jecs = require("../jecs")
local WORLD = require("./world").get

local refs: { [jecs.World]: { [any]: jecs.Entity<any> } } = {}

local function serve_clearer(key: any, world: jecs.World): () -> ()
    return function()
        refs[world][key] = nil
    end
end

--- Gets an entity the given key references to.
--- If the key is nil, an entirely new entity is created and returned.
--- If the key doesn't reference an entity, a new entity is made for it to reference and returned.
--- @param key any
--- @return handle
local function ref(key: any): (handle.handle, () -> ()?)
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

    return handle(entity), serve_clearer(key, world)
end

-- For the `__call`` metamethod
local function __call(_, key: any): (handle.handle, () -> ()?)
    return ref(key)
end

local function search(key: any): (handle.handle?, () -> ()?)
    local world = WORLD()
    if not key then
        return nil
    end
    local entity = refs[world][key]

    if not entity then
        return nil
    end

    return handle(entity), serve_clearer(key, world)
end

local metatable = {
    __call = __call,
    __index = {
        search = search,
        set_ref = ref,
    },
}

local REF = setmetatable({}, metatable) :: typeof(ref) & typeof(metatable.__index)
return REF
