local PickupReplacement = { }

PickupReplacement.Variant = 0
PickupReplacement.SubType = 0
PickupReplacement.Chance = 0

function PickupReplacement:New(variant, subtype, chance)
    local t = { }
    setmetatable(t, self)
    t.__index = self
    t.Variant = variant or 0
    t.SubType = subtype or 0
    t.Chance = chance or 0
    return t
end

return PickupReplacement