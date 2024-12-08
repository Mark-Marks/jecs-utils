--!strict
--!native
--!optimize 2
-- pesde adds dependencies by including a folder with them in the package
-- wally just adds a file for each dependency
-- this is here to mitigate that
local jecs = require("./luau_packages/jecs")
export type Archetype = jecs.Archetype
export type Id<T = nil> = jecs.Id<T>
export type Pair<First, Second> = jecs.Pair<First, Second>
export type Entity<T = nil> = jecs.Entity<T>
export type World = jecs.World
return jecs
