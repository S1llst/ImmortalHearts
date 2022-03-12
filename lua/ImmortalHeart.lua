local mod = ComplianceImmortal
local game = Game()
local sfx = SFXManager()
local immortalBreakSfx = Isaac.GetSoundIdByName("ImmortalHeartBreak")
local immortalSfx = Isaac.GetSoundIdByName("immortal")
local screenHelper = require("lua.screenhelper")

function mod:initData(player)
	local data = mod:GetData(player)
	if data.ComplianceImmortalHeart == nil then
		data.ComplianceImmortalHeart = 0
	end
    if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
    	data.ImmortalCharge = 0
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.initData)

local function CanOnlyHaveSoulHearts(player)
	if player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY
	or player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B or player:GetPlayerType() == PlayerType.PLAYER_BLACKJUDAS
	or player:GetPlayerType() == PlayerType.PLAYER_JUDAS_B or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B
	or player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B or player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B then
		return true
	end
	return false
end

function mod:ImmortalHeartUpdate(entity, collider)
	if collider.Type == EntityType.ENTITY_PLAYER then
		local player = collider:ToPlayer()
		if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
			player = player:GetMainTwin()
		end
		local data = mod:GetData(player)
		local player = player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN and player:GetSubPlayer() or player
		if player:CanPickSoulHearts() then
			if entity.SubType == 902 and data.ComplianceImmortalHeart < mod.optionImmortalNum * 2 then
				if (player:GetPlayerType() == PlayerType.PLAYER_THELOST or player:GetPlayerType() == PlayerType.PLAYER_THELOST_B) then
					entity:GetSprite():Play("Collect", true)
					entity:Die()
					entity.Velocity = Vector.Zero
					sfx:Play(immortalSfx,1,0)
				elseif (player:GetPlayerType() == PlayerType.PLAYER_BETHANY) then
					player:AddSoulCharge(2)
					data.ImmortalCharge = data.ImmortalCharge + 1
					entity:GetSprite():Play("Collect", true)
					entity:Die()
					entity.Velocity = Vector.Zero
					sfx:Play(immortalSfx,1,0)
				else
					if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
						player = player:GetSubPlayer()
					end
					if player:GetEffectiveMaxHearts() + player:GetSoulHearts() < player:GetHeartLimit() then
						entity:GetSprite():Play("Collect", true)
						entity:Die()
						entity.Velocity = Vector.Zero
						sfx:Play(immortalSfx,1,0)
						player:AddSoulHearts(2)
						local amount = 2
						if data.ComplianceImmortalHeart == 0 and player:GetSoulHearts() % 2 ~= 0 then
							amount = 1
						end
						data.ComplianceImmortalHeart = data.ComplianceImmortalHeart + amount
					end
				end
				return nil
			end
			if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
				player = player:GetSubPlayer()
			end
			if player:GetEffectiveMaxHearts() + player:GetSoulHearts() >= player:GetHeartLimit() and data.ComplianceImmortalHeart > 0 then
				return false
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.ImmortalHeartUpdate, PickupVariant.PICKUP_HEART)

function mod:FullSoulHeartInit(pickup)
	if pickup.SubType == HeartSubType.HEART_HALF_SOUL then
		local isImmortalHeart = false
		for i = 0, game:GetNumPlayers() - 1 do
			local data = mod:GetData(Isaac.GetPlayer(i))
			if data.ComplianceImmortalHeart > 0 then
				isImmortalHeart = true
			end
		end
		if isImmortalHeart then
			pickup:ToPickup():Morph(pickup.Type,pickup.Variant,HeartSubType.HEART_SOUL,true,true)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.FullSoulHeartInit, PickupVariant.PICKUP_HEART)

function mod:shouldDeHook()
	local reqs = {
	  not game:GetHUD():IsVisible(),
	  game:GetSeeds():HasSeedEffect(SeedEffect.SEED_NO_HUD),
	  game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN ~= 0
	}
	return reqs[1] or reqs[2] or reqs[3]
end

local pauseColorTimer = 0

