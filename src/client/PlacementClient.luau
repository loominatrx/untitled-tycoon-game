local ContextActionService = game:GetService('ContextActionService')
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Interface = require(ReplicatedStorage.Shared.Interface)
local PlacementModule = require(ReplicatedStorage.Shared.PlacementModule)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Prefabs = ReplicatedStorage.Shared.Prefabs

local COLOR_OK = Color3.fromRGB(13, 105, 172)
local COLOR_ERR = Color3.fromRGB(255, 80, 80)

local ACTION_PLACE = 'ACTION_PLACE'
local ACTION_ROTATE = 'ACTION_ROTATE'

local Plot = Remotes.Base.BaseLoaded.OnClientEvent:Wait()
local Placement = PlacementModule.new(Plot.Base)

local Camera = workspace.CurrentCamera

Remotes.Base.GridOccupied.OnClientEvent:Connect(function(x: number, z: number, sizeX: number, sizeZ: number)
    Placement:Occupy(x, z, sizeX, sizeZ)
end)

Remotes.Base.GridFreed.OnClientEvent:Connect(function(x: number, z: number, sizeX: number, sizeZ: number)
    Placement:Free(x, z, sizeX, sizeZ)
end)

local ClientPlacement = {}
ClientPlacement.__index = ClientPlacement

local function castMouse(): RaycastResult?
    local mouseLocation = UserInputService:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { Players.LocalPlayer.Character }
    params.FilterType = Enum.RaycastFilterType.Exclude
    return workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
end

function ClientPlacement:Update()
    local mouseHit = castMouse()
    self.MouseHit = mouseHit
    if mouseHit and mouseHit.Position then
        local preview = self.PreviewModel :: Model & { Hitbox: BasePart }
        local hitboxSize = preview.Hitbox.Size
        local hitboxOutline = preview.boxOutline :: SelectionBox

        local placementData = Placement:GetPlacement(mouseHit.Position, hitboxSize, self.ModelRotation)
        preview:PivotTo(placementData.CFrame)

        hitboxOutline.Color3 = if placementData.CanPlace then COLOR_OK else COLOR_ERR
    end
end

function ClientPlacement:Rotate()
    self.ModelRotation = (self.ModelRotation + 90) % 360
end

local function init(self)
    local preview = self.PreviewModel
    local boxOutline = Prefabs.boxOutline:Clone() :: SelectionBox
    boxOutline.Adornee = preview.Hitbox
    boxOutline.Parent = preview

    for _, part in preview:GetDescendants() do
        if part:IsA('BasePart') then
            part.CanCollide = false
            part.CanQuery = false
            part.LocalTransparencyModifier = if part.Name ~= 'Hitbox' then 0.5 else 1
        end
    end

    preview.Parent = workspace

    local function CAS_ACTION(actionName: string, inputState: Enum.UserInputState)
        if inputState ~= Enum.UserInputState.Begin then
            return
        end

        if actionName == ACTION_PLACE then
            Remotes.Base.PlaceObject:InvokeServer(self.ObjectName, self.MouseHit.Position, self.ModelRotation)
        elseif actionName == ACTION_ROTATE then
            self:Rotate()
        end
    end

    self.Trove:Connect(RunService.RenderStepped, function()
        self:Update()
    end)
    self.Trove:Add(function()
        ContextActionService:UnbindAction(ACTION_PLACE)
        ContextActionService:UnbindAction(ACTION_ROTATE)
    end)
    self.Trove:Add(function()
        self.GuiContainer:doCleanup()
        self.PlacementGui = nil
    end)

    ContextActionService:BindAction(ACTION_PLACE, CAS_ACTION, false, Enum.UserInputType.MouseButton1)
    ContextActionService:BindAction(ACTION_ROTATE, CAS_ACTION, false, Enum.KeyCode.R)
end

local function new(objectName: string)
    local previewModel = Prefabs:FindFirstChild(objectName, true)
    if previewModel == nil then
        error('Cannot find object in prefabs...')
    end

    local self = setmetatable({}, ClientPlacement)
    self.ObjectName = objectName
    self.PreviewModel = previewModel:Clone()
    self.ModelRotation = 0
    self.Trove = Trove.new()
    self.GuiContainer = Fusion:scoped()
    self.PlacmenetGui = Interface.Elements.PlacementTip(self.GuiContainer, Interface.GuiContainer)
    self.MouseHit = nil

    init(self)

    return self
end

return {
    new = new,
}
