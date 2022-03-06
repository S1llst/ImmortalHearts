local Enums = require("tc_lua.core.enums")
local Globals = require("tc_lua.core.globals")
local PickupHeart = require("tc_lua.items.pickups.hearts.pickup_heart")
local PickupReplacement = require("tc_lua.items.pickups.pickup_replacement")
local ScreenHelper = require("tc_lua.helpers.screen_helper")

local ImmortalHeart = PickupHeart:New(Enums.HeartSubType.HEART_IMMORTAL)

ImmortalHeart.Stats = {
    Cooldown = 20
}

ImmortalHeart.HasUIRender = true
ImmortalHeart.RenderShaderName = "Immortal Hearts"

-- Local variables
local immortalBreakSfx = Isaac.GetSoundIdByName("ImmortalHeartBreak")
local immortalSfx = Isaac.GetSoundIdByName("immortal")
local ImmortalSplash = Sprite()
ImmortalSplash:Load("gfx/ui/ui_remix_hearts.anm2",true)

local players = 0
local isJacobFirst = 0

ImmortalHeart:SetReplacementOptions(
    PickupReplacement:New(PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL, 20)
)

function ImmortalHeart:Collect(pickup)
    PickupHeart.Collect(self, pickup)
    Globals.SFX:Play(immortalSfx,1,0)
end

local function GetAppropriatePlayer(player)
    if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
        player = player:GetMainTwin()
    end
    return player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN and player:GetSubPlayer() or player
end

-- Pickup Callbacks

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


local function CanOnlyHaveSoulHearts(player)
	if player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY
	or player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B or player:GetPlayerType() == PlayerType.PLAYER_BLACKJUDAS
	or player:GetPlayerType() == PlayerType.PLAYER_JUDAS_B or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B
	or player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B or player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B then
		return true
	end
	return false
end

function ImmortalHeart:OnPreRender()
    players = 0
    isJacobFirst = false
end

-- TODO : shouldn't be in the Immortal Heart file. Should be in a "helper" file
local function renderingHearts(player, playeroffset)
    local pData = player:GetData()
	local isForgotten = player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN and 1 or 0
	local transperancy = 1
	local level = Globals.Game:GetLevel()

	if player:GetPlayerType() == PlayerType.PLAYER_JACOB2_B or player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) or isForgotten == 1 then
		transperancy = 0.3
	end

	if isForgotten == 1 then
		player = player:GetSubPlayer()
	end
	
    if level:GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN == 0 and pData.TC_immortalHeart_amount > 0 then
		local hearts = (CanOnlyHaveSoulHearts(player) and player:GetBoneHearts()*2 or player:GetEffectiveMaxHearts()) + player:GetSoulHearts()
		if hearts%2 ~= 0 then
			pData.TC_immortalHeart_hpOffset = playeroffset == 5 and -6 or 6
		else
			pData.TC_immortalHeart_hpOffset = 0
		end
		if player:GetSoulHearts() == 0 then
			pData.TC_immortalHeart_amount = 0
		end
		local playersHeartPos = {
			[1] = Options.HUDOffset * Vector(20, 12) + Vector(hearts*6+36+pData.TC_immortalHeart_hpOffset, 12) + Vector(0,10) * isForgotten,
			[2] = ScreenHelper.GetScreenTopRight(0) + Vector(hearts*6+pData.TC_immortalHeart_hpOffset-123,12) + Options.HUDOffset * Vector(-20*1.2, 12) + Vector(0,20) * isForgotten,
			[3] = ScreenHelper.GetScreenBottomLeft(0) + Vector(hearts*6+pData.TC_immortalHeart_hpOffset+46,-27) + Options.HUDOffset * Vector(20*1.1, -12*0.5) + Vector(0,20) * isForgotten,
			[4] = ScreenHelper.GetScreenBottomRight(0) + Vector(hearts*6+pData.TC_immortalHeart_hpOffset-131,-27) + Options.HUDOffset * Vector(-20*0.8, -12*0.5) + Vector(0,20) * isForgotten,
			[5] = ScreenHelper.GetScreenBottomRight(0) + Vector((-hearts)*6+pData.TC_immortalHeart_hpOffset-36,-27) + Options.HUDOffset * Vector(-20*0.8, -12*0.5)
		}
		local offset = playersHeartPos[playeroffset]
		local offsetCol = (playeroffset == 1 or playeroffset == 5) and 13 or 7
		offset.X = offset.X  - math.floor(hearts / offsetCol) * (playeroffset == 5 and (-72) or (playeroffset == 1 and 72 or 36))
		offset.Y = offset.Y + math.floor(hearts / offsetCol) * 10
		local anim = pData.TC_immortalHeart_amount == 1 and "ImmortalHeartHalf" or "ImmortalHeartFull"
		
		ImmortalSplash.Color = Color(1,1,1,transperancy)

		ImmortalSplash:Play(anim, true)
		local spritename,glowname = "gfx/ui/ui_remix_hearts","gfx/ui/ui_heart_glow"
		--[[if mod.optionNum == 2 then
			spritename,glowname = spritename.."_aladar",glowname.."_aladar"
		end
		if mod.optionNum == 3 then
			spritename,glowname = spritename.."_peas",glowname.."_peas"
		end
		if mod.optionNum == 4 then
			spritename,glowname = spritename.."_beautiful",glowname.."_beautiful"
		end
		if mod.optionNum == 5 then 
			spritename,glowname = spritename.."_goncholito",glowname.."_goncholito"
		end--]]
		spritename, glowname = spritename..".png", glowname..".png"
		ImmortalSplash:ReplaceSpritesheet(0,spritename)
		ImmortalSplash:ReplaceSpritesheet(1,glowname)
		ImmortalSplash:LoadGraphics()
		ImmortalSplash.FlipX = playeroffset == 5
		ImmortalSplash:Render(Vector(offset.X, offset.Y), Vector(0, 0), Vector(0, 0))
	end
