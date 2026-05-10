local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local OnyxUI = require(ReplicatedStorage.Packages.OnyxUI)
local FusionTypes = require(ReplicatedStorage.Packages._Index['elttob_fusion@0.3.0'].fusion.Types)

export type FusionScope = FusionTypes.Scope<FusionTypes.Fusion>
export type FusionProperties = FusionTypes.PropertyTable
export type Fusionyx = typeof(Fusion.innerScope(Fusion.scoped(), Fusion, OnyxUI.Util, OnyxUI.Components))

export type FusionValue = FusionTypes.Value<any>
export type FusionUsedAs<T> = FusionTypes.UsedAs<T>

export type Dictionary<K = any, V = any> = { [K]: V }
export type Array<V = any> = Dictionary<number, V>

--> objects
export type Plot = Model & { Objects: Folder, Base: BasePart, Spawn: SpawnLocation }
export type LayoutData = { number | string }
export type Layout = { LayoutData }

export type ItemMetadata = {
    -- Generic descriptions
    FriendlyName: string,
    Description: string,

    -- Shop stats
    Price: number,
    OnSale: boolean,
    CanBeSold: boolean,

    -- Item stats
    ItemTier: number,
    ItemType: number,
}

export type DropperStats = {
    OreValue: number,
    DropRate: number,
    OreSize: number,
}

export type UpgraderTagData = {
    Operation: 'Add' | 'Multiply',
    Value: number,
}

export type UpgraderTags = { [string]: UpgraderTagData }

export type UpgraderStats = {
    ConveyorSpeed: number,
    Upgrades: UpgraderTags?,
    MaxUpgradeCount: number?,
    ResetAllUpgraderCount: boolean?,
}

export type FurnaceStats = {
    OreMultiplier: number?,
    IsCellFurnace: boolean?,
}

export type DropperMetadata = ItemMetadata & DropperStats
export type UpgraderMetadata = ItemMetadata & UpgraderStats

--> inventory items
export type InventoryItems = Dictionary<string, number>

return {}
