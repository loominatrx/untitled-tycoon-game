local ReplicatedStorage = game:GetService('ReplicatedStorage')

local GameEnum = require(ReplicatedStorage.Shared.GameEnum)
local Modifier = {}
Modifier.__index = Modifier

type ModifierData = {
    Id: string,
    Operation: string,
    Value: number,
}

function Modifier:Add(id: string, value: number)
    table.insert(self.Mods, {
        Id = id,
        Operation = GameEnum.UpgradeOperation.Add,
        Value = value,
    })
end

function Modifier:Multiply(id: string, value: number)
    table.insert(self.Mods, {
        Id = id,
        Operation = GameEnum.UpgradeOperation.Multiply,
        Value = value,
    })
end

function Modifier:ClearModifiers()
    table.clear(self.Mods)
end

function Modifier:Get()
    local value = self.Base

    for _, data: ModifierData in pairs(self.Mods) do
        if data.Operation == GameEnum.UpgradeOperation.Add then
            value += data.Value
        elseif data.Operation == GameEnum.UpgradeOperation.Multiply then
            value *= data.Value
        end
    end

    return value
end

return {
    new = function(baseValue: number)
        return setmetatable({
            Base = baseValue,
            Mods = {},
        }, Modifier)
    end,
}
