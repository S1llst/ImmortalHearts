local PickupManager = require("tc_lua.items.pickups.pickup_manager")
local Pickup = require("tc_lua.items.pickups.pickup")

local function MC_POST_PICKUP_INIT(_, pickup)
    local hasPickup, _pickup = PickupManager:TryGetPickup(pickup.Variant, pickup.SubType)
    if hasPickup then
        Pickup:OnInit(pickup)
    end
end

return MC_POST_PICKUP_INIT