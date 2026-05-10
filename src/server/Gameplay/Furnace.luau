local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local GameEnum = require(ReplicatedStorage.Shared.GameEnum)
local Ore = require(script.Parent.Ore)
local Metadata = require(ReplicatedStorage.Shared.Metadata)

local Furnace = {}
Furnace.__index = Furnace

local Ores = {}

local function init(self)
    self.FurnacePart.Touched:Connect(function(orePart: BasePart)
        local oreData = Ore.GetOreData(orePart)
        if not oreData then
            return
        end

        if Ores[orePart] ~= nil then
            return
        end

        Ores[orePart] = true

        task.delay(0.5, function()
            -- pre-processing thing idk

            -- process the ore
            if self.Metadata.IsCellFurnace and oreData:SumUpgradeCount() > 0 then
                -- do not process the ore if it's cell furnace and the ore is upgraded
                oreData:Destroy()
            elseif self.Metadata.IsCellFurnace and oreData:SumUpgradeCount() == 0 then
                oreData:Upgrade('DefaultCellFurnaceMult', GameEnum.UpgradeOperation.Multiply, 20)
                oreData:Process()
            else
                oreData:Process()
            end

            -- post-processing thing
            Ores[orePart] = nil
        end)
    end)
end

local function register(source: Instance)
    local ownerId = source:GetAttribute('Owner')

    local self = setmetatable({
        Source = source,
        Metadata = Metadata[source.Name],
        FurnacePart = source:FindFirstChild('Furnace', true),
        OwnerId = ownerId,
        Owner = Players:GetPlayerByUserId(ownerId),
    }, Furnace)

    init(self)
    return self
end

return {
    Register = register,
}
