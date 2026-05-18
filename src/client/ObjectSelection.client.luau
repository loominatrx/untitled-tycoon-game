local CollectionService = game:GetService('CollectionService')
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Input = require(ReplicatedStorage.Packages.Input)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Interface = require(ReplicatedStorage.Shared.Interface)
local Camera = workspace.CurrentCamera

local Prefabs = ReplicatedStorage.Shared.Prefabs
local peek = Fusion.peek

local Mouse = Input.Mouse.new()

local currentHitbox = nil
local actionUI = Interface.Elements.ObjectActions(Fusion:scoped())

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

Interface.MainKeybinds:AddKeybind {
    Name = 'Select Items from Hitbox',
    Key = Enum.UserInputType.MouseButton1,
    Callback = function(state: Enum.UserInputState)
        if state == Enum.UserInputState.End then
            if peek(actionUI.SelectedItems)[1] ~= nil then
                actionUI.IsOpened:set(true)
            end
        end
    end,
}

function Update()
    local mouseHit = castMouse()
    if mouseHit and mouseHit.Position then
        if currentHitbox == nil then
            currentHitbox = Prefabs.boxOutline:Clone()
        end

        if not peek(actionUI.IsOpened) and peek(actionUI.SelectedItems)[1] ~= mouseHit.Instance.Parent then
            currentHitbox.Adornee = mouseHit.Instance
            currentHitbox.Parent = mouseHit.Instance
            actionUI.SelectedItems:set { mouseHit.Instance.Parent }
        end
    else
        if
            (not peek(actionUI.IsOpened) and peek(actionUI.SelectedItems)[1] ~= nil)
            or (Mouse:IsLeftDown() and peek(actionUI.IsHovering) == false)
        then
            if currentHitbox ~= nil then
                currentHitbox:Destroy()
                currentHitbox = nil
            end
            actionUI.SelectedItems:set {}
        end
    end
end

RunService.RenderStepped:Connect(Update)
