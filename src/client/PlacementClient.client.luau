local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local Trove = require(ReplicatedStorage.Packages.Trove)
local PlacementModule = require(ReplicatedStorage.Shared.PlacementModule)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Prefabs = ReplicatedStorage.Shared.Prefabs

local TEST_SUBJECT = 'BasicConveyor'
local COLOR_OK = Color3.fromRGB(13, 105, 172)
local COLOR_ERR = Color3.fromRGB(255, 80, 80)

local Plot = Remotes.Base.BaseLoaded.OnClientEvent:Wait()
local Placement = PlacementModule.new(Plot.Base.Position)

local Camera = workspace.CurrentCamera

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
    if mouseHit and mouseHit.Position then
        local preview = self.PreviewModel :: Model & { Hitbox: BasePart }
        local hitboxSize = preview.Hitbox.Size
        local hitboxOutline = preview.boxOutline :: SelectionBox

        local placementData = Placement:GetPlacement(mouseHit, hitboxSize.X, hitboxSize.Z)
        preview:PivotTo(placementData.CFrame)
        -- print(placementData)

        hitboxOutline.Color3 = if placementData.CanPlace then COLOR_OK else COLOR_ERR
    end
end

local function init(self)
    local preview = self.PreviewModel
    local boxOutline = Prefabs.boxOutline:Clone() :: SelectionBox
    boxOutline.Adornee = preview
    boxOutline.Parent = preview

    for _, part in preview:GetDescendants() do
        if part:IsA('BasePart') then
            part.CanCollide = false
            part.CanQuery = false
            part.Transparency = if part.Name ~= 'Hitbox' then 0.5 else 1
        end
    end

    preview.Parent = workspace

    self.Trove:Connect(RunService.RenderStepped, function()
        self:Update()
    end)
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

    init(self)

    return self
end

new(TEST_SUBJECT)
