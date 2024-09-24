--!strict
local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")
local serde = require("@lune/serde")
local spawn = require("util/spawn")

type wally_manifest = {
    package: {
        name: string,
        version: string,
        registry: string,
        realm: string,
        license: string?,
        exclude: { string }?,
        include: { string }?,
    },
    dependencies: {
        [string]: string,
    },
}

local github_token: string = process.args[1]

if not github_token then
    local env_exists = fs.metadata(".env").exists
    if not env_exists then
        error("Usage: lune run download-jecs [GITHUB_PAT]\nAlternatively, put the PAT in an .env file under GITHUB_PAT")
    end

    local env = serde.decode("toml", fs.readFile(".env"))
    local pat = env.GITHUB_PAT or error("Couldn't read GITHUB_PAT from .env")
    github_token = pat
end

local manifest_contents = fs.readFile("wally.toml") or error("Couldn't read manifest.")
local manifest: wally_manifest = serde.decode("toml", manifest_contents) or error("Couldn't decode manifest.")
local jecs_version = string.match(manifest.dependencies.jecs, "%d.%d.%d") or error("Couldn't find jecs version.")

type gh_api_tag = {
    ref: string,
    node_id: string,
    url: string,
    object: {
        sha: string,
        type: string,
        url: string,
    },
}

local response = net.request({
    url = `https://api.github.com/repos/ukendio/jecs/git/refs/tags/v{jecs_version}`,
    method = "GET",
    headers = {
        Accept = "application/vnd.github+json",
        Authorization = `Bearer {github_token}`,
        ["X-GitHub-Api-Version"] = "2022-11-28",
    },
})

if not response.ok then
    error(`Github api response not ok:\n{response.statusCode} @ {response.statusMessage}\n{response.body}`)
end

local gh_api_tag: gh_api_tag = serde.decode("json", response.body)

spawn.start(`curl https://raw.githubusercontent.com/ukendio/jecs/{gh_api_tag.object.sha}/src/init.luau -o jecs.luau`)
