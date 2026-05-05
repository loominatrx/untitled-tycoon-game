local ReplicatedStorage = game:GetService('ReplicatedStorage')
local PlotManager = require(script.Parent.PlotManager)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

Remotes.Base.PlaceObject.OnServerInvoke = PlotManager.PlaceObject
