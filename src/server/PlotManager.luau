local ReplicatedStorage = game:GetService('ReplicatedStorage')
local PlotTemplate = game:GetService('ServerStorage').Prefabs.Plot
local Shared = ReplicatedStorage.Shared
local Prefabs = Shared.Prefabs
local PlacementModule = require(ReplicatedStorage.Shared.PlacementModule)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local DataStore = require(script.Parent.DataStore)

local Inventory = require(script.Parent.Inventory)
local Types = require(ReplicatedStorage.Shared.Types)

local plotManager = {}
local plots: { Types.Plot } = {}
local PlayerPlacementClass = {}

-- spawn pool

local PlotSpawns = workspace:WaitForChild('PlotSpawns')

local availablePlots = PlotSpawns:GetChildren()
local usedPlots: { BasePart } = {}

function plotManager.AssignPlot(player: Player): BasePart
    local plotSpawn = table.remove(availablePlots) :: BasePart
    usedPlots[player.UserId] = plotSpawn
    return plotSpawn
end

function plotManager.ReleasePlot(player: Player)
    local plot = plots[player.UserId]
    if not usedPlots[player.UserId] then
        return
    end

    plot:Destroy()
    plot = nil

    table.insert(availablePlots, plot)
    usedPlots[player.UserId] = nil

    PlayerPlacementClass[player.UserId]:Clear()
    PlayerPlacementClass[player.UserId] = nil
end

-- plot management

function plotManager.SpawnPlot(player: Player): Model?
    local assignedPlot: BasePart? = plotManager.AssignPlot(player)
    if assignedPlot == nil then
        player:Kick('Unable to find empty plot. Please rejoin.')
        return nil
    end

    local plot = PlotTemplate:Clone()
    plot.Name = `{player.Name}'s Plot`
    plot:PivotTo(assignedPlot.CFrame)
    plot.Parent = workspace.Plots
    plots[player.UserId] = plot

    PlayerPlacementClass[player.UserId] = PlacementModule.new(plot.Base.Position)

    return plot
end

function plotManager.GetPlot(player: Player): Types.Plot
    return plots[player.UserId]
end

function plotManager.WithdrawObject(player: Player, object: Model)
    local plot: Types.Plot = plotManager.GetPlot(player)
    local objects: Folder = plot.Objects

    if object.Parent == objects then
        object:Destroy()

        print('adding item to inventory')
        Inventory.AddItem(player, object.Name)
    end
end

function plotManager.WithdrawAll(player: Player)
    local plot = plotManager.GetPlot(player)
    local objects = plot.Objects:GetChildren()

    for _, obj in objects do
        plotManager.WithdrawObject(player, obj :: Model)
    end
end

function plotManager.GetSavedLayouts(player: Player)
    local data = DataStore.GetData(player)
    return data.SavedLayouts
end

function plotManager.GetSavedLayout(player: Player, index: number)
    return plotManager.GetSavedLayouts(player)[index]
end

function plotManager.LoadLayout(player: Player, index: number)
    assert(index >= 0 and index <= 5, 'unable to access the specified layout.')
    local plot = plotManager.GetPlot(player)
    local layout = plotManager.GetSavedLayout(player, index)

    -- for _, objectInfo in layout do
    --     local position = deserializeVector3(objectInfo.position)
    --     local rotation = deserializeVector3(objectInfo.rotation)

    --     local relativeCFrame = CFrame.new(position) * CFrame.Angles(rotation.X, rotation.Y, rotation.Z)
    --     local absoluteCFrame = plot:GetPivot():ToWorldSpace(relativeCFrame)

    --     plotManager.PlaceObject(player, objectInfo.name, absoluteCFrame)
    -- end

    Remotes.Base.BaseLoaded:FireClient(player, plot)
end

function plotManager.SaveLayout(player: Player, index: number)
    assert(index >= 0 and index <= 5, 'unable to access the specified layout.')
    local plot = plotManager.GetPlot(player)
    local layout = plotManager.GetSavedLayout(player, index)

    table.clear(layout)
    -- for _, object in plot.Objects:GetChildren() do
    --     if object:IsA('Model') then
    --         local objectCF = plot:GetPivot():ToObjectSpace(object:GetPivot())
    --         local info = {
    --             name = object.Name,
    --             position = serializeVector3(objectCF.Position),
    --             rotation = serializeVector3(Vector3.new(objectCF:ToOrientation())),
    --         }
    --         table.insert(layout, info)
    --     end
    -- end
end

-- object placement

function plotManager.PlaceObject(player: Player, name: string, targetCF: CFrame)
    local object: Model? = Prefabs:FindFirstChild(name, true)
    local plot = plotManager.GetPlot(player)

    if not object or not plot then
        return
    end

    -- if not Inventory.playerHasItem(player, name) then
    --     error(player.Name .. ' do not have the item.', 2)
    -- end

    local newObject = object:Clone()
    newObject:PivotTo(targetCF)

    print('success!')

    newObject:SetAttribute('Owner', player.UserId)
    newObject.Parent = plot.Objects
    -- Inventory.removeItem(player, name)
end

return plotManager
