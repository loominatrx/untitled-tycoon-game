local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService('StarterGui')

local Keybinds = require(script.Parent.Keybinds)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local OnyxUI = require(ReplicatedStorage.Packages.OnyxUI)
local AttachLoaderFrom = require(script.Parent.LazyLoader)
local Types = require(script.Parent.Types)
local player = Players.LocalPlayer

local Interface = {} :: any
Interface.GuiContainer = Instance.new('ScreenGui')
Interface.MainScope = Fusion:scoped()
Interface.Scopes = {
    Inventory = nil,
    Shop = nil,
}

local function SafeSetCoreGui(CoreGuiType: Enum.CoreGuiType, enabled: boolean)
    local success, result = pcall(StarterGui.SetCoreGuiEnabled, StarterGui, CoreGuiType, enabled)
    if not success then
        warn(`CoreGui visibility cannot be set: {result}; retrying...`)
        task.wait(0.5)
        SafeSetCoreGui(CoreGuiType, enabled)
    end
end

-- Keybinds

local MainKeybinds = Keybinds:CreateNewKeybindGroup({
    Name = 'MainKeybinds',
    Enabled = false,
    IsGameProcessed = false
})

MainKeybinds:AddKeybind({
    Key = Enum.KeyCode.E,
    Callback = function(state: Enum.UserInputState)
        if state ~= Enum.UserInputState.Begin then
            return
        end
        
        Interface.ToggleInventory()
    end
})

-- Public methods

function Interface.init()
    local container = Interface.GuiContainer
    container.Name = 'Interface'
    container.ResetOnSpawn = false
    container.IgnoreGuiInset = true
    container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    container.Parent = player:WaitForChild('PlayerGui')

    Interface.GuiContainer = container
end

function Interface.PopulateOnyx(scope: Types.FusionScope)
    return Fusion.innerScope(scope, Fusion, OnyxUI.Util, OnyxUI.Components) :: Types.Fusionyx
end

function Interface.SetCoreGuiEnabled(enabled: boolean)
    SafeSetCoreGui(Enum.CoreGuiType.PlayerList, enabled)
    SafeSetCoreGui(Enum.CoreGuiType.Chat, enabled)
    SafeSetCoreGui(Enum.CoreGuiType.EmotesMenu, enabled)
    SafeSetCoreGui(Enum.CoreGuiType.SelfView, enabled)
    SafeSetCoreGui(Enum.CoreGuiType.Captures, enabled)
    SafeSetCoreGui(Enum.CoreGuiType.AvatarSwitcher, enabled)
end

function Interface.ToggleInventory()
    if Interface.Scopes.Inventory == nil then
        Interface.Scopes.Inventory = Interface.MainScope:innerScope()
        Interface.Elements.Inventory(Interface.Scopes.Inventory).Parent = Interface.GuiContainer
    else
        Interface.Scopes.Inventory:doCleanup()
        Interface.Scopes.Inventory = nil
    end
end

return AttachLoaderFrom(script, Interface)
