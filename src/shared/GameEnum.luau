local ReplicatedStorage = game:GetService('ReplicatedStorage')
local EnumList = require(ReplicatedStorage.Packages.EnumList)

type EnumList = typeof(EnumList.new(...))

local Enums = {
    ItemPanelContext = EnumList.new('ItemPanelContext', {
        'Shop',
        'Inventory',
    }),
    ItemTier = EnumList.new('ItemTier', {
        'Common',
        'Uncommon',
        'Rare',
        'Super Rare',
        'Epic',
        'Unique',
        'Legendary',
        'Mythical',
        'Reborn',
        'Advanced Reborn',
        'Limited Reborn',
        'Squared Reborn',
        'RebornU',
        'Premium',
    }),
    ItemType = EnumList.new('ItemType', {
        'Droppers',
        'Upgraders',
        'Furnaces',
    }),
}

export type ItemPanelContext = typeof(Enums.ItemPanelContext)
export type ItemTier = typeof(Enums.ItemTier)

return Enums
