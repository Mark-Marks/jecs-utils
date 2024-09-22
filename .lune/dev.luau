--!strict
local process = require("@lune/process")
local stdio = require("@lune/stdio")
local task = require("@lune/task")

local spawn = require("util/spawn")

spawn.spawn("rojo sourcemap dev.project.json -o sourcemap.json --watch")
spawn.spawn("darklua process --config .darklua.json --watch lib/ dist/", { env = { ROBLOX_DEV = "true" } })

task.wait(1)

while true do
    local start_commit = stdio.prompt("confirm", "Start commit? -- `y` to start a commit, `n` to exit the script")
    if not start_commit then
        process.exit(0)
        break
    end

    local _, check_result = pcall(spawn.start, "lune run check")
    if not check_result.ok then
        print("Check didn't go ok, aborting commit")
        break
    end

    local commit_title = stdio.prompt("text", "Commit title -- leave blank to stop committing")
    if not commit_title or commit_title == "" then
        print("Stopping commit")
        continue
    end

    local commit_messages = ""
    while true do
        local commit_message = stdio.prompt("text", "Commit message -- added to the description, leave blank to finish")
        if not commit_message or commit_message == "" then
            break
        end

        commit_messages ..= `-m "{commit_message}" `
    end

    local confirm = stdio.prompt("confirm", "Confirm?")
    if not confirm then
        break
    end

    process.spawn("git", { "add", "." }, { stdio = "forward" })
    process.spawn("git", { "commit", "-m", commit_title, commit_messages }, { stdio = "forward" })
    process.spawn("git", { "push" }, { stdio = "forward" })
end