end

function ImmortalHeart:OnRenderPlayerHeart(i, player)
    if players < 4 then
        local pData = player:GetData()
        if players == 0 and player:GetPlayerType() == PlayerType.PLAYER_JACOB then
            isJacobFirst = true
        end
        if (player:GetPlayerType() == PlayerType.PLAYER_LAZARUS_B or player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B) then
            if player:GetOtherTwin() then
                if pData.TC_immortalHeart_i and pData.iTC_immortalHeart_i == i then
                    pData.TC_immortalHeart_i = nil
                end
                if not pData.TC_immortalHeart_i then
                    local otherTData = player:GetOtherTwin():GetData()
                    otherTData.TC_immortalHeart_i = i
                end
            elseif pData.TC_immortalHeart_i then
                pData.TC_immortalHeart_i = nil
            end
        end
        local playeroffset
        local isIllusion = pData.IllusionMod and pData.IllusionMod.IsIllusion
        if  player:GetPlayerType() ~= PlayerType.PLAYER_THESOUL_B and not isIllusion and not pData.TC_immortalHeart_i then
            if player:GetPlayerType() ~= PlayerType.PLAYER_ESAU then
                players = players + 1
                playeroffset = players
            end
            if player:GetPlayerType() == PlayerType.PLAYER_ESAU and isJacobFirst then
                renderingHearts(player,5)
            elseif player:GetPlayerType() ~= PlayerType.PLAYER_ESAU then
                renderingHearts(player,playeroffset)
            end
        end
    end
end

