local Leaderboard = {}

function Leaderboard.CreateLeaderstats(player: Player)
    local leaderstats = Instance.new('Folder')
    leaderstats.Name = 'leaderstats'
    leaderstats.Parent = player

    return leaderstats
end

function Leaderboard.CreateLeaderboard(
    player: Player,
    name: string,
    valueType: 'StringValue' | 'NumberValue' | 'IntValue',
    value: number | string
)
    local leaderstats = player:FindFirstChild('leaderstats')
    if not leaderstats then
        leaderstats = Leaderboard.CreateLeaderstats(player)
    end

    local valueObject = Instance.new(valueType) :: ValueBase
    valueObject.Name = name
    valueObject.Value = value
    valueObject.Parent = leaderstats

    return valueObject
end

function Leaderboard.UpdateLeaderboard(player: Player, name: string, updatedValue: number | string)
    local leaderstats = player:FindFirstChild('leaderstats')
    if not leaderstats then
        error(`cannot update value, as leaderstats is not initialized for player {player.Name}.`)
    end

    local valueObject = leaderstats:FindFirstChild(name) :: ValueBase?
    if not valueObject then
        error(`cannot update value, as leaderstats is not initialized for player {player.Name}.`)
    end

    valueObject.Value = updatedValue
end

function Leaderboard.GetLeaderboardValue(player: Player, name: string)
    local leaderstats = player:FindFirstChild('leaderstats')
    if not leaderstats then
        error(`cannot update value, as leaderstats is not initialized for player {player.Name}.`)
    end

    local valueObject = leaderstats:FindFirstChild(name) :: ValueBase?
    if not valueObject then
        error(`cannot update value, as leaderstats is not initialized for player {player.Name}.`)
    end

    return valueObject.Value
end

return Leaderboard
