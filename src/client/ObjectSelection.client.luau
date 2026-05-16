local CollectionService = game:GetService('CollectionService')
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')

local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Camera = workspace.CurrentCamera

local Prefabs = ReplicatedStorage.Shared.Prefabs

local currentHitbox = nil

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

function Update()
    local mouseHit = castMouse()
    if mouseHit and mouseHit.Position then
        if currentHitbox == nil then
            currentHitbox = Prefabs.boxOutline:Clone()
        end

        currentHitbox.Adornee = mouseHit.Instance
        currentHitbox.Parent = mouseHit.Instance
    else
        if currentHitbox ~= nil then
            currentHitbox:Destroy()
            currentHitbox = nil
        end
    end
end

RunService.RenderStepped:Connect(Update)
