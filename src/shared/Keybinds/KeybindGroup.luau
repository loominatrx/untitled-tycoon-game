--!strict

local Trove = require(game:GetService('ReplicatedStorage').Packages.Trove)
local Keybind = require(script.Parent:WaitForChild('Keybind'))

local __keybindgroups = {}

----------------------

local KeybindGroup = {}
KeybindGroup.__index = KeybindGroup

export type KeybindGroupConfiguration = {
    Name: string,

    Enabled: boolean?,
    IsGameProcessed: boolean?,
}

export type KeybindGroup = KeybindGroupConfiguration & {
    __Trove: typeof(Trove.new()),
    __Keybinds: { Keybind.Keybind },
} & typeof(KeybindGroup)

-----------------------

function KeybindGroup:AddKeybind(keybindConfig: Keybind.KeybindConfiguration): Keybind.Keybind
    local keybind = Keybind.new(keybindConfig)

    keybind.Enabled = self.Enabled
    keybind.IsGameProcessed = self.IsGameProcessed

    table.insert(self.__Keybinds, keybind)

    return keybind
end

function KeybindGroup:AddKeybinds(configs: { Keybind.KeybindConfiguration })
    for _, config in configs do
        self:AddKeybind(config)
    end
end

function KeybindGroup:GetKeybind(keybindName: string): Keybind.Keybind?
    for _, keybind: Keybind.Keybind in self.__Keybinds do
        if keybind.Name == keybindName then
            return keybind
        end
    end
    return nil
end

function KeybindGroup:GetKeybinds(): { Keybind.Keybind }
    return self.__Keybinds
end

function KeybindGroup:RemoveKeybind(keybindName: string)
    for index: number, keybind in self:GetKeybinds() do
        if keybind.Name == keybindName then
            table.remove(self.__Keybinds, index)
            keybind:Destroy()
            break
        end
    end
end

function KeybindGroup:RemoveKeybinds(...: string)
    local names: { string } = table.pack(...)
    for _, name in names do
        self:RemoveKeybind(name)
    end
end

function KeybindGroup:RemoveAllKeybinds()
    for _, keybind in self:GetKeybinds() do
        keybind:Destroy()
    end
    table.clear(self.__Keybinds)
end

function KeybindGroup:SetEnabled(enabled: boolean)
    self.Enabled = enabled
    for _, keybind: Keybind.Keybind in self:GetKeybinds() do
        keybind.Enabled = self.Enabled
    end
end

function KeybindGroup:SetIsGameProcessed(enabled: boolean)
    self.IsGameProcessed = enabled
    for _, keybind: Keybind.Keybind in self:GetKeybinds() do
        keybind.IsGameProcessed = self.IsGameProcessed
    end
end

function KeybindGroup:Destroy()
    self:RemoveAllKeybinds()
    self.__Trove:Destroy()
    self.Name = nil
    self.Enabled = nil
    self.IsGameProcessed = nil
end

local constructor = {}
function constructor.new(config: KeybindGroupConfiguration): KeybindGroup
    local self = {
        -- Internal object, DNI.
        __Trove = Trove.new(),
        __Keybinds = {},

        Name = config.Name,

        Enabled = config.Enabled or true,
        IsGameProcessed = config.IsGameProcessed or false,
    }

    setmetatable(self, KeybindGroup)
    __keybindgroups[config.Name] = self

    return self :: any
end

function constructor.GetKeybindGroupFromName(name: string)
    return __keybindgroups[name]
end

return constructor