local function renderingHearts(player,playeroffset)
	local data = mod:GetData(player)
	local isForgotten = player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN and 1 or 0
	local transperancy = 1
	local isTotalEven = data.ComplianceImmortalHeart % 2 == 0
	local level = game:GetLevel()
	if player:GetPlayerType() == PlayerType.PLAYER_JACOB2_B or player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) or isForgotten == 1 then
		transperancy = 0.3
	end
	if isForgotten == 1 then
		player = player:GetSubPlayer()
	end
	local heartIndex = math.ceil(data.ComplianceImmortalHeart/2) - 1
	for i=0, heartIndex do
		local ImmortalSplash = Sprite()
		ImmortalSplash:Load("gfx/ui/ui_remix_hearts.anm2",true)

		local hearts = ((CanOnlyHaveSoulHearts(player) and player:GetBoneHearts()*2 or player:GetEffectiveMaxHearts()) + player:GetSoulHearts()) - (i * 2)
		local hpOffset = hearts%2 ~= 0 and (playeroffset == 5 and -6 or 6) or 0
		local playersHeartPos = {
			[1] = Options.HUDOffset * Vector(20, 12) + Vector(hearts*6+36+hpOffset, 12) + Vector(0,10) * isForgotten,
			[2] = screenHelper.GetScreenTopRight(0) + Vector(hearts*6+hpOffset-123,12) + Options.HUDOffset * Vector(-20*1.2, 12) + Vector(0,20) * isForgotten,
			[3] = screenHelper.GetScreenBottomLeft(0) + Vector(hearts*6+hpOffset+46,-27) + Options.HUDOffset * Vector(20*1.1, -12*0.5) + Vector(0,20) * isForgotten,
			[4] = screenHelper.GetScreenBottomRight(0) + Vector(hearts*6+hpOffset-131,-27) + Options.HUDOffset * Vector(-20*0.8, -12*0.5) + Vector(0,20) * isForgotten,
			[5] = screenHelper.GetScreenBottomRight(0) + Vector((-hearts)*6+hpOffset-36,-27) + Options.HUDOffset * Vector(-20*0.8, -12*0.5)
		}
		local offset = playersHeartPos[playeroffset]
		local offsetCol = (playeroffset == 1 or playeroffset == 5) and 13 or 7
		offset.X = offset.X  - math.floor(hearts / offsetCol) * (playeroffset == 5 and (-72) or (playeroffset == 1 and 72 or 36))
		offset.Y = offset.Y + math.floor(hearts / offsetCol) * 10
		local anim = "ImmortalHeartFull"
		if not isTotalEven then
			if i == 0 then
				anim = "ImmortalHeartHalf"
			end
		end
				
		ImmortalSplash.Color = Color(1,1,1,transperancy)
		--[[local rendering = ImmortalSplash.Color.A > 0.1 or game:GetFrameCount() < 1
		if game:IsPaused() then
			pauseColorTimer = pauseColorTimer + 1
			if pauseColorTimer >= 20 and pauseColorTimer <= 30 and rendering then
				ImmortalSplash.Color = Color.Lerp(ImmortalSplash.Color,Color(1,1,1,0.1),0.1)
			end
		else
			pauseColorTimer = 0
			ImmortalSplash.Color = Color(1,1,1,transperancy)
		end]]
		ImmortalSplash:Play(anim, true)
		local spritename,glowname = "gfx/ui/ui_remix_hearts","gfx/ui/ui_heart_glow"
		if mod.optionNum == 2 then
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
		end
		if mod.optionNum == 6 then
			spritename,glowname = spritename.."_flashy",glowname.."_flashy"
		end
		if mod.optionNum == 7 then
			spritename,glowname = spritename.."_bettericons",glowname.."_betterions"
		end
		if mod.optionNum == 8 then
			spritename,glownamw = spritename.."_eternalupdate",glowname.."eternalupdate"
		end
		spritename, glowname = spritename..".png", glowname..".png"
		ImmortalSplash:ReplaceSpritesheet(0,spritename)
		ImmortalSplash:ReplaceSpritesheet(1,glowname)
		ImmortalSplash:LoadGraphics()
		ImmortalSplash.FlipX = playeroffset == 5
		ImmortalSplash:Render(Vector(offset.X, offset.Y), Vector(0,0), Vector(0,0))
	end
