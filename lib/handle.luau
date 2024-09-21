--!strict
--!optimize 2
local jecs = require("./jecs")
type entity<T = nil> = jecs.Entity<T>
type id<T = nil> = entity<T> | jecs.Pair

local world = require("./world").get

type interface = {
    __index: interface,

    new: (entity: entity) -> handle,

    --- Checks if the entity has all of the given components
    has: (self: handle, ...id) -> boolean,
    --- Retrieves the value of up to 4 components. These values may be nil.
    get: (<A>(self: handle, id<A>) -> A?)
        & (<A, B>(self: handle, id<A>, id<B>) -> (A?, B?))
        & (<A, B, C>(self: handle, id<A>, id<B>, id<C>) -> (A?, B?, C?))
        & (<A, B, C, D>(self: handle, id<A>, id<B>, id<C>, id<D>) -> (A?, B?, C?, D?)),
    --- Adds a component to the entity with no value
    add: <T>(self: handle, id: id<T>) -> handle,
    --- Assigns a value to a component on the given entity
    set: <T>(self: handle, id: id<T>, data: T) -> handle,
    --- Removes a component from the given entity
    remove: (self: handle, id: id) -> handle,
    --- Deletes the entity and all its related components and relationships. **Does not** refer to deleting the handle
    delete: (self: handle) -> (),
    --- Gets the entitys id
    id: (self: handle) -> entity,
}

export type handle = typeof(setmetatable({} :: { entity: entity, world: jecs.World }, {} :: interface))

local handle = {} :: interface
handle.__index = handle

function handle.new(entity: entity)
    local self = {
        entity = entity,
        world = world(),
    }

    return setmetatable(self, handle)
end

function handle:has(...: id): boolean
    return self.world:has(self.entity, ...)
end

handle.get = function(self: handle, a: id, b: id?, c: id?, d: id?)
    return self.world:get(self.entity, a, b :: any, c :: any, d :: any)
end :: any

function handle:add<T>(id: id<T>): handle
    self.world:add(self.entity, id)
    return self
end

function handle:set<T>(id: id<T>, value: T): handle
    self.world:set(self.entity, id, value)
    return self
end

function handle:remove(id: id): handle
    self.world:remove(self.entity, id)
    return self
end

function handle:delete()
    self.world:delete(self.entity)
end

function handle:id(): entity
    return self.entity
end

return handle.new
