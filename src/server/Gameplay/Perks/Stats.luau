local ReplicatedStorage = game:GetService('ReplicatedStorage')

local GameEnum = require(ReplicatedStorage.Shared.GameEnum)
return {
    ['OreWealth'] = {
        Name = 'Ore Wealth',
        Description = "Increases ore's base value.",
        Values = {
            [1] = 5,
            [2] = 10,
            [3] = 22,
            [4] = 30,
            [5] = 38,
            [6] = 42,
            [7] = 50,
            [8] = 58,
            [9] = 62,
            [10] = 68,
        },
        Hooks = {
            [GameEnum.PerkHooks.OnOreSpawn] = function(ore)
                ore:Upgrade('OreWealthPerk', GameEnum.UpgradeOperation.Multiply, 1.5)
            end,
        },
    },
}
