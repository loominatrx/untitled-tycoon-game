local Metadata = {}
for _, data in script:GetChildren() do
    if data:IsA('ModuleScript') then
        Metadata[data.Name] = require(data)
    end
end

return Metadata
