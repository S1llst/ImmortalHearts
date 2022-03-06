local Globals = require("tc_lua.core.globals")
local Pickup = require("tc_lua.items.pickups.pickup")
local PickupManager = require("tc_lua.items.pickups.pickup_manager")

local PickupHeart = Pickup:New(PickupVariant.PICKUP_HEART, 0)

PickupHeart.HasUIRender = false
PickupHeart.RenderShaderName = "TC Hearts"

function PickupHeart:New(subtype)
    return Pickup:New(PickupVariant.PICKUP_HEART, subtype)
end

-- Heart Pickup callback

function PickupHeart:OnPreRender()
    print("Render heart")
end

function PickupHeart:OnRenderPlayerHeart(i, player)

end

function PickupHeart:OnPlayerTakeDamage(player, amount, flag, source, cooldown)

end

-- Additional callbacks

local function shouldDeHook()
	local reqs = {
	  not Globals.Game:GetHUD():IsVisible(),
	  Globals.Game:GetSeeds():HasSeedEffect(SeedEffect.SEED_NO_HUD)
	}
	return reqs[1] or reqs[2]
end

function PickupHeart:OnShaderRender(shaderName)
    local _heartPickups = PickupManager:GetPickups(PickupVariant.PICKUP_HEART)
    
    for subtype, _pickup in pairs(_heartPickups) do
        if _pickup.HasUIRender == true and _pickup.RenderShaderName == shaderName and shouldDeHook() == false then
            
            _pickup:OnPreRender()

            for i = 0, Globals.Game:GetNumPlayers() - 1 do
                local player = Isaac.GetPlayer(i)
                _pickup:OnRenderPlayerHeart(i, player)
            end
        end
    end
end


function PickupHeart:OnEntityTakeDamage(entity, amount, flag, source, cooldown)
    local player = entity:ToPlayer()

    local _heartPickups = PickupManager:GetPickups(PickupVariant.PICKUP_HEART)
    
    for subtype, _pickup in pairs(_heartPickups) do
        local sustainDamage = _pickup:OnPlayerTakeDamage(player, amount, flag, source, cooldown)
        if sustainDamage == false then
            return false
        end
    end
end

TC_ImmortalHeart:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, PickupHeart.OnShaderRender)
TC_ImmortalHeart:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, PickupHeart.OnEntityTakeDamage, EntityType.ENTITY_PLAYER)

return PickupHeart