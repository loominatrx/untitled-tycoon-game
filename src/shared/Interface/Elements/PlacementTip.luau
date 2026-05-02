local ReplicatedStorage = game:GetService('ReplicatedStorage')
-- local UserInputService = game:GetService('UserInputService')

local Interface = require(script.Parent.Parent)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Types = require(ReplicatedStorage.Shared.Types)

local Children = Fusion.Children

local SourceSans = Interface.Font.new('rbxasset://fonts/families/SourceSansPro.json')

-- local function addToCleanup(scope: Types.FusionScope, object: Instance | RBXScriptConnection)
--     table.insert(scope, function()
--         if typeof(object) == 'Instance' then
--             object:Destroy()
--         elseif typeof(object) == 'RBXScriptConnection' then
--             object:Disconnect()
--         end
--     end)
-- end

local function createTip(
    scope: Types.FusionScope,
    config: {
        key: Enum.KeyCode | Enum.UserInputType,
        action: string,
    }
)
    -- local key = config.key
    -- local isInputDown = scope:Value(false)
    -- local inputType = if key:IsA('KeyCode')
    --     then 'keyboard'
    --     elseif key:IsA('UserInputType') and key == Enum.UserInputType.MouseButton1 then 'mouse_left'
    --     elseif key:IsA('UserInputType') and key == Enum.UserInputType.MouseButton2 then 'mouse_right'
    --     elseif key:IsA('UserInputType') and key == Enum.UserInputType.MouseButton3 then 'mouse_wheel'
    --     -- elseif key:IsA('UserInputType') and key == Enum.UserInputType.Touch then
    --     --     'touch'
    --     else 'unknown'

    -- local imageId = if inputType == 'keyboard'
    --     then `{inputType}_{key.Name:lower()}`
    --     elseif inputType:match('^mouse') ~= nil then inputType
    --     else ''

    -- local function onInput(input: InputObject)
    --     local isDown = if input.UserInputState == Enum.UserInputState.Begin
    --         then true
    --         elseif input.UserInputState == Enum.UserInputState.End then false
    --         else nil

    --     if input.KeyCode == key or input.UserInputType == key then
    --         isInputDown:set(isDown)
    --     end
    -- end

    local tip = scope:New('Frame') {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0.1, 12),

        [Children] = {
            scope:New('UIListLayout') {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder,

                Padding = UDim.new(0.01, 4),
            },

            scope:New('UIFlexItem') {
                FlexMode = Enum.UIFlexMode.Fill,
            },

            scope:New('ImageLabel') {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                -- Image = scope:Computed(function(use)
                --     return (use(isInputDown) == true and inputAsset[`{imageId}_down`])
                --         or (use(isInputDown) == false and inputAsset[`{imageId}_up`])
                -- end),

                [Children] = {
                    scope:New('UIAspectRatioConstraint') {
                        AspectRatio = 1,
                    },
                },
            },

            scope:New('TextLabel') {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),

                Text = config.action,
                FontFace = SourceSans.SemiBold,
                TextScaled = true,
                TextColor3 = Color3.new(1, 1, 1),
                TextXAlignment = Enum.TextXAlignment.Left,

                [Children] = {
                    scope:New('UIFlexItem') {
                        FlexMode = Enum.UIFlexMode.Fill,
                    },

                    scope:New('UIPadding') {
                        -- PaddingLeft = UDim.new(0.05, 2),
                        PaddingRight = UDim.new(0.05, 2),
                        PaddingTop = UDim.new(0.05, 2),
                        PaddingBottom = UDim.new(0.05, 2),
                    },
                },
            },
        },
    }

    -- addToCleanup(scope, UserInputService.InputBegan:Connect(onInput))
    -- addToCleanup(scope, UserInputService.InputEnded:Connect(onInput))

    return tip
end

return function(scope: Types.FusionScope, parent: Instance?)
    return scope:New('Frame') {
        BackgroundTransparency = 0.5,
        BackgroundColor3 = Color3.new(),

        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0.025, 24, 0.975, -24),
        Size = UDim2.new(0.1, 120, 0.1, 105),

        Parent = parent,

        [Children] = {
            scope:New('UIAspectRatioConstraint') {
                AspectRatio = 280 / 210,
            },

            scope:New('UIListLayout') {
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder,

                Padding = UDim.new(0.01, 2),
            },

            scope:New('UIPadding') {
                PaddingLeft = UDim.new(0.05, 2),
                PaddingRight = UDim.new(0.05, 2),
                PaddingTop = UDim.new(0.05, 2),
                PaddingBottom = UDim.new(0.05, 2),
            },

            createTip(scope, {
                key = Enum.UserInputType.MouseButton1,
                action = 'Place Object',
            }),

            createTip(scope, {
                key = Enum.KeyCode.R,
                action = 'Rotate Object',
            }),

            createTip(scope, {
                key = Enum.KeyCode.F,
                action = 'Undo Placement',
            }),

            createTip(scope, {
                key = Enum.KeyCode.Q,
                action = 'Exit Placement',
            }),
        },
    }
end
