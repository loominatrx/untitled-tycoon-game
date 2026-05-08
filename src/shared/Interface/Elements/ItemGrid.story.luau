local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Interface = require(script.Parent.Parent)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local story = {
    fusion = Fusion,
    controls = {
        name = 'IronMine',
    },
    story = function(props)
        local scope = props.scope
        local target = props.target
        Interface.Elements.ItemGrid(scope, props.controls.name).Parent = target
    end,
}

return story
