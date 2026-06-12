local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Tracker = require(ReplicatedStorage.Shared.Tracker)
local items = Tracker.new { 'Yeah', 'Boi' }

items.ValueAdded:Connect(function(newValue: any)
    print(`newValue: {newValue}`)
end)

items.ValueRemoved:Connect(function(removedValue: any)
    print(`removedValue: {removedValue}`)
end)

items:output()

items:add('new item')
items:output()

items:add('newer item')
items:output()

items:remove('new item')
items:output()

local items2 = Tracker.new { 'abc', 'def' }
items2:add('ghi')
items2:output()
