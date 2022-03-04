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
		if data.ComplianceImmortalHeart < 2 then
			for _, entity in pairs(Isaac.FindByType(3, 238, 20)) do
				data.ComplianceImmortalHeart = 2
				entity:Kill()
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UseSumptorium, CollectibleType.COLLECTIBLE_SUMPTORIUM)

function mod:UseSumptoriumNoTEve(boi, rng, player, slot, data)
	local data = mod:GetData(player)
	if data.ComplianceImmortalHeart == 2 then
		data.ComplianceImmortalHeart = 0
		SFXManager():Play(Isaac.GetSoundIdByName("ImmortalHeartBreak"),1,0)
		local clot = Isaac.Spawn(3, 238, 20, player.Position, Vector.Zero, player):ToFamiliar()
		clot:GetData().HP = 6
		clot.HitPoints = clot:GetData().HP
		player:AnimateCollectible(CollectibleType.COLLECTIBLE_SUMPTORIUM, "UseItem")
		return true
	end
	return nil
end
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, mod.UseSumptoriumNoTEve, CollectibleType.COLLECTIBLE_SUMPTORIUM)

function mod:ImmortalClotDamage(clot,_,_,_,dmgcooldown)
	if clot.Variant == 238 and clot.SubType == 20 then
		clot.HitPoints = clot:GetData().HP
		clot:GetData().HP = clot:GetData().HP - 1
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.ImmortalClotDamage, EntityType.ENTITY_FAMILIAR)