end

function mod:onRender(shadername)
	if shadername ~= "Immortal Hearts" then return end
	if mod:shouldDeHook() then return end
	local players = 0
	local isJacobFirst = false
	for i = 0, game:GetNumPlayers() - 1 do
		if players < 4 then
			local player = Isaac.GetPlayer(i)
			local data = mod:GetData(player)
			if players == 0 and player:GetPlayerType() == PlayerType.PLAYER_JACOB then
				isJacobFirst = true
			end
			if (player:GetPlayerType() == PlayerType.PLAYER_LAZARUS_B or player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B) then
				if player:GetOtherTwin() then
					if data.i and data.i == i then
						data.i = nil
					end
					if not data.i then
						local otherTData = mod:GetData(player:GetOtherTwin())
						otherTData.i = i
					end
				elseif data.i then
					data.i = nil
				end
			end
			local playeroffset
			local isIllusion = player:GetData().IllusionMod and player:GetData().IllusionMod.IsIllusion
			if  player:GetPlayerType() ~= PlayerType.PLAYER_THESOUL_B and not isIllusion and not data.i then
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

end

mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, mod.onRender)

function mod:ImmortalBlock(entity, amount, flag, source, cooldown)
	local player = entity:ToPlayer()
	local data = mod:GetData(player)
	player = player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B and player:GetOtherTwin() or player
	if data.ComplianceImmortalHeart > 0 and flag & DamageFlag.DAMAGE_FAKE == 0 and not (( 
	flag & DamageFlag.DAMAGE_RED_HEARTS == DamageFlag.DAMAGE_RED_HEARTS or player:HasTrinket(TrinketType.TRINKET_CROW_HEART)) and player:GetHearts() > 0) and
	not (player:GetEffects():HasCollectibleEffect(NullItemID.ID_HOLY_CARD) or player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)) 
	and (player:GetPlayerType() ~= PlayerType.PLAYER_THELOST and player:GetPlayerType() ~= PlayerType.PLAYER_THELOST_B
	and player:GetPlayerType() ~= PlayerType.PLAYER_JACOB2_B and player:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN) and
	not (player:GetData().VoodooPin and player:GetData().VoodooPin.SwapedEnemy) then
		if (data.ComplianceImmortalHeart % 2 ~= 0) then
			sfx:Play(immortalBreakSfx,1,0)
			local shatterSPR = Isaac.Spawn(EntityType.ENTITY_EFFECT, 904, 0, player.Position + Vector(0, 1), Vector.Zero, nil):ToEffect():GetSprite()
			shatterSPR.PlaybackSpeed = 2
		end
		data.ComplianceImmortalHeart = data.ComplianceImmortalHeart - 1
		player:TakeDamage(1,DamageFlag.DAMAGE_FAKE,source,cooldown)
		player:AddSoulHearts(-1)
		if data.ComplianceImmortalHeart > 0 then
			player:ResetDamageCooldown()
			player:SetMinDamageCooldown(20)
			if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B or player:GetPlayerType() == PlayerType.PLAYER_ESAU
			or player:GetPlayerType() == PlayerType.PLAYER_JACOB then
				player:GetOtherTwin():ResetDamageCooldown()
				player:GetOtherTwin():SetMinDamageCooldown(20)		
			end
		end
		return false
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.ImmortalBlock, EntityType.ENTITY_PLAYER)

function mod:ActOfImmortal(player)
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION) then return end
	if mod.optionContrition ~= 1 then return end
	local data = mod:GetData(player)

	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
		player = player:GetMainTwin()
	end
	if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
		player = player:GetSubPlayer()
	end
	
	if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION) ~= data.ContritionCount then
		player:AddSoulHearts(2)
		local amount = 2
		if data.ComplianceImmortalHeart == 0 and player:GetSoulHearts() % 2 ~= 0 then
			amount = 1
		end
		data.ComplianceImmortalHeart = data.ComplianceImmortalHeart + amount
		
		player:AddEternalHearts(-1)
		data.ContritionCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.ActOfImmortal)