function ImmortalHeart:OnPlayerTakeDamage(player, amount, flag, source, cooldown)
    local pData = player:GetData()
    local playerType = player:GetPlayerType()

	player = playerType == PlayerType.PLAYER_THEFORGOTTEN_B and player:GetOtherTwin() or player

    -- TODO : Isn't it possible to clean that terrifying if condition ?
	if pData.TC_immortalHeart_amount > 0 and flag & DamageFlag.DAMAGE_FAKE == 0 and not (( 
	flag & DamageFlag.DAMAGE_RED_HEARTS == DamageFlag.DAMAGE_RED_HEARTS or player:HasTrinket(TrinketType.TRINKET_CROW_HEART)) and player:GetHearts() > 0) and
	not (player:GetEffects():HasCollectibleEffect(NullItemID.ID_HOLY_CARD) or player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)) 
	and (playerType ~= PlayerType.PLAYER_THELOST and playerType ~= PlayerType.PLAYER_THELOST_B
	and playerType ~= PlayerType.PLAYER_JACOB2_B and playerType ~= PlayerType.PLAYER_THEFORGOTTEN) and
	not (pData.VoodooPin and pData.VoodooPin.SwapedEnemy) then
		amount = pData.TC_immortalHeart_amount == 1 and 1 or (amount > 2 and 2 or amount)
		pData.TC_immortalHeart_amount = pData.TC_immortalHeart_amount - amount
		if pData.TC_immortalHeart_amount == 0 then
			Globals.SFX:Play(immortalBreakSfx, 1, 0)
			local shatterSPR = Isaac.Spawn(EntityType.ENTITY_EFFECT, 904, 0, player.Position + Vector(0, 1), Vector.Zero, nil):ToEffect():GetSprite()
			shatterSPR.PlaybackSpeed = 2
		end
		player:TakeDamage(amount, DamageFlag.DAMAGE_FAKE, source, cooldown)
		player:AddSoulHearts(-amount)
		if pData.TC_immortalHeart_amount > 0 then
			player:ResetDamageCooldown()
			player:SetMinDamageCooldown(ImmortalHeart.Stats.Cooldown)
			if playerType == PlayerType.PLAYER_THESOUL_B or playerType == PlayerType.PLAYER_ESAU
			or player:GetPlayerType() == PlayerType.PLAYER_JACOB then
				player:GetOtherTwin():ResetDamageCooldown()
				player:GetOtherTwin():SetMinDamageCooldown(ImmortalHeart.Stats.Cooldown)
			end
		end
		return false
	end
end

-- Additional callbacks

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

-- MC_POST_PICKUP_INIT --
function ImmortalHeart:FullSoulHeartInit(pickup)
	if pickup.SubType == HeartSubType.HEART_HALF_SOUL then
		for i = 0, Globals.Game:GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
			local pData = player:GetData()
			if pData.TC_immortalHeart_amount > 0 then
                pickup:ToPickup():Morph(pickup.Type,pickup.Variant,HeartSubType.HEART_SOUL,true,true)
                return
			end
		end
	end
end

-- MC_PRE_SPAWN_CLEAN_AWARD --
function ImmortalHeart:CleanRoom()
	for i = 0, Globals.Game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local pData = player:GetData()
		if pData.TC_immortalHeart_amount == 1 then
			ImmortalEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 903, 0, player.Position + Vector(0, 1), Vector.Zero, nil):ToEffect()
			ImmortalEffect:GetSprite().Offset = Vector(0, -22)
			Globals.SFX:Play(SoundEffect.SOUND_HOLY, 1, 0, false, 1.25)
			pData.TC_immortalHeart_amount = 2
			player:AddSoulHearts(1)
		end
	end
	
    -- TODO : Wisps ? And get rid of hardcoded values, like what is this 206 ?
    --[[for _, entity in ipairs(Isaac.FindByType(3, 206)) do
		local wispdata = entity:GetData()
		if wispdata.IsImmortal == 1 and entity.HitPoints < entity.MaxHitPoints + 3 then
			entity.HitPoints = entity.HitPoints + 1
		end
	end--]]
end

TC_ImmortalHeart:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, ImmortalHeart.PlayerInit)
TC_ImmortalHeart:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, ImmortalHeart.FullSoulHeartInit, PickupVariant.PICKUP_HEART)
TC_ImmortalHeart:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, ImmortalHeart.CleanRoom)

return ImmortalHeart