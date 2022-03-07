local PickupManager = require("tc_lua.items.pickups.pickup_manager")

local Pickup = {
    Variant = 0,
    SubType = 0,
    ReplacementOptions = { }
}

-- Pickup functions
function Pickup:New(variant, subtype)
    local t = { }
    setmetatable(t, self)
    self.__index = self
    t.Variant = variant or 0
    t.SubType = subtype or 0

    if subtype > 0 then -- Do not register "abstract" pickups
        PickupManager:RegisterPickup(t)
    end
    return t
end

function Pickup:SetReplacementOptions(...)
	local args = {...}
    for _, replacementOption in ipairs(args) do
        PickupManager:RegisterPickupReplacement(self, replacementOption)
        table.insert(self.ReplacementOptions, replacementOption)
    end
end

function Pickup:Collect(pickup)
    local sprite = pickup:GetSprite()
    sprite:Play("Collect", true)
    pickup:Die()
    pickup.Velocity = Vector.Zero
end

-- Standard mod callbacks
function Pickup:PickupInit(pickup)
    local hasReplacementOptions, _replacementOptions = PickupManager:TryGetPickupReplacements(pickup.Variant, pickup.SubType)
    if hasReplacementOptions then
        local rng = pickup:GetDropRNG()
        for _pickup, _replacementOption in pairs(_replacementOptions) do
            if rng:RandomFloat() * 100 < _replacementOption.Chance then
                pickup:Morph(pickup.Type, _pickup.Variant, _pickup.SubType)
            end
        end
    end
end

function Pickup:PickupUpdate(pickup)
    Pickup:OnUpdate(pickup)
end

function Pickup:PrePickupCollision(pickup, collider)
	if collider.Type == EntityType.ENTITY_PLAYER then
        local player = collider:ToPlayer()
        
        local hasPickup, _pickup = PickupManager:TryGetPickup(pickup.Variant, pickup.SubType)
        if hasPickup then
            _pickup:OnPlayerCollision(pickup, player)
        end
    end
end


-- Pickup callbacks
function Pickup:OnInit(pickup)
end

function Pickup:OnUpdate(pickup)
end

function Pickup:OnPlayerCollision(pickup, player)
end

function Pickup:IsPickable(pickup, player)
end


TC_ImmortalHeart:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, Pickup.PickupInit)
TC_ImmortalHeart:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Pickup.PickupUpdate)
TC_ImmortalHeart:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Pickup.PrePickupCollision)


return Pickup