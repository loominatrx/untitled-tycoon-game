local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Signal = require(ReplicatedStorage.Packages.Signal)
local Types = require(script.Parent.Types)

local Set = {}
Set.__index = Set

-- Function to add an item to a set
function Set:add(item)
    local itemExists = table.find(self.Data, item)
    if itemExists then
        return
    end
    table.insert(self.Data, item)
    self.ValueAdded:Fire(item)
    self.SetChanged:Fire(self.Data)
end

-- Function to remove an item from a set
function Set:remove(item)
    table.remove(self.Data, table.find(self.Data, item))
    self.ValueRemoved:Fire(item)
    self.SetChanged:Fire(self.Data)
end

-- Function to check if a set contains an item
function Set:contains(item)
    return self.Data[item] == true
end

-- Function to output set as a comma-delimited list for debugging
function Set:output()
    local elems = {}
    for _, value in self.Data do
        table.insert(elems, tostring(value))
    end
    print(table.concat(elems, ', '))
end

function Set:clear()
    for _, value in self.Data do
        self:remove(value)
    end
    self.SetCleared:Fire()
end

return {
    new = function(items: Types.Array<any>)
        local newSet = {}
        for _, value in items or {} :: Types.Array<any> do
            table.insert(newSet, value)
        end
        return setmetatable({
            Data = newSet,
            ValueAdded = Signal.new(),
            ValueRemoved = Signal.new(),
            SetCleared = Signal.new(),
            SetChanged = Signal.new(),
        }, Set)
    end,
}
