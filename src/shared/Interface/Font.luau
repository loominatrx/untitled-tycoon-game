--[=[
Copyright 2024 Mas Gading

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]=]

--

local function __new(family: string)
    return setmetatable({
        family = family,
    }, {
        __index = function(data, index: string)
            local isItalic
            index, isItalic = index:gsub('Italic$', '')
            return Font.new(
                data.family,
                Enum.FontWeight[index] :: Enum.FontWeight,
                isItalic == 1 and Enum.FontStyle.Italic or Enum.FontStyle.Normal
            )
        end,
        __newindex = function()
            error('This table is not writable!')
        end,
    })
end

type FontWrapper = typeof(__new('rbxasset://fonts/families/BuilderSans.json'))

--[=[
    Craetes a new font wrapper.

    @param family string -- The asset ID for the font family, starting with `rbxasset://` or `rbxassetid://`
    @return FontWrapper -- Returns the requested font wrapper.
]=]

function new(family): FontWrapper
    return __new(family)
end

return { new = new }
