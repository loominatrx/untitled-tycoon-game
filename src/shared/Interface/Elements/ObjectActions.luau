local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local OnyxUI = require(ReplicatedStorage.Packages.OnyxUI)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local ThemeSpec = require(ReplicatedStorage.Shared.Interface.Theme)
local Metadata = require(ReplicatedStorage.Shared.Metadata)
local MoneyLib = require(ReplicatedStorage.Shared.MoneyLib)
local Interface = require(script.Parent.Parent)
local Types = require(ReplicatedStorage.Shared.Types)

local Themer = OnyxUI.Themer

local Children = Fusion.Children
local peek = Fusion.peek

local CLOSED_Y = 72
local OPENED_Y = 278

local ListParameter = {
    FillDirection = Enum.FillDirection.Vertical,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    SortOrder = Enum.SortOrder.LayoutOrder,
}

return function(scope: Types.FusionScope)
    local onyx = Interface.PopulateOnyx(scope)
    local isOpened = onyx:Value(false)
    local isHovering = onyx:Value(false)
    local items = onyx:Value {}

    onyx:Observer(items):onBind(function()
        if #peek(items) == 0 then
            isOpened:set(false)
        end
    end)

    local UI, Billboard
    do
        Themer.Theme:is(ThemeSpec):during(function()
            local Theme = Themer.Theme:now()
            Billboard = onyx:New('BillboardGui') {
                AlwaysOnTop = true,
                Adornee = onyx:Computed(function(use)
                    local currentItems = use(items)
                    if #currentItems == 0 then
                        return nil
                    end
                    return currentItems[#currentItems]
                end),
                Enabled = onyx:Computed(function(use)
                    local currentItems = use(items)
                    if #currentItems == 0 then
                        return false
                    end
                    return true
                end),
                Size = UDim2.fromOffset(280, OPENED_Y),
                Parent = Players.LocalPlayer.PlayerGui,
            }
            UI = onyx:BaseButton {
                AutomaticSize = Enum.AutomaticSize.None,
                AnchorPoint = Vector2.one * 0.5,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = onyx:Spring(
                    onyx:Computed(function(use)
                        local open = use(isOpened)
                        return UDim2.fromOffset(280, open and OPENED_Y or CLOSED_Y)
                    end),
                    20,
                    1
                ),
                List = TableUtil.Reconcile({
                    Padding = UDim.new(0, 8),
                }, ListParameter),
                Hovering = isHovering,

                ClipsDescendants = true,

                OnActivate = function()
                    isOpened:set(true)
                end,

                Parent = Billboard,

                [Children] = {
                    onyx:Card {
                        AutomaticSize = Enum.AutomaticSize.None,
                        AnchorPoint = Vector2.zero,
                        Position = UDim2.fromScale(0, 0),
                        Size = onyx:Spring(
                            onyx:Computed(function(use)
                                local open = use(isOpened)
                                return UDim2.new(1, 0, 0, open and OPENED_Y or CLOSED_Y)
                            end),
                            20,
                            1
                        ),

                        List = ListParameter,
                        Corner = {
                            Radius = onyx:UDim(0, Theme.CornerRadius['1.5']),
                        },
                        Stroke = {
                            Position = Enum.BorderStrokePosition.Inner,
                        },

                        [Children] = {

                            -- prepare for computeds lmao
                            onyx:Frame {
                                Name = 'Info',
                                AutomaticSize = Enum.AutomaticSize.XY,
                                List = TableUtil.Reconcile({
                                    Padding = UDim.new(0, 4),
                                }, ListParameter),
                                [Children] = {

                                    -- Item name
                                    onyx:Text {
                                        Text = onyx:Computed(function(use)
                                            local currentItems = use(items)
                                            if #currentItems > 1 then
                                                return 'Multiple items selected'
                                            elseif #currentItems == 1 then
                                                local id = currentItems[1].Name
                                                print(id)
                                                local meta = Metadata[id]
                                                if meta == nil then
                                                    return 'Unknown Item'
                                                end
                                                return meta.FriendlyName or id
                                            else
                                                return 'Unknown Item'
                                            end
                                        end),
                                        TextSize = 24,
                                    },

                                    -- Item tier
                                    onyx:Text {
                                        Text = onyx:Computed(function(use)
                                            local currentItems = use(items)
                                            if #currentItems > 1 then
                                                return `{#currentItems} items`
                                            elseif #currentItems == 1 then
                                                local id = currentItems[1].Name
                                                local meta = Metadata[id]
                                                -- if meta == nil then
                                                --     return '<cannot fetch data>'
                                                -- end
                                                return meta.ItemTier
                                            else
                                                return '<cannot fetch data>'
                                            end
                                        end),
                                        TextSize = 18,
                                    },
                                },
                            },

                            onyx:Frame {
                                Name = 'Actions',
                                Size = UDim2.fromScale(1, 0),
                                AutomaticSize = Enum.AutomaticSize.Y,
                                List = ListParameter,
                                [Children] = {

                                    -- Buy item
                                    onyx:Button {
                                        List = ListParameter,
                                        Disabled = onyx:Computed(function(use)
                                            local currentItems = use(items)
                                            if #currentItems > 1 then
                                                return true
                                            elseif #currentItems == 1 then
                                                local id = currentItems[1].Name
                                                local meta = Metadata[id]
                                                return not meta.OnSale
                                            else
                                                return true
                                            end
                                        end),
                                        Size = UDim2.fromScale(1, 0),
                                        Color = Theme.Colors.Base.Main,
                                        Content = onyx:Computed(function(use)
                                            local currentItems = use(items)
                                            if #currentItems > 1 then
                                                return { "Can't buy" }
                                            elseif #currentItems == 1 then
                                                local id = currentItems[1].Name
                                                local meta = Metadata[id]
                                                return { `Buy for {MoneyLib.HandleMoney(meta.Price)}` }
                                            else
                                                return { 'Buy' }
                                            end
                                        end),
                                        ContentSize = 24,
                                    },

                                    onyx:Button {
                                        List = ListParameter,
                                        Disabled = onyx:Computed(function(use)
                                            local currentItems = use(items)
                                            if #currentItems > 1 then
                                                return true
                                            elseif #currentItems == 1 then
                                                local id = currentItems[1].Name
                                                local meta = Metadata[id]
                                                return not meta.CanBeSold
                                            else
                                                return true
                                            end
                                        end),
                                        Size = UDim2.fromScale(1, 0),
                                        Color = Theme.Colors.Base.Main,
                                        Content = onyx:Computed(function(use)
                                            local currentItems = use(items)
                                            if #currentItems > 1 then
                                                return { "Can't sell" }
                                            elseif #currentItems == 1 then
                                                local id = currentItems[1].Name
                                                local meta = Metadata[id]
                                                return { `Sell for {MoneyLib.HandleMoney(meta.Price / 2)}` }
                                            else
                                                return { 'Sell' }
                                            end
                                        end),
                                        ContentSize = 24,
                                    },
                                    onyx:Button {
                                        List = ListParameter,
                                        Size = UDim2.fromScale(1, 0),
                                        Color = Theme.Colors.Base.Main,
                                        Content = { 'Move Item' },
                                        ContentSize = 24,
                                    },
                                    onyx:Button {
                                        List = ListParameter,
                                        Size = UDim2.fromScale(1, 0),
                                        Color = Theme.Colors.Base.Main,
                                        Content = { 'Withdraw Item' },
                                        ContentSize = 24,
                                    },
                                },
                            },
                        },
                    },
                },
            }
        end)
    end
    return {
        UI = UI,
        Billboard = Billboard,
        SelectedItems = items,
        IsOpened = isOpened,
        IsHovering = isHovering,
        Scope = scope,
    }
end
