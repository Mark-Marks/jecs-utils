--!strict
--!optimize 2
local jecs = require("@jecs")
type entity<T = nil> = jecs.Entity<T>
type id<T = nil> = jecs.Id<T>

local _world = require("./world")
local WORLD = _world.get

-- luau-lsp literally dies if you use the actual world type
type jecs_world = any

--- `map<component_id, array<entity_id>>`
local add_commands: { [jecs_world]: { [id]: { entity } } } = {}
--- `map<component_id, array<entity_id, component_value>>`
local set_commands: { [jecs_world]: { [id]: { [entity]: any } } } = {}
--- `map<component_id, array<entity_id>>`
local remove_commands: { [jecs_world]: { [id]: { entity } } } = {}
--- `array<entity_id>`
local delete_commands: { [jecs_world]: { entity } } = {}

_world.on_set(function(world)
    add_commands[world] = {}
    set_commands[world] = {}
    remove_commands[world] = {}
    delete_commands[world] = {}
end)

export type command_buffer = {
    --- Execute all buffered commands and clear the buffer
    flush: () -> (),

    --- Adds a component to the entity with no value
    add: (entity: entity, component: id) -> (),
    --- Assigns a value to a component on the given entity
    set: <T>(entity: entity, component: id<T>, data: T) -> (),
    --- Removes a component from the given entity
    remove: (entity: entity, component: id) -> (),
    --- Deletes an entity from the world
    delete: (entity: entity) -> (),
}

local function flush()
    for world, entities in delete_commands do
        for _, entity in entities do
            world:delete(entity)
        end
    end

    for world, commands in add_commands do
        for component, entities in commands do
            for _, entity in entities do
                if delete_commands[world][entity] then
                    continue
                end

                world:add(entity, component)
            end
        end
        table.clear(add_commands[world])
    end

    for world, commands in set_commands do
        for component, entities in commands do
            for entity, value in entities do
                if delete_commands[world][entity] then
                    continue
                end

                world:set(entity, component, value)
            end
        end
        table.clear(set_commands[world])
    end

    for world, commands in remove_commands do
        for component, entities in commands do
            for _, entity in entities do
                if delete_commands[world][entity] then
                    continue
                end

                world:remove(entity, component)
            end
        end
        table.clear(remove_commands[world])
    end

    for world in delete_commands do
        table.clear(delete_commands[world])
    end
end

local function add(entity: entity, component: id)
    local world = WORLD()
    if not add_commands[world][component] then
        add_commands[world][component] = {}
    end

    table.insert(add_commands[world][component], entity)
end

local function set<T>(entity: entity, component: id<T>, data: T)
    local world = WORLD()
    if not set_commands[world][component] then
        set_commands[world][component] = {}
    end

    set_commands[world][component][entity] = data
end

local function remove(entity: entity, component: id)
    local world = WORLD()
    if not remove_commands[world][component] then
        remove_commands[world][component] = {}
    end

    table.insert(remove_commands[world][component], entity)
end

local function delete(entity: entity)
    local world = WORLD()
    table.insert(delete_commands[world], entity)
end

local command_buffer: command_buffer = {
    flush = flush,

    add = add,
    set = set,
    remove = remove,
    delete = delete,
}

return command_buffer
