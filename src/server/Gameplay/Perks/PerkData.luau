local ReplicatedStorage = game:GetService('ReplicatedStorage')

local GameEnum = require(ReplicatedStorage.Shared.GameEnum)
return {
    Overclocked = {
        Name = 'Overclocked',
        Description = 'hell yeah',

        PerkStats = {
            Buffs = { { GameEnum.PerkBuffs.OreWealth, NumberRange.new(1, 6) } },
            Debuffs = { { GameEnum.PerkDebuffs.DropperJam, NumberRange.new(1, 4) } },
        },
    },
}
