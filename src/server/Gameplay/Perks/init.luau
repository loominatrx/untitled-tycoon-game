local ServerScriptService = game:GetService('ServerScriptService')

local DataStore = require(ServerScriptService.Server.DataStore)
local PlayerPerks = {}
PlayerPerks.__index = PlayerPerks

local Perks = {}

function PlayerPerks:GetActivePerks() end

function PlayerPerks:AddPerk() end

function PlayerPerks:RemovePerk() end

function PlayerPerks:ResetPerks() end

function PlayerPerks:RunHook(hookName, ...: any) end

local function GetPerkData() end

local function new(player: Player)
    local self = setmetatable({
        Player = player,
        ActivePerks = DataStore.GetData(player).ActivePerks,
    }, PlayerPerks)

    Perks[player] = self

    return self
end

local function GetPlayerPerk(player)
    return Perks[player]
end

return {
    new = new,
    GetPlayerPerk = GetPlayerPerk,
}
