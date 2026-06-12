local ReplicatedStorage = game:GetService('ReplicatedStorage')
local StarterGui = game:GetService('StarterGui')
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local OnyxUI = require(ReplicatedStorage.Packages.OnyxUI)
local Types = require(ReplicatedStorage.Shared.Types)
local Helper = {}

local function SafeSetCoreGui(CoreGuiType: Enum.CoreGuiType, enabled: boolean)
    local success, result = pcall(StarterGui.SetCoreGuiEnabled, StarterGui, CoreGuiType, enabled)
    if not success then
        warn(`CoreGui visibility cannot be set: {result}; retrying...`)
        task.wait(0.5)
        SafeSetCoreGui(CoreGuiType, enabled)
    end
end

function Helper.PopulateOnyx(scope: Types.FusionScope)
    return Fusion.innerScope(scope, Fusion, OnyxUI.Util, OnyxUI.Components) :: Types.Fusionyx
end

function Helper.SetCoreGuiEnabled(enabled: boolean)
    SafeSetCoreGui(Enum.CoreGuiType.PlayerList, enabled)
    SafeSetCoreGui(Enum.CoreGuiType.Chat, enabled)
    SafeSetCoreGui(Enum.CoreGuiType.EmotesMenu, enabled)
    SafeSetCoreGui(Enum.CoreGuiType.SelfView, enabled)
    SafeSetCoreGui(Enum.CoreGuiType.Captures, enabled)
    SafeSetCoreGui(Enum.CoreGuiType.AvatarSwitcher, enabled)
end

return Helper
