--!strict

local Trove = require(game:GetService('ReplicatedStorage').Packages.Trove)
local UserInputService = game:GetService('UserInputService')

----------------------

local Keybind = {}
Keybind.__index = Keybind

export type KeybindConfiguration = {
    Name: string,
    Key: Enum.KeyCode | Enum.UserInputType,
    Callback: (Enum.UserInputState) -> (),

    Enabled: boolean?,
    IsGameProcessed: boolean?,
}

export type Keybind = KeybindConfiguration & {
    __Trove: typeof(Trove.new()),
} & typeof(Keybind)

-----------------------

function init(self: Keybind)
    self.__Trove:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if self.Enabled == false then
            return
        end
        if input.UserInputType == self.Key or input.KeyCode == self.Key then
            if gameProcessed ~= self.IsGameProcessed then
                return
            end
            self.Callback(Enum.UserInputState.Begin)
        end
    end))

    self.__Trove:Add(UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if self.Enabled == false then
            return
        end
        if input.UserInputType == self.Key or input.KeyCode == self.Key then
            if gameProcessed ~= self.IsGameProcessed then
                return
            end
            self.Callback(Enum.UserInputState.End)
        end
    end))
end

function Keybind:Destroy()
    self.__Trove:Clean()

    self.Name = nil
    self.Key = nil
    self.Callback = nil

    self.Enabled = nil
    self.IsGameProcessed = nil
end

local constructor = {}
function constructor.new(config: KeybindConfiguration): Keybind
    local self = {
        -- Internal object, DNI.
        __Trove = Trove.new(),

        Name = config.Name,
        Key = config.Key,
        Callback = config.Callback,

        Enabled = config.Enabled or true,
        IsGameProcessed = config.IsGameProcessed or false,
    }

    setmetatable(self, Keybind)
    init(self :: any)
    return self :: any
end

return constructor
