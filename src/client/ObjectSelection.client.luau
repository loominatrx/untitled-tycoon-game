local CollectionService = game:GetService('CollectionService')
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Input = require(ReplicatedStorage.Packages.Input)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Interface = require(ReplicatedStorage.Shared.Interface)
local PlacementClient = script.Parent.PlacementClient
local isPlacementRunning = PlacementClient:WaitForChild('IsRunning')
local Camera = workspace.CurrentCamera

local Prefabs = ReplicatedStorage.Shared.Prefabs

local Mouse = Input.Mouse.new()

local currentHitbox = Prefabs.boxOutline:Clone()
local actionUI = Interface.Elements.ObjectActions(Fusion:scoped())

local isSelectMode = false

local function castMouse(): RaycastResult?
    local mouseLocation = UserInputService:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
    local hitboxes = CollectionService:GetTagged('ObjectHitboxes')
    local filteredHitboxes = TableUtil.Filter(hitboxes, function(hitbox): boolean
        return hitbox.Parent:GetAttribute('Owner') == Players.LocalPlayer.UserId
    end)

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = filteredHitboxes
    params.FilterType = Enum.RaycastFilterType.Include

    return workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
end

actionUI.SelectedItems.ValueAdded:Connect(function(object)
    local hitbox = Prefabs.boxOutline:Clone()
    hitbox.Parent = object
    hitbox.Adornee = object.Hitbox
end)

actionUI.SelectedItems.ValueRemoved:Connect(function(object)
    local hitbox = object.boxOutline
    hitbox:Destroy()
end)

Interface.Keybinds.MainKeybinds:AddKeybind {
    Name = 'Begin Drag Drag',
    Key = Enum.UserInputType.MouseButton1,
    Callback = function(state: Enum.UserInputState)
        if state == Enum.UserInputState.Begin then
            isSelectMode = true
            while Mouse:IsLeftDown() do
                local mouseHit = castMouse()
                if mouseHit and mouseHit.Instance then
                    actionUI.SelectedItems:add(mouseHit.Instance.Parent)
                end
                RunService.RenderStepped:Wait()
            end
            isSelectMode = false
        end
    end,
}

Interface.Keybinds.MainKeybinds:AddKeybind {
    Name = 'End Drag',
    Key = Enum.UserInputType.MouseButton1,
    Callback = function(state: Enum.UserInputState)
        if state == Enum.UserInputState.End then
            if actionUI.SelectedItems.Data[1] ~= nil then
                actionUI.IsOpened:set(true)
            end
        end
    end,
}

Interface.Keybinds.ObjectSelectionKeybind:AddKeybind {
    Name = 'Move',
    Key = Enum.KeyCode.R,
    Callback = function(state: Enum.UserInputState)
        if state ~= Enum.UserInputState.Begin then
            return
        end

        actionUI.MoveItems()
    end,
}

Interface.Keybinds.ObjectSelectionKeybind:AddKeybind {
    Name = 'Move',
    Key = Enum.KeyCode.Z,
    Callback = function(state: Enum.UserInputState)
        if state ~= Enum.UserInputState.Begin then
            return
        end

        actionUI.WithdrawItems()
    end,
}

function Update()
    local mouseHit = castMouse()
    local isRunning = isPlacementRunning:Invoke()
    if mouseHit and mouseHit.Instance and not isRunning then
        currentHitbox.Adornee = mouseHit.Instance
        currentHitbox.Parent = mouseHit.Instance
    else
        if Mouse:IsLeftDown() and not isSelectMode then
            actionUI.SelectedItems:clear()
        end

        currentHitbox.Adornee = nil
        currentHitbox.Parent = nil
    end
end

RunService.RenderStepped:Connect(Update)
