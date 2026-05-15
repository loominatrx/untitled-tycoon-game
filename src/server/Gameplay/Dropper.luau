local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Ore = require(script.Parent.Ore)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Metadata = require(ReplicatedStorage.Shared.Metadata)

local Dropper = {}
Dropper.__index = Dropper

function Dropper:SpawnOre()
    Ore.new(self.Source)
end

function Dropper:Update(dt)
    local rate = self.Metadata.DropRate

    self.Cooldown -= dt

    if self.Cooldown <= 0 then
        self.Cooldown = rate
        self:SpawnOre()
    end
end

local function init(self)
    self.Trove:Connect(RunService.Heartbeat, function(dt)
        self:Update(dt)
    end)

    -- auto-cleanup when the dropper destroyed
    self.Trove:Add(function()
        task.defer(function()
            self.Source = nil
            self.Owner = nil
            self.Metadata = nil
            self.Cooldown = nil
        end)
    end)

    -- attach to the the instance
    self.Trove:AttachToInstance(self.Source)
    print(`Dropper system initted for {tostring(self.Owner)}'s {self.Source.Name}`)
    print(self)
end

-- careful for giving the model wrong metadata to use, as it can cause confusion among players. use with caution.
local function register(model: Model)
    local metadata = Metadata[model.Name]

    local self = setmetatable({
        Source = model,
        Owner = model:GetAttribute('Owner') :: number,
        Metadata = metadata,
        Cooldown = metadata.DropRate,

        Trove = Trove.new(),
    }, Dropper)

    init(self)
    return self
end

return {
    Register = register,
}
