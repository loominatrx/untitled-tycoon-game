local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Keybinds = require(ReplicatedStorage.Shared.Keybinds)
return {
    MainKeybinds = Keybinds:CreateNewKeybindGroup {
        Name = 'MainKeybinds',
        Enabled = true,
        IsGameProcessed = false,
    },

    ObjectSelectionKeybind = Keybinds:CreateNewKeybindGroup {
        Name = 'ObjectSelectionKeybind',
        Enabled = false,
        IsGameProcessed = false,
    },
}
