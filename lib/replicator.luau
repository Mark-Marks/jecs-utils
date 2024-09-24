--!strict
--!optimize 2
local jecs = require("@jecs")
type entity<T = nil> = jecs.Entity<T>
type i53 = number

local ref = require("./ref")
local WORLD = require("./world").get

--- A replicator keeps track of all entities with the passed components and their values -
--- whenever a component is changed (add, change, remove) and the replicator listens to it, it's also changed within the contained raw data.\
--- The developer can then calculate the difference on the server and send it to the client every time,
--- on which the difference is then applied to the world.\
--- Albeit it's called a replicator, it doesn't replicate the data by itself.
--- This allows the developer to use any networking libary to replicate the changes.
--- ```luau
--- -- server
--- local replicator = jecs_utils.create_replicator(component_a, component_b, ...)
---
--- local function system()
---     local difference = replicator.calculate_difference()
---     -- There might not be any difference
---     if not difference then
---         return
---     end
---     data_replication_event.send_to_all(difference)
--- end
--- ```
--- ```luau
--- -- client
--- local replicator = jecs_utils.replicator(component_a, component_b, ...)
---
--- local function system()
---     for _, difference in data_replication_event.poll() do
---         replicator.apply_difference(difference)
---     end
--- end
--- ```
export type replicator = {
    --- Gets the full data representing the entire world.
    --- Useful for initial replication to every player.
    --- ```luau
    --- local replicator = jecs_utils.replicator(component_a, component_b, ...)
    ---
    --- Players.PlayerAdded:Connect(function(player)
    ---     data_replication_event.send_to(player, replicator.get_full_data())
    --- end)
    --- ```
    --- @return changes
    get_full_data: () -> changes,
    --- Calculates the difference between last sent data and currently stored data.
    --- ```luau
    --- local replicator = jecs_utils.create_replicator(component_a, component_b, ...)
    ---
    --- local function system()
    ---     local difference = replicator.calculate_difference()
    ---     -- There might not be any difference
    ---     if not difference then
    ---         return
    ---     end
    ---     data_replication_event.send_to_all(difference)
    --- end
    --- ```
    --- @return changes? -- There might not be any difference
    calculate_difference: () -> changes?,
    --- Applies the difference to the current data.
    --- ```luau
    --- local replicator = jecs_utils.replicator(component_a, component_b, ...)
    ---
    --- local function system()
    ---     for _, difference in data_replication_event.poll() do
    ---         replicator.apply_difference(difference)
    ---     end
    --- end
    --- ```
    --- @param difference changes
    apply_difference: (difference: changes) -> (),
}

--- `map<component_id, array<entity_id>>`
type changes_added = { [i53]: { i53 } }
--- `map<component_id, array<entity_id, component_value>>`
type changes_set = { [i53]: { [i53]: unknown } }
--- `map<component_id, array<entity_id>>`
type changes_removed = { [i53]: { i53 } }

export type changes = {
    added: changes_added,
    set: changes_set,
    removed: changes_removed,
}

--- A replicator keeps track of all entities with the passed components and their values -
--- whenever a component is changed (add, change, remove) and the replicator listens to it, it's also changed within the contained raw data.\
--- The developer can then calculate the difference on the server and send it to the client every time,
--- on which the difference is then applied to the world.\
--- Albeit it's called a replicator, it doesn't replicate the data by itself.
--- This allows the developer to use any networking libary to replicate the changes.
--- ```luau
--- -- server
--- local replicator = jecs_utils.create_replicator(component_a, component_b, ...)
---
--- local function system()
---     local difference = replicator.calculate_difference()
---     -- There might not be any difference
---     if not difference then
---         return
---     end
---     data_replication_event.send_to_all(difference)
--- end
--- ```
--- ```luau
--- -- client
--- local replicator = jecs_utils.replicator(component_a, component_b, ...)
---
--- local function system()
---     for _, difference in data_replication_event.poll() do
---         replicator.apply_difference(difference)
---     end
--- end
--- ```
--- @param ... entity
--- @return replicator
local function replicator(...: entity): replicator
    local world = WORLD()
    local components = { ... }

    -- don't index a changes table start
    local raw_added: changes_added = {}
    local raw_set: changes_set = {}
    local raw_removed: changes_removed = {}

    local changes_added: changes_added = {}
    local changes_set: changes_set = {}
    local changes_removed: changes_removed = {}
    -- don't index a changes table end

    for _, component in components do
        world:set(component, jecs.OnAdd, function(entity)
            if not raw_added[component] then
                raw_added[component] = {}
            end
            if not changes_added[component] then
                changes_added[component] = {}
            end
            table.insert(raw_added[component], entity)
            table.insert(changes_added[component], entity)
        end)
        world:set(component, jecs.OnSet, function(entity, value)
            if not raw_set[component] then
                raw_set[component] = {}
            end
            if not changes_set[component] then
                changes_set[component] = {}
            end
            raw_set[component][entity] = value
            changes_set[component][entity] = value
        end)
        world:set(component, jecs.OnRemove, function(entity)
            if not raw_removed[component] then
                raw_removed[component] = {}
            end
            if not changes_removed[component] then
                changes_removed[component] = {}
            end
            table.insert(raw_removed[component], entity)
            table.insert(changes_removed[component], entity)
        end)
    end

    local function get_full_data(): changes
        return {
            added = raw_added,
            set = raw_set,
            removed = raw_removed,
        }
    end

    local function calculate_difference(): changes?
        local difference_added = changes_added
        local difference_set = changes_set
        local difference_removed = changes_removed
        changes_added = {}
        changes_set = {}
        changes_removed = {}

        local added_not_empty = next(difference_added) ~= nil
        local set_not_empty = next(difference_set) ~= nil
        local removed_not_empty = next(difference_removed) ~= nil

        if not added_not_empty and not set_not_empty and not removed_not_empty then
            return nil
        end

        return {
            added = difference_added,
            set = difference_set,
            removed = difference_removed,
        }
    end

    local function apply_difference(difference: changes)
        for component, entities in difference.added do
            for _, entity_id in entities do
                local entity = ref(`replicated-{entity_id}`)

                local exists = entity:has(component)
                if exists then
                    continue
                end
                entity:add(component)
            end
        end

        for component, entities in difference.set do
            for entity_id, value in entities do
                local entity = ref(`replicated-{entity_id}`)

                local existing_value = entity:get(component)
                if existing_value == value then
                    continue
                end
                entity:set(component, value)
            end
        end

        for component, entities in difference.removed do
            for _, entity_id in entities do
                local entity = ref(`replicated-{entity_id}`)

                local exists = entity:has(component)
                if exists then
                    continue
                end
                entity:remove(component)
            end
        end
    end

    return {
        get_full_data = get_full_data,
        calculate_difference = calculate_difference,
        apply_difference = apply_difference,
    }
end

return replicator
