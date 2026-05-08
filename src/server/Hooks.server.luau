local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Inventory = require(script.Parent.Inventory)
local PlotManager = require(script.Parent.PlotManager)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

Remotes.Base.PlaceObject.OnServerInvoke = PlotManager.PlaceObject
Remotes.Inventory.GetOwnedItems.OnServerInvoke = Inventory.GetData
