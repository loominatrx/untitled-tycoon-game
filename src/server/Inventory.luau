local ReplicatedStorage = game:GetService('ReplicatedStorage')
local DataStore = require(script.Parent.DataStore)
local metadata = ReplicatedStorage.Shared.Metadata

local inventory = {}

local function checkItem(item: string)
    return metadata:FindFirstChild(item) ~= nil
end

function inventory.PlayerHasItem(player: Player, item: string)
    assert(checkItem(item), 'item not found')
    local data = inventory.GetData(player)

    return data[item] ~= nil and data[item] > 0
end

function inventory.GetData(player: Player)
    return DataStore.GetData(player).Inventory
end

function inventory.AddItem(player: Player, item: string, quantity: number?)
    assert(checkItem(item), 'item not found')
    quantity = if quantity ~= nil and quantity ~= 0 then math.round(quantity) else 1
    local data = inventory.GetData(player)

    if data[item] == nil then
        data[item] = 0
    end

    data[item] += quantity
end

function inventory.RemoveItem(player: Player, item: string, quantity: number?)
    local qty = if quantity ~= nil and quantity > 0 then math.round(math.abs(quantity)) else 1
    return inventory.AddItem(player, item, -qty)
end

return inventory
