local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Interface = require(script.Parent.Parent)
local Types = require(ReplicatedStorage.Shared.Types)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local OnyxUI = require(ReplicatedStorage.Packages.OnyxUI)
local Themer = OnyxUI.Themer

local ThemeSpec = require(ReplicatedStorage.Shared.Interface.Theme)
local Metadata = require(ReplicatedStorage.Shared.Metadata)
local assets = require(ReplicatedStorage.Shared.assets)

local Children = Fusion.Children
local peek = Fusion.peek

return function(scope: Types.FusionScope, name: Types.FusionUsedAs<string>, size: number)
    local onyx = Interface.PopulateOnyx(scope) :: Types.Fusionyx
    local expanding = onyx:Value(false)
    
    name = OnyxUI.Util.EnsureValue(onyx, name)
    
    size = size - 4 or 200
    local expandedSize = size * 3
    
    local container
    Themer.Theme:is(ThemeSpec):during(function()
        local Theme = Themer.Theme:now()
        container = onyx:Frame {
            Size = onyx:Spring(onyx:Computed(function(use)
                return UDim2.fromOffset(if use(expanding) == true then expandedSize else size, size)
            end), Theme.SpringSpeed.Base, Theme.SpringDampening['2']),
            AnchorPoint = Vector2.one * 0.5,
            Position = UDim2.fromScale(0.5, 0.5),
            AutomaticSize = Enum.AutomaticSize.None,

            Padding = {
                Enabled = true,
                All = UDim.new(0, Theme.Padding['1'])
            },

            [Children] = {
                onyx:Button {
                    AutomaticSize = Enum.AutomaticSize.None,
                    Size = UDim2.fromScale(1, 1),
                    Style = 'Ghost',

                    OnActivate = function()
                        expanding:set(not peek(expanding))
                    end
                },
                onyx:Card {
                    ClipsDescendants = true,
                    Size = UDim2.fromScale(1, 1),
                    AutomaticSize = Enum.AutomaticSize.None,

                    [Children] = {
                        onyx:Frame {
                            AutomaticSize = Enum.AutomaticSize.None,
                            Size = UDim2.fromScale(1, 1),

                            List = {
                                FillDirection = Enum.FillDirection.Horizontal,
                                VerticalAlignment = Enum.VerticalAlignment.Top,
                                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                                SortOrder = Enum.SortOrder.LayoutOrder,
                            },

                            [Children] = {
                                onyx:Image {
                                    Size = UDim2.fromScale(1, 1),
                                    Image = onyx:Computed(function(use)
                                        return assets.Items[use(name)]
                                    end),
                                    AutomaticSize = Enum.AutomaticSize.None,
                                    Parent = container,

                                    Aspect = {
                                        Ratio = 1
                                    },

                                    Corner = {
                                        Radius = UDim.new(0, peek(Theme.CornerRadius['1']))
                                    }
                                },

                                onyx:Frame {
                                    AutomaticSize = Enum.AutomaticSize.None,
                                    Size = UDim2.new(0, (expandedSize / 1.5) - 16, 1, 0),
                                    Visble = false,
                                    
                                    List = {
                                        FillDirection = Enum.FillDirection.Vertical,
                                        VerticalAlignment = Enum.VerticalAlignment.Top,
                                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                                        SortOrder = Enum.SortOrder.LayoutOrder,
                                        Padding = UDim.new(0, -6)
                                    },

                                    [Children] = {
                                        onyx:Heading {
                                            Text = onyx:Computed(function(use)
                                                return Metadata[use(name)].FriendlyName
                                            end),
                                        },
                                        onyx:Divider {},
                                        onyx:Text {
                                            Text = onyx:Computed(function(use)
                                                return Metadata[use(name)].Description
                                            end),
                                            Flex = {
                                                Mode = Enum.UIFlexMode.Fill
                                            }
                                        },
                                        onyx:Frame {
                                            AutomaticSize = Enum.AutomaticSize.None,
                                            Size = UDim2.fromScale(1, 0.225),

                                            List = {
                                                FillDirection = Enum.FillDirection.Horizontal,
                                                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                                                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                                                SortOrder = Enum.SortOrder.LayoutOrder,
                                            },

                                            [Children] = {
                                                onyx:Button {
                                                    Style = 'Filled',
                                                    SizeVariant = 'ExtraLarge',
                                                    Color = Theme.Colors.Primary.Main,
                                                    Content = { '<b>Place</b>' }
                                                },

                                                onyx:Button {
                                                    Style = 'Filled',
                                                    SizeVariant = 'ExtraLarge',
                                                    Color = Theme.Colors.Accent.Main,
                                                    Content = { 'More info' }
                                                },
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    end)

    -- local thread = task.spawn(function()
    --     while true do
    --         task.wait(2)
    --         expanding:set(true)
    --         task.wait(2)
    --         expanding:set(false)
    --     end
    -- end)

    -- table.insert(onyx, function()
    --     task.cancel(thread)
    -- end)

    return container
end
