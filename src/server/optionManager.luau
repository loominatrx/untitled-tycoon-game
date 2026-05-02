local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Types = require(ReplicatedStorage.Shared.Types)
local dataMgr = require(script.Parent.dataMgr)
local optionManager = {}

function optionManager.getOptions(player: Player)
    return dataMgr.getData(player).options
end

function optionManager.setOptions(player: Player, options: Types.Dictionary<string, any>)
    for k, v in options do
        optionManager.setValue(player, k, v)
    end
end

function optionManager.getValue(player: Player, option: string)
    local data = dataMgr.getData(player)
    return data.options[option]
end

function optionManager.setValue(player: Player, option: string, value: any)
    local data = dataMgr.getData(player)
    data.options[option] = value
end

return optionManager
