local ReplicatedStorage = game:GetService('ReplicatedStorage')
local StarterGui = game:GetService('StarterGui')

local Interface = require(script.Parent.Parent)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local sample = workspace.IronMine
local story = {
    fusion = Fusion,
    story = function(props)
        local scope = props.scope
        Interface.Elements.ObjectActions(scope, scope:Value { sample }).Billboard.Parent = StarterGui
    end,
}

return story
