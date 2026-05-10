local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Ore = require(script.Parent.Ore)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Trove = require(ReplicatedStorage.Packages.Trove)
local GameEnum = require(ReplicatedStorage.Shared.GameEnum)
local Metadata = require(ReplicatedStorage.Shared.Metadata)
local Upgrader = {}
Upgrader.__index = Upgrader

function Upgrader:AttachUpgraderConnection(upgraderPart: BasePart)
    local upgraderColorOrig = upgraderPart.Color
    local darkerUpgraderColor = upgraderColorOrig:Lerp(Color3.new(), 0.6)
    upgraderPart.Touched:Connect(function(orePart: BasePart)
        local oreData = Ore.GetOreData(orePart)
        if not oreData then
            return
        end

        for id, data in self.Metadata.Upgrades do
            oreData:Upgrade(id, GameEnum.UpgradeOperation[data.Operation], data.Value)
        end

        if self.Metadata.ResetAllUpgradeCount == true then
            oreData:ResetAllUpgradeCount()
        else
            if oreData:GetUpgradeCount(self.Source) < self.Metadata.MaxUpgradeCount then
                oreData:AddUpgradeCount(self.Source)
            else
                -- beep boop
                upgraderPart.Color = darkerUpgraderColor
                task.wait(0.2)
                upgraderPart.Color = upgraderColorOrig
            end
        end
    end)
end

local function init(self)
    for _, part in self.ConveyorParts do
        part.AssemblyLinearVelocity = part.CFrame.LookVector * self.Metadata.ConveyorSpeed
    end

    for _, part in self.UpgraderParts do
        self:AttachUpgraderConnection(part)
    end
end

local function register(source: Instance)
    local ownerId = source:GetAttribute('Owner') :: number

    local self = setmetatable({
        Source = source,
        UpgraderParts = TableUtil.Filter(source:GetDescendants(), function(part)
            return part:IsA('BasePart') and part.Name == 'UpgraderPart'
        end),
        ConveyorParts = TableUtil.Filter(source:GetDescendants(), function(part)
            return part:IsA('BasePart') and part.Name == 'Conveyor'
        end),
        Metadata = Metadata[source.Name],
        Trove = Trove.new(),

        OwnerId = ownerId,
        Owner = Players:GetPlayerByUserId(ownerId),
    }, Upgrader)

    init(self)
    return self
end

return {
    Register = register,
}
