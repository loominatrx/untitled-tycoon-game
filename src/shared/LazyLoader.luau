-- taken from https://github.com/EgoMoose/Rbx-Gui-Library/blob/master/src/GuiLib/LazyLoader.lua
local FORMAT_STR = '"%s" is not an existing class/folder.'

local VALID = {
    ['Folder'] = true,
    ['ModuleScript'] = true,
}

local function attachLoaderFrom(module, target)
    local Library = {}
    local Meta = {}

    function Meta:__index(key)
        if Library[key] then
            -- print(`Library[{key}] =`, Library[key])
            return Library[key]
        end

        local object = module:FindFirstChild(key)
        if object and object ~= script and VALID[object.ClassName] then
            Library[key] = object:IsA('ModuleScript') and require(object) or attachLoaderFrom(object, {})
            -- print(`Library[{key}] =`, Library[key])
            return Library[key]
        end

        error(FORMAT_STR:format(key), 2)
    end

    return setmetatable(target, Meta)
end

return attachLoaderFrom
