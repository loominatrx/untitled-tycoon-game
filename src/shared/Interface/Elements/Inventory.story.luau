local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Interface = require(script.Parent.Parent)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local story = {
   fusion = Fusion,
   story = function(props)
      local scope = props.scope
      local target = props.target
      Interface.Elements.ItemPanel(scope).Parent =  target
   end
}

return story