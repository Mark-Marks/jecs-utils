--!strict
local spawner_type = require("./spawner_type")
local WORLD = require("./world").get
local handle = require("./handle")

export type spawner<T...> = spawner_type.spawner<T...>

--- Creates an entity spawner.
--- ```luau
--- local spawner = jecs_utils.spawner(components.part, components.velocity, components.position)
--- for _ = 1, 1000 do
---     spawner.spawn(part_template:Clone(), Vector3.zero, Vector3.zero)
--- end
--- ```
--- @param ... T... -- Components to use.
--- @return spawner<T...>
local function spawner(...)
    local components = { ... }
    local world = WORLD()

    local function spawn(...)
        local passed = { ... }
        local entity = world:entity()

        for idx, component in components do
            world:set(entity, component, passed[idx])
        end

        return entity
    end

    local function spawn_with_handle(...)
        local passed = { ... }
        local entity = handle(world:entity())

        for idx, component in components do
            entity:set(component, passed[idx])
        end

        return entity
    end

    return {
        spawn = spawn,
        spawn_with_handle = spawn_with_handle,
    }
end

return (spawner :: any) :: spawner_type.create_spawner
