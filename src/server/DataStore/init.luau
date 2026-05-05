local ProfileStore = require(game.ServerScriptService.Packages.ProfileStore)

-- The PROFILE_TEMPLATE table is what new profile "Profile.Data" will default to:
local PROFILE_TEMPLATE = require(script.Template)

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local Leaderboard = require(script.Parent.Leaderboard)
local Promise = require(ReplicatedStorage.Packages.Promise)
local MoneyLib = require(ReplicatedStorage.Shared.MoneyLib)

local PlayerStore = ProfileStore.New('TestStore', PROFILE_TEMPLATE)
local Profiles: { [Player]: typeof(PlayerStore:StartSessionAsync()) } = {}

-- if RunService:IsStudio() == true then
--     PlayerStore = PlayerStore.Mock
-- end

local DataManager = {}

function DataManager.LoadData(player: Player, saveIndex: number)
    return Promise.new(function(resolve, reject)
        -- Start a profile session for this player's data:

        local profile = PlayerStore:StartSessionAsync(`{player.UserId}#{saveIndex}`, {
            Cancel = function()
                return player.Parent ~= Players
            end,
        })

        -- Handling new profile session or failure to start it:

        if profile ~= nil then
            profile:AddUserId(player.UserId) -- GDPR compliance
            profile:Reconcile() -- Fill in missing variables from PROFILE_TEMPLATE (optional)

            profile.OnSessionEnd:Connect(function()
                Profiles[player] = nil
                player:Kick(`Profile session end - Please rejoin`)
            end)

            if player.Parent == Players then
                Profiles[player] = profile
                print(`Profile loaded for {player.DisplayName}!`)

                Leaderboard.CreateLeaderboard(
                    player,
                    'Money',
                    'StringValue',
                    MoneyLib.DealWithPoints(profile.Data.Money)
                )
                resolve(profile)
            else
                -- The player has left before the profile session started
                profile:EndSession()
            end
        else
            -- This condition should only happen when the Roblox server is shutting down
            player:Kick(`Profile load fail - Please rejoin`)
            reject('Profile load failed')
        end
    end)
end

-- Data returned by this method is writable. Please use it wisely.
function DataManager.GetProfile(player: Player)
    return Profiles[player]
end

-- Data returned by this method is writable. Please use it wisely.
function DataManager.GetData(player: Player)
    return Profiles[player].Data
end

function DataManager.GetMoney(player: Player)
    local data = DataManager.GetData(player)
    return data.Money
end

-- Very Dangerous
function DataManager.UpdateMoney(player: Player, money: number)
    local data = DataManager.GetData(player)
    data.Money = money
    Leaderboard.UpdateLeaderboard(player, 'Money', MoneyLib.HandleMoney(data.Money))
end

function DataManager.AddMoney(player: Player, amount: number)
    local currentMoney = DataManager.GetMoney(player)
    DataManager.UpdateMoney(player, currentMoney + amount)
end

function DataManager.SubtractMoney(player: Player, amount: number)
    DataManager.AddMoney(player, -math.abs(amount))
end

function DataManager.ReleaseData(player: Player)
    local profile = Profiles[player]
    if profile ~= nil then
        profile:EndSession()
    end
end

return DataManager
