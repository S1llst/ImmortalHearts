local mod = ComplianceImmortal
local game = Game()

function mod:ClotHeal()
	for _, entity in pairs(Isaac.FindByType(3, 238, 20)) do
		entity = entity:ToFamiliar()
		if entity.HitPoints > 5 then
			local healed = 0
			for _, entity2 in pairs(Isaac.FindByType(3, 238)) do
				entity2 = entity2:ToFamiliar()
				if entity2.SubType ~= 20 and not entity2:GetData().Healed 
				and GetPtrHash(entity2.Player) == GetPtrHash(entity.Player) 
				and entity2.HitPoints < entity2.MaxHitPoints then
					entity2:AddHealth(2)
					entity2:GetData().Healed = true
					healed = healed + 1
				end
			end
			if entity:GetData().HP < entity.MaxHitPoints then
				entity:GetData().HP = entity:GetData().HP + 1 / (1 + #Isaac.FindByType(3, 238))
			end
		else
			entity:GetData().HP = entity:GetData().HP + 2
		end
	end
	for _, entity in pairs(Isaac.FindByType(3, 238)) do
		entity = entity:ToFamiliar()
		if entity:GetData().Healed then
			entity:GetData().Healed = nil
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.ClotHeal)

function mod:StaticHP(clot)
	if clot.SubType == 20 then
		local data = clot:GetData()
		if not data.HP then
			data.HP = clot.HitPoints
		else
			data.HP = data.HP <= clot.MaxHitPoints and data.HP or clot.MaxHitPoints
			clot.HitPoints = data.HP
		end
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.StaticHP, 238)

function mod:UseSumptorium(boi, rng, player, slot, data)
	local data = mod:GetData(player)
	if player:GetPlayerType() == PlayerType.PLAYER_EVE_B then
		local amount = 0
		for _, entity in pairs(Isaac.FindByType(3, 238, 20)) do
			amount = amount + 1
			entity:Kill()
		end
		if amount > 0 then
			player:AddSoulHearts(amount)
			data.ComplianceImmortalHeart = data.ComplianceImmortalHeart + amount
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UseSumptorium, CollectibleType.COLLECTIBLE_SUMPTORIUM)

function mod:UseSumptoriumNoTEve(boi, rng, player, slot, data)
	local data = mod:GetData(player)
	if data.ComplianceImmortalHeart > 0 and player:GetHearts() == 0 and player:GetPlayerType() ~= PlayerType.PLAYER_EVE_B then
		SFXManager():Play(Isaac.GetSoundIdByName("ImmortalHeartBreak"),1,0)
		local clot = Isaac.Spawn(3, 238, 20, player.Position, Vector.Zero, player):ToFamiliar()
		clot:GetData().HP = 3
		clot.HitPoints = clot:GetData().HP
		player:AddSoulHearts(-1)
		data.ComplianceImmortalHeart = data.ComplianceImmortalHeart - 1
		player:AnimateCollectible(CollectibleType.COLLECTIBLE_SUMPTORIUM, "UseItem")
		return true
	end
	return nil
end
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, mod.UseSumptoriumNoTEve, CollectibleType.COLLECTIBLE_SUMPTORIUM)


--SPAWNING
--t eve's ability
function mod:TEveSpawn(baby)
	local player = baby.Player
	local data = mod:GetData(player)
	if (player:GetPlayerType() == PlayerType.PLAYER_EVE_B) and (data.ComplianceImmortalHeart > 0) and (baby.SubType == 1) then
		if data.ComplianceImmortalHeart % 2 ~= 0 then
			SFXManager():Play(Isaac.GetSoundIdByName("ImmortalHeartBreak"),1,0)
			local shatterSPR = Isaac.Spawn(EntityType.ENTITY_EFFECT, 904, 0, player.Position + Vector(0, 1), Vector.Zero, nil):ToEffect():GetSprite()
			shatterSPR.PlaybackSpeed = 2
		end
		
		local clot = Isaac.Spawn(3, 238, 20, player.Position, Vector(0, 0), player):ToFamiliar()
		clot:GetData().HP = 3
		clot.HitPoints = clot:GetData().HP
		data.ComplianceImmortalHeart = data.ComplianceImmortalHeart - 1
		baby:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.TEveSpawn, 238)


function mod:ImmortalClotDamage(clot,_,_,_,dmgcooldown)
	if clot.Variant == 238 and clot.SubType == 20 then
		clot.HitPoints = clot:GetData().HP
		clot:GetData().HP = clot:GetData().HP - 1
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.ImmortalClotDamage, EntityType.ENTITY_FAMILIAR)
