--!strict
-- stylua: ignore start
local jecs = require("@jecs")
local jecs_utils = require("@jecs_utils")
local testkit = require("@testkit")

type entity<T = nil> = jecs.Entity<T>

local collect = jecs_utils.collect
local handle = jecs_utils.handle
local replicator = jecs_utils.replicator
local ref = jecs_utils.ref
local ref_search = ref.search
local command_buffer = jecs_utils.command_buffer
local spawner = jecs_utils.spawner

local signal = require("./signal")

local BENCH, START = testkit.benchmark()

local TEST, CASE, CHECK, FINISH, SKIP, FOCUS = testkit.test()

TEST("jecs_utils.collect()", function()
    do CASE "collects"
        local sig: signal.signal<number> = signal()
        local flush = collect(sig)
        local should = {}

        for idx = 100, 1, -1 do
            local n = math.random()
            should[idx] = n
            sig:fire(n)
        end

        for idx, n in flush do
            CHECK(should[idx] == n)
        end
    end
end)

TEST("jecs_utils.handle()", function()
    do CASE "has"
        local world = jecs.World.new()
        jecs_utils.initialize(world)

        local entity = world:entity()
        local tag = world:entity()

        world:add(entity, tag)
        CHECK(handle(entity):has(tag))
    end

    do CASE "get"
        local world = jecs.World.new()
        jecs_utils.initialize(world)

        local entity = world:entity()
        local component = world:component()

        world:set(entity, component, 50)
        CHECK(handle(entity):get(component) == 50)
    end

    do CASE "add"
        local world = jecs.World.new()
        jecs_utils.initialize(world)

        local entity = world:entity()
        local tag = world:entity()

        handle(entity):add(tag)
        CHECK(world:has(entity, tag))
    end

    do CASE "set"
        local world = jecs.World.new()
        jecs_utils.initialize(world)

        local entity = world:entity()
        local component = world:component()

        handle(entity):set(component, 50)
        CHECK(world:get(entity, component) == 50)
    end

    do CASE "remove"
        local world = jecs.World.new()
        jecs_utils.initialize(world)

        local entity = world:entity()
        local component = world:component()

        handle(entity):set(component, 50)
        CHECK(world:get(entity, component) == 50)
    end

    do CASE "delete"
        local world = jecs.World.new()
        jecs_utils.initialize(world)

        local entity = world:entity()
        handle(entity):delete()
        CHECK(not world:contains(entity))
    end
end)

TEST("jecs_utils.ref()", function()
    do CASE "set_ref"
        local world = jecs.World.new()
        jecs_utils.initialize(world)

        local a: number = ref(1234):id()
        local b: number = ref(1234):id()
        CHECK(a == b)
    end

    do CASE "search"
        local world = jecs.World.new()
        jecs_utils.initialize(world)

        local a: number = ref(1234):id()
        local b = ref_search(1234)
        assert(b) -- give me the type refinements...
        CHECK(a == b:id() :: number)
    end

    do CASE "clearer"
        local world = jecs.World.new()
        jecs_utils.initialize(world)

        local a, a_clear = ref(1234);
        (a_clear :: any)()
        local b = ref(1234)
        CHECK(b:id() :: number ~= a:id() :: number)
    end
end)

TEST("jecs_utils.replicator()", function()
    do CASE "propagates difference"
        local world = jecs.World.new()
        local tag = world:entity()
        local component: jecs.Entity<number> = world:component()

        local entity1 = world:entity()
        local entity2 = world:entity()

        jecs_utils.initialize(world)
        local rep = replicator(component, tag)

        world:add(entity1, tag)
        world:set(entity2, component, 50)

        local difference: jecs_utils.changes = rep.calculate_difference() :: any
        CHECK(difference ~= nil)

        local world2 = jecs.World.new()
        local component2: jecs.Entity<number> = world2:component()
        local tag2 = world2:entity()

        jecs_utils.initialize(world2)
        local rep2 = replicator(component2, tag2)

        rep2.apply_difference(difference)

        CHECK(ref(`replicated-{entity1}`):has(tag2))
        CHECK(ref(`replicated-{entity2}`):get(component2) == 50)
    end

    do CASE "propagates full data"
        local world = jecs.World.new()
        local tag = world:entity()
        local component: jecs.Entity<number> = world:component()

        local entity1 = world:entity()
        local entity2 = world:entity()

        jecs_utils.initialize(world)
        local rep = replicator(component, tag)

        world:add(entity1, tag)
        world:set(entity2, component, 50)

        local full_data = rep.get_full_data()
        CHECK(full_data ~= nil)

        local world2 = jecs.World.new()
        local component2: jecs.Entity<number> = world2:component()
        local tag2 = world2:entity()

        jecs_utils.initialize(world2)
        local rep2 = replicator(component2, tag2)

        rep2.apply_difference(full_data)

        CHECK(ref(`replicated-{entity1}`):has(tag2))
        CHECK(ref(`replicated-{entity2}`):get(component2) == 50)
    end
end)

TEST("jecs_utils.command_buffer", function()
    do CASE "add"
        local world = jecs.World.new()
        jecs_utils.initialize(world)

        local tag = world:entity()
        local entity = world:entity()
        command_buffer.add(entity, tag)

        CHECK(not world:has(entity, tag))

        command_buffer.flush()

        CHECK(world:has(entity, tag))
    end

    do CASE "set"
        local world = jecs.World.new()
        jecs_utils.initialize(world)

        local component = world:component()
        local entity = world:entity()
        command_buffer.set(entity, component, 50)

        CHECK(not world:has(entity, component))

        command_buffer.flush()

        CHECK(world:get(entity, component) == 50)
    end

    do CASE "remove"
        local world = jecs.World.new()
        jecs_utils.initialize(world)

        local component = world:component()
        local entity = world:entity()
        world:set(entity, component, 50)
        command_buffer.remove(entity, component)

        CHECK(world:has(entity, component))

        command_buffer.flush()

        CHECK(not world:has(entity, component))
    end

    do CASE "delete"
        local world = jecs.World.new()
        jecs_utils.initialize(world)

        local entity = world:entity()
        command_buffer.delete(entity)

        command_buffer.flush()

        CHECK(not world:contains(entity))
    end
end)

TEST("jecs_utils.spawner()", function()
    do CASE "spawn"
        local world = jecs.World.new()
        jecs_utils.initialize(world)

        local c1: entity<number> = world:component()
        local c2: entity<string> = world:component()
        local c3: entity<{}> = world:component()

        local t1 = world:entity()

        local entity_spawner = spawner(c1, c2, c3, t1)

        local tbl = {}

        local idx = entity_spawner.spawn(1234, "abcdef", tbl)
        CHECK(world:contains(idx))
        CHECK(world:get(idx, c1) == 1234)
        CHECK(world:get(idx, c2) == "abcdef")
        CHECK(world:get(idx, c3) == tbl)
        CHECK(world:has(idx, t1))
    end

    do CASE "spawn_with_handle"
        local world = jecs.World.new()
        jecs_utils.initialize(world)

        local c1: entity<number> = world:component()
        local c2: entity<string> = world:component()
        local c3: entity<{}> = world:component()

        local t1 = world:entity()

        local entity_spawner = spawner(c1, c2, c3, t1)

        local tbl = {}

        local ent = entity_spawner.spawn_with_handle(1234, "abcdef", tbl)
        CHECK(world:contains(ent:id()))
        CHECK(ent:get(c1) == 1234)
        CHECK(ent:get(c2) == "abcdef")
        CHECK(ent:get(c3) == tbl)
        CHECK(ent:has(t1))
    end
end)

FINISH()
-- stylua: ignore end
