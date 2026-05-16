local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local DataStore = require(script.DataStore)
local Perks = require(script.Gameplay.Perks)
local PlotManager = require(script.PlotManager)

local function onPlayerAdded(player: Player)
    local plot = PlotManager.SpawnPlot(player) :: Model
    local spawn = plot:WaitForChild('Spawn') :: SpawnLocation
    local teamColor = BrickColor.random()

    local team = Instance.new('Team')
    team.Name = `{player.Name}'s Tycoon`
    team.Parent = game:GetService('Teams')
    team.TeamColor = teamColor

    player.Team = team
    spawn.TeamColor = teamColor

    DataStore.LoadData(player, 1):andThen(function(data)
        print(data)
        Perks.init(player)
        PlotManager.LoadLayout(player, 0)
        Remotes.Base.BaseLoaded:FireClient(player, plot)
    end)
end

local function onPlayerRemoving(player: Player)
    print('saving layout...')
    PlotManager.SaveLayout(player, 0)
    print('withdrawing all objects...')
    PlotManager.WithdrawAll(player)
    print('releasing plot...')
    PlotManager.ReleasePlot(player)
    DataStore.ReleaseData(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
