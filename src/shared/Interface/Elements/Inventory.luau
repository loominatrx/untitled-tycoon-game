local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameEnum = require(ReplicatedStorage.Shared.GameEnum)
local ItemUtil = require(ReplicatedStorage.Shared.Interface.Utils.ItemUtil)
local Interface = require(script.Parent.Parent)
local Types = require(ReplicatedStorage.Shared.Types)

return function(scope: Types.FusionScope)
    local Panel = Interface.Elements.ItemPanel(scope)

    task.defer(function()

        ItemUtil.GetInventoryItems():andThen(function(items)
            for name, amount in items do
                if ItemUtil.DoesItemExist(name) then
                    local item = Interface.Elements.ItemGrid(scope, name, Panel.Card.Scroller.AbsoluteSize.Y, GameEnum.ItemPanelContext.Inventory)
                    item.Parent = Panel.Card.Scroller
                end
            end
        end):catch(error)
        
        -- for i = 0, 8 do
        --     local thing = Interface.Elements.ItemGrid(scope, things[(i % 3) + 1], Panel.Card.Scroller.AbsoluteSize.Y)
        --     thing.Parent = Panel.Card.Scroller
        -- end
    end)

    return Panel
end