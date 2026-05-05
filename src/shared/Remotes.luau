local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Types = require(script.Parent.Types)
local TypedRemote = require(ReplicatedStorage.Packages.TypedRemote)

-- I LOVE ROBLOX TYPECHECKING SYSTEM
local typed_remote = require(ReplicatedStorage.Packages._Index['sleitnick_typed-remote@0.3.0']['typed-remote'])

-- Get the RF, RE and URE instance creators, which create RemoteFunctions/RemoteEvents/UnreliableRemoteEvents
-- within the given parent (the script by default):
local RF, RE = TypedRemote.parent(script)

-- Redeclare the TypedRemote types for simplicity:
type RF<T..., R...> = typed_remote.Function<T..., R...>
type RE<T...> = typed_remote.Event<T...>

return {
    Base = {
        GetPlot = RF('GetPlot') :: RF<(), (Types.Plot)>,
        PlaceObject = RF('PlaceObject') :: RF<(string, CFrame, number), ()>,
        WithdrawObject = RF('WithdrawObject') :: RF<(Model), ()>,
        WithdrawAllObjects = RF('WithdrawAllObjects') :: RF<(), ()>,

        BaseLoaded = RE('BaseLoaded') :: RE<Types.Plot>,
        GridOccupied = RE('GridOccupied') :: RE<number, number, number, number>,
        GridFreed = RE('GridFreed') :: RE<number, number, number, number>,
    },

    Inventory = {
        GetOwnedItems = RF('GetOwnedItems') :: RF<(), (Types.InventoryItems)>,
    },
}
