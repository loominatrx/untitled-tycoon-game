local SeededRNG = {}
SeededRNG.__index = SeededRNG

local function stringToSeed(str: string): number
    local hash = 0

    for i = 1, #str do
        local byte = string.byte(str, i)
        hash = (hash * 31 + byte) % 2 ^ 31
    end

    return hash
end

function SeededRNG.new(seed: number | string)
    local setSeed: number
    if typeof(seed) == 'string' then
        setSeed = stringToSeed(seed)
    elseif typeof(seed) == 'number' then
        setSeed = seed
    end

    return setmetatable({
        rng = Random.new(setSeed),
        calls = 0,
    }, SeededRNG)
end

function SeededRNG:NextNumber()
    self.calls += 1
    return self.rng:NextNumber()
end

function SeededRNG:GetState()
    return self.calls
end

function SeededRNG:SetState(calls)
    for _ = 1, calls do
        self.rng:NextNumber() -- discard
    end
    self.calls = calls
end

return SeededRNG
