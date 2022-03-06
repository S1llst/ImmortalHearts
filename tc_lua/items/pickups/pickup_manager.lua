local PickupManager = { }

local registeredPickups = { }
local replacementPickups = { }

function PickupManager:RegisterPickup(_pickup)
    local variant = _pickup.Variant
    local subtype = _pickup.SubType
    if registeredPickups[variant] == nil then
        registeredPickups[variant] = { }
    end
    registeredPickups[variant][subtype] = _pickup
end

function PickupManager:RegisterPickupReplacement(_pickup, _pickupReplacementOption)
    local variant = _pickupReplacementOption.Variant
    local subtype = _pickupReplacementOption.SubType
    if replacementPickups[variant] == nil then
        replacementPickups[variant] = { }
    end
    if replacementPickups[variant][subtype] == nil then
        replacementPickups[variant][subtype] = { }
    end

    replacementPickups[variant][subtype][_pickup] = _pickupReplacementOption
end

function PickupManager:TryGetPickup(variant, subtype)
    if registeredPickups[variant] == nil or registeredPickups[variant][subtype] == nil then
        return false
    end
    return true, registeredPickups[variant][subtype]
end

function PickupManager:TryGetPickupReplacements(variant, subtype)
    if replacementPickups[variant] == nil or replacementPickups[variant][subtype] == nil then
        return false
    end
    return true, replacementPickups[variant][subtype]
end

function PickupManager:GetPickups(variant)
    return registeredPickups[variant] or { }
end

return PickupManager