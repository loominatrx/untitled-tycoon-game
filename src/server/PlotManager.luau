local CollectionService = game:GetService('CollectionService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
local PlotTemplate = game:GetService('ServerStorage').Prefabs.Plot
local Shared = ReplicatedStorage.Shared
local Prefabs = Shared.Prefabs
local Furnace = require(ServerScriptService.Server.Gameplay.Furnace)
local Upgrader = require(ServerScriptService.Server.Gameplay.Upgrader)
local GameEnum = require(ReplicatedStorage.Shared.GameEnum)
local Metadata = require(ReplicatedStorage.Shared.Metadata)
local PlacementModule = require(ReplicatedStorage.Shared.PlacementModule)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local DataStore = require(script.Parent.DataStore)
local Dropper = require(script.Parent.Gameplay.Dropper)

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

    local onInstanceAdd = plot.Objects.ChildAdded:Connect(function(object)
        local objectMetadata = Metadata[object.Name]
        if objectMetadata.ItemType == GameEnum.ItemType.Droppers.Name then
            Dropper.Register(object)
        elseif objectMetadata.ItemType == GameEnum.ItemType.Upgraders.Name then
            Upgrader.Register(object)
        elseif objectMetadata.ItemType == GameEnum.ItemType.Furnaces.Name then
            Furnace.Register(object)
        end
    end)

    plot.Destroying:Connect(function()
        onInstanceAdd:Disconnect()
        onInstanceAdd = nil
    end)

    PlayerPlacementClass[player.UserId] = PlacementModule.new(plot.Base)

    return plot
end

function plotManager.GetPlot(player: Player): Types.Plot
    return plots[player.UserId]
end

function plotManager.WithdrawObject(player: Player, object: Model)
    local plot: Types.Plot = plotManager.GetPlot(player)
    local objects: Folder = plot.Objects
    local Placement = PlayerPlacementClass[player.UserId]

    if object.Parent == objects then
        local position = object:GetPivot().Position
        local hitboxSize = (object.PrimaryPart :: BasePart).Size

        local x, z = Placement:WorldToGrid(position)

        Placement:Free(x, z, hitboxSize.X, hitboxSize.Z)
        Remotes.Base.GridFreed:FireClient(player, x, z, hitboxSize.X, hitboxSize.Z)

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

function plotManager.GetSavedLayouts(player: Player): Types.Dictionary<string, Types.Layout>
    local data = DataStore.GetData(player)
    return data.SavedLayouts
end

function plotManager.GetSavedLayout(player: Player, index: number): Types.Layout
    return plotManager.GetSavedLayouts(player)[tostring(index)]
end

function plotManager.LoadLayout(player: Player, index: number)
    assert(index >= 0 and index <= 5, 'unable to access the specified layout.')
    local layout = plotManager.GetSavedLayout(player, index)
    local Placement = PlayerPlacementClass[player.UserId]

    for _, objectInfo in layout do
        local name = objectInfo[1] :: string
        local positionX, positionZ = objectInfo[2] :: number, objectInfo[3] :: number
        local rotation = objectInfo[4] :: number

        local absolutePosition = Placement:GridToWorld(positionX, positionZ)

        plotManager.PlaceObject(player, name, absolutePosition, rotation)
    end
end

function plotManager.SaveLayout(player: Player, index: number)
    assert(index >= 0 and index <= 5, 'unable to access the specified layout.')
    local plot = plotManager.GetPlot(player)
    local layout = plotManager.GetSavedLayout(player, index)
    local Placement = PlayerPlacementClass[player.UserId]

    table.clear(layout)
    for _, object in plot.Objects:GetChildren() do
        if object:IsA('Model') then
            local objectCF = object:GetPivot()
            local absoluteX, absoluteZ = Placement:WorldToGrid(objectCF.Position)
            local orientation = Vector3.new(objectCF:ToOrientation())

            local info = {
                object.Name,
                absoluteX,
                absoluteZ,
                math.round(math.deg(orientation.Y)),
            }

            print(info)
            table.insert(layout, info)
        end
    end
end

-- object placement

function plotManager.PlaceObject(player: Player, name: string, position: Vector3, rotation: number)
    local object: Model? = Prefabs:FindFirstChild(name, true)
    local plot = plotManager.GetPlot(player)
    local Placement = PlayerPlacementClass[player.UserId]

    if not object or not plot then
        return
    end

    -- if not Inventory.playerHasItem(player, name) then
    --     error(player.Name .. ' do not have the item.', 2)
    -- end

    local newObject = object:Clone()
    local hitbox = newObject.Hitbox
    local hitboxSize = hitbox.Size

    local PlacementData = Placement:GetPlacement(position, hitboxSize, rotation)
    if not PlacementData.CanPlace then
        return
    end

    newObject:PivotTo(PlacementData.CFrame)

    print('success!')

    Placement:Occupy(PlacementData.X, PlacementData.Z, hitboxSize.X, hitboxSize.Z)
    Remotes.Base.GridOccupied:FireClient(player, PlacementData.X, PlacementData.Z, hitboxSize.X, hitboxSize.Z)

    newObject:SetAttribute('Owner', player.UserId)
    newObject.Parent = plot.Objects
    CollectionService:AddTag(hitbox, 'ObjectHitboxes')

    -- Inventory.removeItem(player, name)
end

return plotManager
