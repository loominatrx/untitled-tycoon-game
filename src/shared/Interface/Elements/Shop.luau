local ReplicatedStorage = game:GetService('ReplicatedStorage')

local GameEnum = require(ReplicatedStorage.Shared.GameEnum)
local ItemUtil = require(ReplicatedStorage.Shared.Interface.Utils.ItemUtil)
local Interface = require(script.Parent.Parent)
local Types = require(ReplicatedStorage.Shared.Types)

return function(scope: Types.FusionScope)
    local Panel = Interface.Elements.ItemPanel(scope, 'Shop')

    task.defer(function()
        local buyableItems = ItemUtil.GetBuyableItems()
        for _, id in buyableItems do
            local item = Interface.Elements.ItemGrid(
                scope,
                id,
                Panel.Card.Scroller.AbsoluteSize.Y,
                GameEnum.ItemPanelContext.Shop
            )
            item.Parent = Panel.Card.Scroller
        end
    end)

    return Panel
end
