local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Promise = require(ReplicatedStorage.Packages.Promise)
local Metadata = require(ReplicatedStorage.Shared.Metadata)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

return {
    GetInventoryItems = function()
        return Promise.new(function(resolve, reject)
            local RF = Remotes.Inventory.GetOwnedItems
            local success, result = pcall(RF.InvokeServer, RF)
            if success then
                resolve(result)
            else
                reject(result)
            end
        end)
    end,

    DoesItemExist = function(name: string)
        return Metadata[name] ~= nil
    end,
}
