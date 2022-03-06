local Enums = require("tc_lua.core.enums")
local Globals = require("tc_lua.core.globals")
local Pickup = require("tc_lua.items.pickups.pickup")
local PickupReplacement = require("tc_lua.items.pickups.pickup_replacement")

local ImmortalHeart = Pickup:New(PickupVariant.PICKUP_HEART, Enums.HeartSubType.HEART_IMMORTAL)

-- Local variables
local immortalBreakSfx = Isaac.GetSoundIdByName("ImmortalHeartBreak")
local immortalSfx = Isaac.GetSoundIdByName("immortal")
local ImmortalSplash = Sprite()
ImmortalSplash:Load("gfx/ui/ui_remix_hearts.anm2",true)

ImmortalHeart:SetReplacementOptions(
    PickupReplacement:New(PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL, 20)
)

function ImmortalHeart:Collect(pickup)
    Pickup.Collect(self, pickup)
    Globals.SFX:Play(immortalSfx,1,0)
end

-- MC_POST_PLAYER_INIT --
function ImmortalHeart:PlayerInit(player)
    local pData = player:GetData()

	if pData.TC_immortalHeart_amount == nil then
		pData.TC_immortalHeart_amount = 0
		pData.TC_immortalHeart_hpOffset = 0
	end
    if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
    	pData.TC_immortalHeart_immortalCharge = 0
	end
end

local function GetAppropriatePlayer(player)
    if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
        player = player:GetMainTwin()
    end
    return player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN and player:GetSubPlayer() or player
end

function ImmortalHeart:OnPlayerCollision(pickup, player)
    player = GetAppropriatePlayer(player)

    if player:CanPickSoulHearts() == false then
        return nil
    end

    local pData = player:GetData()
    local playerType = player:GetPlayerType()

    if playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B then
        ImmortalHeart:Collect(pickup)
    elseif player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
        player:AddSoulCharge(2)
        pData.TC_immortalHeart_immortalCharge = pData.TC_immortalHeart_immortalCharge + 1
        ImmortalHeart:Collect(pickup)
    elseif pData.TC_immortalHeart_amount < 2 then
        if playerType == PlayerType.PLAYER_THEFORGOTTEN then
            player = player:GetSubPlayer()
        end
        if player:GetEffectiveMaxHearts() + player:GetSoulHearts() < player:GetHeartLimit() then
            local extra = (pData.TC_immortalHeart_amount == 0 and player:GetSoulHearts() % 2 or 0) - pData.TC_immortalHeart_amount
            player:AddSoulHearts(2 + extra)
            pData.TC_immortalHeart_amount = 2
            ImmortalHeart:Collect(pickup)
        end
        return nil
    end

    if playerType == PlayerType.PLAYER_THEFORGOTTEN then
        player = player:GetSubPlayer()
    end
    if player:GetEffectiveMaxHearts() + player:GetSoulHearts() >= player:GetHeartLimit() and pData.TC_immortalHeart_amount > 0 then
        return false
    end
end

TC_ImmortalHeart:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, ImmortalHeart.PlayerInit)

return ImmortalHeart