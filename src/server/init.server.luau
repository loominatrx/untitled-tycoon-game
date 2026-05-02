local Players = game:GetService('Players')
local DataStore = require(script.DataStore)
local PlotManager = require(script.PlotManager)

local function onPlayerAdded(player: Player)
    local plot = PlotManager.SpawnPlot(player) :: Model
    local spawn = plot:WaitForChild('Spawn') :: SpawnLocation
    local teamColor = BrickColor.random()

    local team = Instance.new('Team')
    team.Name = `{player.Name}'s Warnet`
    team.Parent = game:GetService('Teams')
    team.TeamColor = teamColor

    player.Team = team
    spawn.TeamColor = teamColor

    DataStore.LoadData(player, 1):andThen(function(data)
        print(data)
        PlotManager.LoadLayout(player, 0)
    end)
end

local function onPlayerRemoving(player: Player)
    print('saving layout...')
    PlotManager.SaveLayout(player, 0)
    print('withdrawing all objects...')
    PlotManager.WithdrawAll(player)
    print('releasing plot...')
    PlotManager.ReleasePlot(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
