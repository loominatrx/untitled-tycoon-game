-- wacky wrapper because zed sucks
local process = require("@lune/process")

local function check(toolchain: string)
    local success, result = pcall(process.exec, toolchain, {"--version"})
    if success  and result.ok then
        local major, minor, patch = result.stdout:match('(%d+)%.(%d+)%.([%d%a-%.]+)')
        print(`[sync  ] {toolchain} exists and reported itself as version {major}.{minor}.{patch}`)
    else
        print(`[sync  ] {toolchain} doesn't appear to be installed. exiting...`)
        process.exit(1)
    end
end

-- check everything first
print('[sync  ] checking everything required')
print()

check('stylua')
check('rojo')

print()

process.create("stylua", { "--lsp" })
print('[stylua] LSP runs in background')
local serve = process.create("rojo", { "serve" })
print('[rojo  ] project should be in sync. visit http://localhost:34872/ in your browser for more information.')
local sourcemap = process.create("rojo", {
    "sourcemap",
    "--watch",
    "--include-non-scripts",
    "--output",
    "sourcemap.json"
})
print('[rojo  ] currently autogenerating sourcemap.json; do not exit')

print()

print('[sync  ] script will exit if something goes wrong.')
print('[sync  ] if it did, try running each tasks one by one. [ctrl+shift+p -> tasks]')

-- watch for rojo serve (and maybe sourcemap too)
serve.stdout:readToEnd()
sourcemap.stdout:readToEnd()
