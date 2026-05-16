local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local PerkData = require(script.PerkData)
local PerkStats = require(script.PerkStats)
local GameEnum = require(ReplicatedStorage.Shared.GameEnum)
local Types = require(ReplicatedStorage.Shared.Types)
local DataStore = require(ServerScriptService.Server.DataStore)
local PlayerPerks = {}
PlayerPerks.__index = PlayerPerks

local Perks = {}

function PlayerPerks:GetActivePerks() end

function PlayerPerks:AddPerk() end

function PlayerPerks:RemovePerk() end

function PlayerPerks:ResetPerks() end

-- should be only called when player is about to leave.
function PlayerPerks:SavePerks() end

local function __runHook(statsList, hookEnum: GameEnum.PerkHooks, context: any)
    for statsEnum, statsValue in statsList or {} do
        local stats = PerkStats[statsEnum]
        local hookFn = stats and stats.Hooks and stats.Hooks[hookEnum]

        print(statsEnum, statsValue, hookFn)

        if hookFn ~= nil then
            hookFn(context, statsValue)
        end
    end
end

function PlayerPerks:RunHook(hookEnum: GameEnum.PerkHooks, context: any)
    local activePerks = self.ActivePerks
    for _, perkData in ipairs(activePerks or {}) do
        __runHook(perkData.Buffs, hookEnum, context)
        __runHook(perkData.Debuffs, hookEnum, context)
    end
end

local function GetPerkData(perkName: string)
    return PerkData[perkName]
end

local function processSavedPerks(player: Player): ()
    local playerActivePerks = DataStore.GetData(player).ActivePerks
    local result = {}

    for _, data: Types.SavedPerk in playerActivePerks do
        local perk = GetPerkData(data.Name)

        local buffs = {}
        for i, buffValue in data.Buffs do
            local buffData = perk.PerkStats.Buffs[i]
            buffs[buffData[1]] = math.clamp(buffValue, buffData[2].Min, buffData[2].Max)
        end

        local debuffs = {}
        for i, debuffValue in data.Debuffs do
            local debuffData = perk.PerkStats.Debuffs[i]
            debuffs[debuffData[1]] = math.clamp(debuffValue, debuffData[2].Min, debuffData[2].Max)
        end

        table.insert(result, {
            Name = data.Name,
            Buffs = buffs,
            Debuffs = debuffs,
        })
    end

    return result
end

local function init(player: Player)
    if Perks[player] ~= nil then
        warn(`{player.Name}'s perk data has been initialized. Aborting...`)
        return
    end

    local self = setmetatable({
        Player = player,
        ActivePerks = processSavedPerks(player),
    }, PlayerPerks)

    print(self.ActivePerks)

    Perks[player] = self

    return self
end

local function GetPlayerPerk(player)
    return Perks[player]
end

return {
    init = init,
    GetPlayerPerk = GetPlayerPerk,
}
