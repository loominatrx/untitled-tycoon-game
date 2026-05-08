--!strict

local KeybindManager = {}
local KeybindGroup = require(script:WaitForChild('KeybindGroup'))
local Keybind = require(script:WaitForChild('Keybind'))

function KeybindManager:CreateNewKeybindGroup(config: KeybindGroup.KeybindGroupConfiguration): KeybindGroup.KeybindGroup
    return KeybindGroup.new(config)
end

function KeybindManager:CreateNewKeybind(config: Keybind.KeybindConfiguration): Keybind.Keybind
    return Keybind.new(config)
end

return KeybindManager
