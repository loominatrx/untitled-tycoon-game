--[=[
	@class Placement
	A grid-based placement system for tycoon-style games.

	Each instance represents ONE plot (usually per player).

	Use `Placement.new()` to create a new placement system tied to a plot.

	Supports:
	- Grid snapping
	- Placement validation
	- Per-plot occupancy
	- Rotation
]=]

local Placement = {}
Placement.__index = Placement

--[=[
	@prop CellSize number
	@within Placement
	Size of each grid cell in studs.
]=]
Placement.CellSize = 1

--[=[
	@prop GridSize number
	@within Placement
]=]
Placement.GridSize = 25 -- x and z pos halved

--[=[
	Creates a new placement instance.

	Each instance has its own:
	- PlotOrigin
	- Occupied grid

	@param plotOrigin Vector3
	@return Placement
]=]
function Placement.new(plotOrigin: Vector3)
    local self = setmetatable({}, Placement)

    self.PlotOrigin = plotOrigin
    self.Occupied = {}

    return self
end

--[=[
	@prop PlotOrigin Vector3
	@within Placement
	The origin point of this placement grid (grid coordinate 0,0).
]=]

--[=[
	@prop Occupied table
	@within Placement
	Internal occupancy map. Do not modify manually.
]=]

--[=[
	Converts a world position into grid coordinates.

	@param worldPos Vector3
	@return number x
	@return number z
]=]
function Placement:WorldToGrid(worldPos: Vector3)
    local relative = worldPos - self.PlotOrigin

    local x = math.floor((relative.X / self.CellSize))
    local z = math.floor((relative.Z / self.CellSize))

    return x, z
end

function Placement:IsWithinBounds(x, z, sizeX, sizeZ)
    print(x, z, sizeX, sizeZ)

    return (x >= 0 and z >= 0 and x + sizeX <= Placement.GridSize and z + sizeZ <= Placement.GridSize)
end

--[=[
	Converts grid coordinates into a world position.

	@param x number
	@param z number
	@return Vector3
]=]
function Placement:GridToWorld(x: number, z: number)
    return self.PlotOrigin + Vector3.new((x + 0.5) * self.CellSize, 0, (z + 0.5) * self.CellSize)
end

function Placement:_isOccupied(x, z)
    return self.Occupied[x] and self.Occupied[x][z]
end

function Placement:_occupy(x, z)
    self.Occupied[x] = self.Occupied[x] or {}
    self.Occupied[x][z] = true
end

function Placement:_free(x, z)
    if self.Occupied[x] then
        self.Occupied[x][z] = nil
    end
end

--[=[
	Checks if an object can be placed at the given grid position.

	@param x number
	@param z number
	@param sizeX number
	@param sizeZ number
	@return boolean
]=]
function Placement:CanPlace(x: number, z: number, sizeX: number, sizeZ: number)
    -- if not self:IsWithinBounds(x, z, sizeX, sizeZ) then
    --     return false
    -- end

    for dx = 0, sizeX - 1 do
        for dz = 0, sizeZ - 1 do
            if self:_isOccupied(x + dx, z + dz) then
                return false
            end
        end
    end
    return true
end

--[=[
	Marks a grid area as occupied.

	@param x number
	@param z number
	@param sizeX number
	@param sizeZ number
]=]
function Placement:Occupy(x: number, z: number, sizeX: number, sizeZ: number)
    for dx = 0, sizeX - 1 do
        for dz = 0, sizeZ - 1 do
            self:_occupy(x + dx, z + dz)
        end
    end
end

--[=[
	Frees a previously occupied grid area.

	@param x number
	@param z number
	@param sizeX number
	@param sizeZ number
]=]
function Placement:Free(x: number, z: number, sizeX: number, sizeZ: number)
    for dx = 0, sizeX - 1 do
        for dz = 0, sizeZ - 1 do
            self:_free(x + dx, z + dz)
        end
    end
end

--[=[
	Returns the size of an object after rotation.

	@param sizeX number
	@param sizeZ number
	@param rotation number -- degrees (0, 90, 180, 270)
	@return number
	@return number
]=]
function Placement:GetRotatedSize(sizeX: number, sizeZ: number, rotation: number)
    if rotation % 180 == 90 then
        return sizeZ, sizeX
    end
    return sizeX, sizeZ
end

--[=[
	Calculates placement data for preview or validation.

	Used on:
	- Client (preview)
	- Server (validation)

	@param mouseHit CFrame
	@param sizeX number
	@param sizeZ number
	@param rotation number?
	@return table
]=]
function Placement:GetPlacement(mouseHit: CFrame, sizeX: number, sizeZ: number, rotation: number?)
    rotation = rotation or 0

    local x, z = self:WorldToGrid(mouseHit.Position)
    local rSizeX, rSizeZ = self:GetRotatedSize(sizeX, sizeZ, rotation)

    local worldPos = self:GridToWorld(x, z)
    local cf = CFrame.new(worldPos) * CFrame.Angles(0, math.rad(rotation), 0)

    local canPlace = self:CanPlace(x, z, rSizeX, rSizeZ)

    return {
        X = x,
        Z = z,
        SizeX = rSizeX,
        SizeZ = rSizeZ,
        CFrame = cf,
        CanPlace = canPlace,
    }
end

--[=[
	Attempts to place an object.

	Should be called on the SERVER.

	@param data table
	@return boolean success
]=]
function Placement:Place(data)
    if not data.CanPlace then
        return false
    end

    self:Occupy(data.X, data.Z, data.SizeX, data.SizeZ)
    return true
end

--[=[
	Clears all occupied cells.

	Useful for:
	- Resetting a plot
	- Debugging
]=]
function Placement:Clear()
    table.clear(self.Occupied)
end

return Placement
