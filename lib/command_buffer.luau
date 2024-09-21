--!strict
--!optimize 2
local jecs = require("./jecs")
type entity<T = nil> = jecs.Entity<T>
type id<T = nil> = jecs.Id<T>

local WORLD = require("./world").get

--- `map<component_id, array<entity_id>>`
local add_commands: { [id]: { entity } } = {}
--- `map<component_id, array<entity_id, component_value>>`
local set_commands: { [id]: { [entity]: any } } = {}
--- `map<component_id, array<entity_id>>`
local remove_commands: { [id]: { entity } } = {}
--- `array<entity_id>`
local delete_commands: { entity } = {}

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
    local world = WORLD()

    for _, entity in delete_commands do
        world:delete(entity)
    end

    for component, entities in add_commands do
        for _, entity in entities do
            if delete_commands[entity] then
                continue
            end

            world:add(entity, component)
        end
    end
    table.clear(add_commands)

    for component, entities in set_commands do
        for entity, value in entities do
            if delete_commands[entity] then
                continue
            end

            world:set(entity, component, value)
        end
    end
    table.clear(set_commands)

    for component, entities in remove_commands do
        for _, entity in entities do
            if delete_commands[entity] then
                continue
            end

            world:remove(entity, component)
        end
    end
    table.clear(remove_commands)

    table.clear(delete_commands)
end

local function add(entity: entity, component: id)
    if not add_commands[component] then
        add_commands[component] = {}
    end

    table.insert(add_commands[component], entity)
end

local function set<T>(entity: entity, component: id<T>, data: T)
    if not set_commands[component] then
        set_commands[component] = {}
    end

    set_commands[component][entity] = data
end

local function remove(entity: entity, component: id)
    if not remove_commands[component] then
        remove_commands[component] = {}
    end

    table.insert(remove_commands[component], entity)
end

local function delete(entity: entity)
    table.insert(delete_commands, entity)
end

local command_buffer: command_buffer = {
    flush = flush,

    add = add,
    set = set,
    remove = remove,
    delete = delete,
}

return command_buffer
