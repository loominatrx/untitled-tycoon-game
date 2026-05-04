local ReplicatedStorage = game:GetService('ReplicatedStorage')

local FusionTypes = require(ReplicatedStorage.Packages._Index['elttob_fusion@0.3.0'].fusion.Types)

export type FusionScope = FusionTypes.Scope<FusionTypes.Fusion>
export type FusionProperties = FusionTypes.PropertyTable

export type FusionValue = FusionTypes.Value<any>

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

export type DropperMetadata = ItemMetadata & DropperStats

--> inventory items
export type InventoryItems = Dictionary<string, number>

return {}
