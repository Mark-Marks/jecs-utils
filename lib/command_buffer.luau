--!strict
--!optimize 2
local jecs = require("@pkg/jecs")
type entity<T = nil> = jecs.Entity<T>
type id<T = nil> = jecs.Id<T>

local world = require("./world").get()

--- `map<component_id, array<entity_id>>`
local add_commands: { [id]: { entity } } = {}
--- `map<component_id, array<entity_id, component_value>>`
local set_commands: { [id]: { [entity]: any } } = {}
--- `map<component_id, array<entity_id>>`
local remove_commands: { [id]: { entity } } = {}
--- `array<entity_id>`
local delete_commands: { entity } = {}

type command_buffer = {
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
    local adds = add_commands
    local sets = set_commands
    local removes = remove_commands
    local deletes = delete_commands
    table.clear(add_commands)
    table.clear(set_commands)
    table.clear(remove_commands)
    table.clear(delete_commands)

    for _, id in deletes do
        world:delete(id)
    end

    for component, ids in adds do
        for _, id in ids do
            if deletes[id] then
                continue
            end

            world:add(id, component)
        end
    end

    for component, ids in sets do
        for id, value in ids do
            if deletes[id] then
                continue
            end

            world:set(id, component, value)
        end
    end

    for component, ids in removes do
        for _, id in ids do
            if deletes[id] then
                continue
            end

            world:remove(id, component)
        end
    end
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