function mod:HeartHandling(player)
	local data = mod:GetData(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
		player = player:GetSubPlayer()
	end
	if data.ComplianceImmortalHeart > 0 then
		data.ComplianceImmortalHeart = data.ComplianceImmortalHeart > mod.optionImmortalNum * 2 and mod.optionImmortalNum * 2 or data.ComplianceImmortalHeart
		data.ComplianceImmortalHeart = data.ComplianceImmortalHeart > player:GetSoulHearts() and player:GetSoulHearts() or data.ComplianceImmortalHeart
		local heartIndex = math.ceil(data.ComplianceImmortalHeart/2) - 1
		for i=0, heartIndex do
			local ExtraHearts = math.ceil(player:GetSoulHearts() / 2) + player:GetBoneHearts() - i
			local NumSoulHearts = player:GetSoulHearts() - (1 - player:GetSoulHearts() % 2) - i * 2
			if (player:IsBoneHeart(ExtraHearts - 1) or player:IsBlackHeart(NumSoulHearts)) then
				player:AddSoulHearts(-data.ComplianceImmortalHeart)
				player:AddSoulHearts(data.ComplianceImmortalHeart)
			end
			if player:GetEffectiveMaxHearts() + player:GetSoulHearts() == player:GetHeartLimit() and data.ComplianceImmortalHeart == 1 then
				player:AddSoulHearts(-1)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.HeartHandling)

function mod:ImmortalHeal()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = mod:GetData(player)
		if not (data.ComplianceImmortalHeart % 2 == 0) then
			ImmortalEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 903, 0, player.Position + Vector(0, 1), Vector.Zero, nil):ToEffect()
			ImmortalEffect:GetSprite().Offset = Vector(0, -22)
			SFXManager():Play(SoundEffect.SOUND_HOLY, 1, 0, false, 1.25)
			data.ComplianceImmortalHeart = data.ComplianceImmortalHeart + 1
			player:AddSoulHearts(1)
		end
	end
	for _, entity in pairs(Isaac.FindByType(3, 206)) do
		local wispdata = entity:GetData()
		if wispdata.IsImmortal == 1 and entity.HitPoints < entity.MaxHitPoints + 3 then
			entity.HitPoints = entity.HitPoints + 1
		end
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.ImmortalHeal)

function mod:postPickupInit(pickup)
	local rng = pickup:GetDropRNG()
	if pickup.SubType == HeartSubType.HEART_ETERNAL then
		if rng:RandomFloat() >= (1 - mod.optionChance / 100) then
			pickup:Morph(pickup.Type, pickup.Variant, 902)
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.postPickupInit, PickupVariant.PICKUP_HEART)

function mod:DefaultWispInit(wisp)
	local player = wisp.Player
	local data = mod:GetData(player)
	local wispdata = wisp:GetData()
	if data.ImmortalCharge > 0 then
	wisp:SetColor(Color(232, 240, 255, 0.02, 0, 0, 0), -1, 1, false, false)
		data.ImmortalCharge = data.ImmortalCharge - 1
		wispdata.IsImmortal = 1
	else
		wispdata.IsImmortal = 0
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.DefaultWispInit, FamiliarVariant.WISP)

function mod:SpriteChange(entity)
	if entity.SubType == 902 then
		local sprite = entity:GetSprite()
		local spritename = "gfx/items/pick ups/pickup_001_remix_heart"
		if mod.optionNum == 2 then
			spritename = spritename.."_aladar"
		end
		if mod.optionNum == 3 then
			spritename = spritename.."_peas"
		end
		if mod.optionNum == 6 then
			spritename = spritename.."_flashy"
		end
		if mod.optionNum == 7 then
			spritename = spritename.."_bettericons"
		end
		spritename = spritename..".png"
		for i = 0,2 do
			sprite:ReplaceSpritesheet(i,spritename)
		end
		sprite:LoadGraphics()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, mod.SpriteChange, PickupVariant.PICKUP_HEART)