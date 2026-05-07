local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Interface = require(script.Parent.Parent)
local Types = require(ReplicatedStorage.Shared.Types)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local OnyxUI = require(ReplicatedStorage.Packages.OnyxUI)
local Themer = OnyxUI.Themer

local ThemeSpec = require(ReplicatedStorage.Shared.Interface.Theme)

local Children = Fusion.Children

return function(scope: Types.FusionScope, context: 'Inventory' | 'Shop')
    local onyx = Interface.PopulateOnyx(scope) :: Types.Fusionyx
    local container
    Themer.Theme:is(ThemeSpec):during(function()
        container = onyx:Frame {
            AutomaticSize = Enum.AutomaticSize.None,
            Size = UDim2.new(1, 0, 0.2, 160),
            AnchorPoint = Vector2.yAxis,
            Position = UDim2.fromScale(0, 1),

            List = {
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder,
            },

            [Children] = {
                onyx:New('Frame') {
                    AutomaticSize = Enum.AutomaticSize.None,
                    Size = UDim2.new(0.4, 120, 0.05, 40),
                    BackgroundTransparency = 1,
                },
                onyx:Card {
                    AutomaticSize = Enum.AutomaticSize.None,
                    Size = UDim2.fromScale(1, 1),

                    Flex = {
                        Mode = Enum.UIFlexMode.Fill
                    },

                    [Children] = {
                        onyx:Scroller {
                            Size = UDim2.fromScale(1, 1),
                            AutomaticCanvasSize = Enum.AutomaticSize.X,
                            ElasticBehavior = Enum.ElasticBehavior.Always,
                            ScrollingDirection = Enum.ScrollingDirection.X,
                            ScrollBarThickness = 0,

                            List = {
                                FillDirection = Enum.FillDirection.Horizontal,
                                VerticalAlignment = Enum.VerticalAlignment.Top,
                                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                                SortOrder = Enum.SortOrder.LayoutOrder,
                            },

                            Padding = {
                                All = UDim.new(0, 2)
                            }
                        }
                    }
                },
            }
        }

        task.defer(function()
            local things = {'IronMine', 'BasicConveyor', 'BasicFurnace'}
            for i = 0, 8 do
                local thing = Interface.Elements.ItemGrid(scope, things[(i % 3) + 1], container.Card.Scroller.AbsoluteSize.Y)
                thing.Parent = container.Card.Scroller
            end
        end)
    end)

    return container
end
