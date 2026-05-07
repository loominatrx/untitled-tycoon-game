local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Interface = require(ReplicatedStorage.Shared.Interface)

require(script.PlacementClient) -- gotta load this as early as possible
Interface.init()