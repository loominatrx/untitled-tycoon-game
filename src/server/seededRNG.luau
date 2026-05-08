local SeededRNG = {}
SeededRNG.__index = SeededRNG

function SeededRNG.new(seed)
    return setmetatable({
        rng = Random.new(seed),
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
