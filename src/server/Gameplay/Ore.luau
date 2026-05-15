local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local DataStore = require(ServerScriptService.Server.DataStore)
local GameEnum = require(ReplicatedStorage.Shared.GameEnum)
local Modifier = require(script.Parent.Modifier)
local Perks = require(script.Parent.Perks)
local Metadata = require(ReplicatedStorage.Shared.Metadata)

local Ore = {}
Ore.__index = Ore

local OreData = {}

local function hasHitOreLimit(player: Player)
    local counter = 0
    local maxLimit = DataStore.GetData(player).Options.OreLimit
    for _, data in OreData do
        if data.Owner == player then
            counter += 1
        end
    end

    if counter > maxLimit then
        return true
    end

    return false
end

function Ore:Upgrade(id: string, operator: GameEnum.UpgradeOperation, value: number)
    if operator == GameEnum.UpgradeOperation.Add then
        self.Value:Add(id, value)
    elseif operator == GameEnum.UpgradeOperation.Multiply then
        self.Value:Multiply(id, value)
    end
end

function Ore:AddUpgradeCount(upgrader: Instance)
    local upgraderName = upgrader.Name
    if self.UpgradeCount[upgraderName] == nil then
        self.UpgradeCount[upgraderName] = 0
    end

    self.UpgradeCount[upgraderName] += 1
end

function Ore:GetUpgradeCount(upgrader: Instance): number
    local upgraderName = upgrader.Name
    if self.UpgradeCount[upgraderName] == nil then
        self.UpgradeCount[upgraderName] = 0
    end

    return self.UpgradeCount[upgraderName]
end

function Ore:ResetUpgradeCount(upgrader: Instance)
    self.UpgradeCount[upgrader.Name] = 0
end

function Ore:ResetAllUpgradeCount()
    for k in self.UpgradeCount do
        self.UpgradeCount[k] = 0
    end
end

function Ore:SumUpgradeCount()
    local sum = 0
    for _, v in self.UpgradeCount do
        sum += v
    end
    return sum
end

function Ore:Process()
    -- add active perks here if implemented
    local worth = self.Value:Get()
    DataStore.AddMoney(self.Owner, worth)
    self:Destroy()
end

function Ore:Destroy()
    if self.OrePart ~= nil then
        OreData[self.OrePart] = nil

        self.Source = nil
        self.UpgradeCount = nil
        self.OwnerId = nil
        self.Owner = nil
        self.Value = nil

        self.OrePart:Destroy()
        self.OrePart = nil
    end
end

local function init(self)
    local dropper = self.Source
    local ore = self.OrePart

    local PlayerPerk = Perks.GetPlayerPerk(self.Owner)
    PlayerPerk:RunHook(GameEnum.PerkHooks.OnOreSpawn, self)

    ore:PivotTo(dropper.Drop:GetPivot() - Vector3.new(0, 1, 0))
    ore:SetAttribute('Owner', self.OwnerId)

    -- basic ore data
    ore.Parent = workspace.Ores
    OreData[ore] = self

    local hasTouchedBase = false
    local touchedConnection
    touchedConnection = ore.Touched:Connect(function(otherPart)
        if otherPart.Name == 'Base' and not hasTouchedBase then
            hasTouchedBase = true
            task.wait(2)
            touchedConnection:Disconnect()
            touchedConnection = nil
            self:Destroy()
        end
    end)
end

local function new(source: Instance)
    local ownerId = source:GetAttribute('Owner')
    local player = Players:GetPlayerByUserId(ownerId)

    if hasHitOreLimit(player) then
        return
    end

    local oreTemplate = source:FindFirstChild('OreTemplate')
    if not oreTemplate then
        -- fallback to default ore
        oreTemplate = ReplicatedStorage.Shared.Prefabs.GenericOre
    end

    local ore = oreTemplate:Clone()
    local metadata = Metadata[source.Name]

    local self = setmetatable({
        Source = source,
        OrePart = ore,
        UpgradeCount = {},
        OwnerId = ownerId,
        Owner = player,
        Value = Modifier.new(metadata.OreValue),
    }, Ore)

    init(self)
    return self
end

local function getOreDataFromOrePart(part: BasePart): typeof(new(Instance.new('Part')))
    return OreData[part]
end

return {
    new = new,
    GetOreData = getOreDataFromOrePart,
}
