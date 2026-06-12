local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local PlacementClient = Players.LocalPlayer.PlayerScripts.Client.PlacementClient

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local OnyxUI = require(ReplicatedStorage.Packages.OnyxUI)
local Interface = require(ReplicatedStorage.Shared.Interface)
local Metadata = require(ReplicatedStorage.Shared.Metadata)
local MoneyLib = require(ReplicatedStorage.Shared.MoneyLib)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Tracker = require(ReplicatedStorage.Shared.Tracker)
local Types = require(ReplicatedStorage.Shared.Types)

local Themer = OnyxUI.Themer
local ThemeSpec = Interface.Theme

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
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
    local onyx = Interface.Utils.Helper.PopulateOnyx(scope)
    local isOpened = onyx:Value(false)
    local isHovering = onyx:Value(false)
    local items = Tracker.new {}
    local amountOfSelectedItems = onyx:Value(0)

    items.SetChanged:Connect(function(newData)
        amountOfSelectedItems:set(#newData)
        if #newData == 0 then
            isOpened:set(false)
        end
    end)

    onyx:Observer(isOpened):onBind(function()
        local current = peek(isOpened)
        Interface.Keybinds.MainKeybinds:SetEnabled(not current)
        Interface.Keybinds.ObjectSelectionKeybind:SetEnabled(current)

        if current == true then
            Interface.DisableInterfaces()
        end
    end)

    onyx:Observer(isHovering):onBind(function()
        print(`isHovering: {peek(isHovering)}`)
    end)

    -- functions
    local function move()
        local item = items.Data[1]
        items:clear()
        Remotes.Base.WithdrawObject:InvokeServer(item)
        PlacementClient.New:Fire(item.Name)
    end

    local function withdraw()
        for _, item in items.Data do
            Remotes.Base.WithdrawObject:InvokeServer(item)
        end
        items:clear()
    end

    local UI
    do
        Themer.Theme:is(ThemeSpec):during(function()
            local Theme = Themer.Theme:now()
            UI = onyx:Frame {
                AutomaticSize = Enum.AutomaticSize.None,
                Active = true,
                AnchorPoint = Vector2.one,
                Position = UDim2.new(0.95, 0, 0.95, -12),
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
                Visible = isOpened,
                Parent = Interface.GuiContainer,

                ClipsDescendants = true,

                [OnEvent('MouseEnter')] = function()
                    isHovering:set(true)
                end,

                [OnEvent('MouseLeave')] = function()
                    isHovering:set(false)
                end,

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
                                            local currentSelectedCount = use(amountOfSelectedItems)
                                            if currentSelectedCount > 1 then
                                                return 'Multiple items selected'
                                            elseif currentSelectedCount == 1 then
                                                local id = items.Data[1].Name
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
                                            local currentSelectedCount = use(amountOfSelectedItems)
                                            if currentSelectedCount > 1 then
                                                return `{currentSelectedCount} items`
                                            elseif currentSelectedCount == 1 then
                                                local id = items.Data[1].Name
                                                local meta = Metadata[id]
                                                return meta.ItemTier or id
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
                                            local currentSelectedCount = use(amountOfSelectedItems)
                                            if currentSelectedCount > 1 then
                                                return true
                                            elseif currentSelectedCount == 1 then
                                                local id = items.Data[1].Name
                                                local meta = Metadata[id]
                                                return not meta.OnSale
                                            else
                                                return true
                                            end
                                        end),
                                        Size = UDim2.fromScale(1, 0),
                                        Color = Theme.Colors.Base.Main,
                                        Content = onyx:Computed(function(use)
                                            local currentSelectedCount = use(amountOfSelectedItems)
                                            if currentSelectedCount > 1 then
                                                return { "Can't buy" }
                                            elseif currentSelectedCount == 1 then
                                                local id = items.Data[1].Name
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
                                            local currentSelectedCount = use(amountOfSelectedItems)
                                            if currentSelectedCount > 1 then
                                                return true
                                            elseif currentSelectedCount == 1 then
                                                local id = items.Data[1].Name
                                                local meta = Metadata[id]
                                                return not meta.CanBeSold
                                            else
                                                return true
                                            end
                                        end),
                                        Size = UDim2.fromScale(1, 0),
                                        Color = Theme.Colors.Base.Main,
                                        Content = onyx:Computed(function(use)
                                            local currentSelectedCount = use(amountOfSelectedItems)
                                            if currentSelectedCount > 1 then
                                                return { "Can't sell" }
                                            elseif currentSelectedCount == 1 then
                                                local id = items.Data[1].Name
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
                                        OnActivate = move,
                                    },
                                    onyx:Button {
                                        List = ListParameter,
                                        Size = UDim2.fromScale(1, 0),
                                        Color = Theme.Colors.Base.Main,
                                        Content = { 'Withdraw Item' },
                                        ContentSize = 24,
                                        OnActivate = withdraw,
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
        SelectedItems = items,
        IsOpened = isOpened,
        IsHovering = isHovering,
        Scope = scope,

        MoveItems = move,
        WithdrawItems = withdraw,
    }
end
