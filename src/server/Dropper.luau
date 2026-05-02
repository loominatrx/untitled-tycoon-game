local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Types = require(ReplicatedStorage.Shared.Types)

local Dropper = {}
Dropper.__index = Dropper

function Dropper:SpawnOre()
    local dropper = self.Instance
    local owner = self.Owner

    local oreTemplate = dropper:FindFirstChild("OreTemplate")
    if not oreTemplate then return end

    local ore = oreTemplate:Clone()
    ore.CFrame = dropper.PrimaryPart.CFrame * CFrame.new(0, -2, 0)

    -- basic ore data
    ore:SetAttribute("BaseValue", self.Metadata.OreValue)
    ore:SetAttribute("Owner", owner)

    ore.Parent = workspace.Ores

    CollectionService:AddTag(ore, "Ore")
end

function Dropper:Update(dt)
    local rate = self.Metadata.DropRate

    self.Cooldown -= dt

    if self.Cooldown <= 0 then
        self.Cooldown = rate
        self:SpawnOre()
    end
end

local function init(self)
    self.Trove:Connect(RunService.Heartbeat, function(dt)
        self:Update(dt)
    end)

    -- auto-cleanup when the dropper destroyed
    self.Trove:Add(function()
        task.defer(function()
            self.Instance = nil
            self.Owner = nil
            self.Metadata = nil
            self.Cooldown = nil
        end)
    end)

    -- attach to the the instance
    self.Trove:AttachToInstance(self.Instance)
end

-- careful for giving the model wrong metadata to use, as it can cause confusion among players. use with caution.
local function register(model: Model, metadata: Types.DropperMetadata)
    local self = {}
    self.Instance = model
    self.Owner = model:GetAttribute('Owner') :: number
    self.Metadata = metadata
    self.Cooldown = metadata.DropRate

    self.Trove = Trove.new()

    return init(setmetatable(self, Dropper))
end

return {
    Register = register
}
