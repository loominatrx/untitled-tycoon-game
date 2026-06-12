local ReplicatedStorage = game:GetService('ReplicatedStorage')
local DataStore = require(script.Parent.DataStore)
local Types = require(ReplicatedStorage.Shared.Types)
local Shop = {}

local SELL_VALUE = 0.42

function Shop.GetSellValue(metadata: Types.ItemMetadata)
    local price = metadata.Price
    return math.floor(price * SELL_VALUE)
end

function Shop.Buy(buyer: Player, metadata: Types.ItemMetadata)
    if not metadata.OnSale then
        return
    end

    local price = metadata.Price
    local money = DataStore.GetMoney(buyer)
    if money >= metadata.Price then
        DataStore.AddMoney(buyer, -(math.abs(price)))
    end
end

function Shop.Sell(seller: Player, metadata: Types.ItemMetadata)
    if not metadata.CanBeSold then
        return
    end

    DataStore.AddMoney(seller, Shop.GetSellValue(metadata))
end

return Shop
