local Players = game:GetService('Players')
local StarterGui = game:GetService('StarterGui')
local AttachLoaderFrom = require(script.Parent.LazyLoader)
local player = Players.LocalPlayer

local Interface = {}
Interface.GuiContainer = Instance.new('ScreenGui')

local function SafeSetCoreGui(CoreGuiType: Enum.CoreGuiType, enabled: boolean)
    local success, result = pcall(StarterGui.SetCoreGuiEnabled, StarterGui, CoreGuiType, enabled)
    if not success then
        warn(`CoreGui visibility cannot be set: {result}; retrying...`)
        task.wait(0.5)
        SafeSetCoreGui(CoreGuiType, enabled)
    end
end

function Interface.init()
    local container = Interface.GuiContainer
    container.Name = 'Interface'
    container.ResetOnSpawn = false
    container.IgnoreGuiInset = true
    container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    container.Parent = player:WaitForChild('PlayerGui')

    local containerValue = script.ContainerObject
    containerValue.Value = container

    Interface.GuiContainer = container
end

function Interface.SetCoreGuiEnabled(enabled: boolean)
    SafeSetCoreGui(Enum.CoreGuiType.PlayerList, enabled)
    SafeSetCoreGui(Enum.CoreGuiType.Chat, enabled)
    SafeSetCoreGui(Enum.CoreGuiType.EmotesMenu, enabled)
    SafeSetCoreGui(Enum.CoreGuiType.SelfView, enabled)
    SafeSetCoreGui(Enum.CoreGuiType.Captures, enabled)
    SafeSetCoreGui(Enum.CoreGuiType.AvatarSwitcher, enabled)
end

return AttachLoaderFrom(script, Interface)
