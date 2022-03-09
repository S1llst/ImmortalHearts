ComplianceImmortal = RegisterMod("Compliance Immortal Hearts", 1)
local mod = ComplianceImmortal
local game = Game()
local json = require("json") 
local IHDesc =  "{{ImmortalHeartIcon}} Holy heart that regenerates upon completing a room in which the player received damage#{{ImmortalHeartIcon}} Invincibility frames are reduced"
local IHDescSpa = "{{ImmortalHeartIcon}} Corazón especial que se regenera al completar una sala si es que recibió daño#{{ImmortalHeartIcon}} El tiempo de invencibilidad al recibir daño se reduce"
local IHDescRu = "{{ImmortalHeartIcon}} Святое сердце, которое восстанавливается после зачистки комнаты, в которой игрок получил урон#{{ImmortalHeartIcon}} Время неуязвимости после урона уменьшено"

if EID then
--EID:addIcon(shortcut, animationName, animationFrame, width, height, leftOffset, topOffset, spriteObject)
EID:setModIndicatorName("Immortal Heart")
	local iconSprite = Sprite()
	iconSprite:Load("gfx/eid_icon_immortal_hearts.anm2", true)
	EID:addIcon("ImmortalHeartIcon", "Immortal Heart Icon", 0, 11, 10, -1, -1, iconSprite)
	EID:setModIndicatorIcon("ImmortalHeartIcon")
	EID:addEntity(5, 10, 902, "Immortal Heart", IHDesc, "en_us")
	EID:addEntity(5, 10, 902, "Corazón Inmortal", IHDescSpa, "spa")
	EID:addEntity(5, 10, 902, "Бессмертное сердце", IHDescRu, "ru")
end

include("lua/ModConfigMenu.lua")
include("lua/ImmortalHeart.lua")
include("lua/ImmortalClot.lua")
include("lua/achievement_display_api.lua")

if MinimapAPI then
    local frame = 1
    local ImmortalSprite = Sprite()
    ImmortalSprite:Load("gfx/ui/immortalheart_icon.anm2", true)
    MinimapAPI:AddIcon("ImmortalIcon", ImmortalSprite, "ImmortalHeart", 0)
	MinimapAPI:AddPickup(902, "ImmortalIcon", 5, 10, 902, MinimapAPI.PickupNotCollected, "hearts", 13000)
end

function onStart(_, bool)
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = mod:GetData(player)
		if bool == false or data.ComplianceImmortalHeart == nil then
			data.ComplianceImmortalHeart = 0
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, onStart)

function mod:OnSave(isSaving)
	local save = {}
	if isSaving then
		local saveData = {}
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			local data = mod:GetData(player)
			saveData["player_"..tostring(i+1)] = data
			saveData["player_"..tostring(i+1)].i = nil
		end
		save.PlayerData = saveData
	end
	save.SpriteStyle = mod.optionNum
	save.AppearanceChance = mod.optionChance
	save.IHAmount = mod.optionImmortalNum
	save.ActOfContritionChance = mod.optionContrition
	save.showAchievement = true
	mod:SaveData(json.encode(save))
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.OnSave)

function mod:OnLoad(isLoading)
	if mod:HasData() then
		local save = json.decode(mod:LoadData())
		if isLoading then
			local loadData = save.PlayerData
			for i = 0, game:GetNumPlayers() - 1 do
				local player = Isaac.GetPlayer(i)
				if loadData["player_"..tostring(i+1)] then
					player:GetData().ImmortalHeart = loadData["player_"..tostring(i+1)]
				end
			end
		end
		mod.optionNum = save.SpriteStyle and save.SpriteStyle or 1
		mod.optionChance = save.AppearanceChance and save.AppearanceChance or 20
		mod.optionContrition = save.ActOfContritionChance and save.ActOfContritionChance or 1
		mod.optionImmortalNum = save.IHAmount and save.IHAmount or 18
		
		if EID then
			if mod.optionContrition == 1 then -- Has to be here because of save data
				EID:addCollectible(601, "↑ {{Tears}} +0.7 Tears up#{{ImmortalHeartIcon}} +1 Immortal Heart#{{AngelDevilChance}} Allows both Devil and Angel deals to be taken#Taking Red Heart damage doesn't reduce Devil/Angel Room chance as much", "Act of contrition", "en_us")
				EID:addCollectible(601, "↑ {{Tears}} Lágrimas +0.7#{{ImmortalHeartIcon}} +1 corazón inmortal#{{AngelDevilChance}} Permite que aparezcan salas del ángel aunque hayas hecho pactos con el diablo antes", "Acto de Contrición", "spa")
				EID:addCollectible(601, "↑ {{Tears}} +0.7 к скорострельности#{{ImmortalHeartIcon}} +1 бессмертное сердце#{{AngelDevilChance}} Позволяет Ангельским комнатам появляться даже в том случае, если ранее была заключена сделка с Дьяволом#Получение урона красными сердцами не так сильно снижает шанс сделки","Покаяние","ru")
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.OnLoad)

function mod:PostUpdateAchiv()
	local showAchievement
	if not showAchievement then
		showAchievement = mod:HasData() and json.decode(mod:LoadData()).showAchievement or false
		if Isaac.GetPlayer().ControlsEnabled and showAchievement ~= true then
			showAchievement = true
			mod:OnSave(true)
			CCO.AchievementDisplayAPI.PlayAchievement("gfx/ui/achievements/achievement_immortalheart.png")
		end	
	end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.PostUpdateAchiv)

-----------------------------------
--Helper Functions (thanks piber)--
-----------------------------------

function mod:GetPlayers(functionCheck, ...)

	local args = {...}
	local players = {}
	
	local game = Game()
	
	for i=1, game:GetNumPlayers() do
	
		local player = Isaac.GetPlayer(i-1)
		
		local argsPassed = true
		
		if type(functionCheck) == "function" then
		
			for j=1, #args do
			
				if args[j] == "player" then
					args[j] = player
				elseif args[j] == "currentPlayer" then
					args[j] = i
				end
				
			end
			
			if not functionCheck(table.unpack(args)) then
			
				argsPassed = false
				
			end
			
		end
		
		if argsPassed then
			players[#players+1] = player
		end
		
	end
	
	return players
	
end

function mod:GetPlayerFromTear(tear)
	for i=1, 3 do
		local check = nil
		if i == 1 then
			check = tear.Parent
		elseif i == 2 then
			check = mod:GetSpawner(tear)
		elseif i == 3 then
			check = tear.SpawnerEntity
		end
		if check then
			if check.Type == EntityType.ENTITY_PLAYER then
				return mod:GetPtrHashEntity(check):ToPlayer()
			elseif check.Type == EntityType.ENTITY_FAMILIAR and check.Variant == FamiliarVariant.INCUBUS then
				local data = mod:GetData(tear)
				data.IsIncubusTear = true
				return check:ToFamiliar().Player:ToPlayer()
			end
		end
	end
	return nil
end

function mod:GetSpawner(entity)
	if entity and entity.GetData then
		local spawnData = mod:GetSpawnData(entity)
		if spawnData and spawnData.SpawnerEntity then
			local spawner = mod:GetPtrHashEntity(spawnData.SpawnerEntity)
			return spawner
		end
	end
	return nil
end

function mod:GetSpawnData(entity)
	if entity and entity.GetData then
		local data = mod:GetData(entity)
		return data.SpawnData
	end
	return nil
end

function mod:GetPtrHashEntity(entity)
	if entity then
		if entity.Entity then
			entity = entity.Entity
		end
		for _, matchEntity in pairs(Isaac.FindByType(entity.Type, entity.Variant, entity.SubType, false, false)) do
			if GetPtrHash(entity) == GetPtrHash(matchEntity) then
				return matchEntity
			end
		end
	end
	return nil
end

function mod:GetData(entity)
	if entity and entity.GetData then	
		local data = entity:GetData()
		if not data.ImmortalHeart then
			data.ImmortalHeart = {}
		end
		return data.ImmortalHeart
	end
	return nil
end

function mod:DidPlayerCollectibleCountJustChange(player)
	local data = mod:GetData(player)
	if data.didCollectibleCountJustChange then
		return true
	end
	return false
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	local data = mod:GetData(player)
	local currentCollectibleCount = player:GetCollectibleCount()
	if not data.lastCollectibleCount then
		data.lastCollectibleCount = currentCollectibleCount
	end
	data.didCollectibleCountJustChange = false
	if data.lastCollectibleCount ~= currentCollectibleCount then
		data.didCollectibleCountJustChange = true
	end
	data.lastCollectibleCount = currentCollectibleCount
end)

--[[mod.entitySpawnData = {}
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, type, variant, subType, position, velocity, spawner, seed)
	mod.entitySpawnData[seed] = {
		Type = type,
		Variant = variant,
		SubType = subType,
		Position = position,
		Velocity = velocity,
		SpawnerEntity = spawner,
		InitSeed = seed
	}
end)
mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(_, entity)
	local seed = entity.InitSeed
	local data = mod:GetData(entity)
	data.SpawnData = mod.entitySpawnData[seed]
end)
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, entity)
	local data = mod:GetData(entity)
	data.SpawnData = nil
end)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	mod.entitySpawnData = {}
end)]]

function mod:Contains(list, x)
	for _, v in pairs(list) do
		if v == x then return true end
	end
	return false
end

function mod:GetRandomNumber(numMin, numMax, rng)
	if not numMax then
		numMax = numMin
		numMin = nil
	end
	
	rng = rng or RNG()

	if type(rng) == "number" then
		local seed = rng
		rng = RNG()
		rng:SetSeed(seed, 1)
	end
	
	if numMin and numMax then
		return rng:Next() % (numMax - numMin + 1) + numMin
	elseif numMax then
		return rng:Next() % numMin
	end
	return rng:Next()
end

OnRenderCounter = 0
IsEvenRender = true
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	OnRenderCounter = OnRenderCounter + 1
	
	IsEvenRender = false
	if Isaac.GetFrameCount()%2 == 0 then
		IsEvenRender = true
	end
end)

--ripairs stuff from revel
function ripairs_it(t,i)
	i=i-1
	local v=t[i]
	if v==nil then return v end
	return i,v
end
function ripairs(t)
	return ripairs_it, t, #t+1
end

--delayed functions
DelayedFunctions = {}

function mod:DelayFunction(func, delay, args, removeOnNewRoom, useRender)
	local delayFunctionData = {
		Function = func,
		Delay = delay,
		Args = args,
		RemoveOnNewRoom = removeOnNewRoom,
		OnRender = useRender
	}
	table.insert(DelayedFunctions, delayFunctionData)
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for i, delayFunctionData in ripairs(DelayedFunctions) do
		if delayFunctionData.RemoveOnNewRoom then
			table.remove(DelayedFunctions, i)
		end
	end
end)

local function delayFunctionHandling(onRender)
	if #DelayedFunctions ~= 0 then
		for i, delayFunctionData in ripairs(DelayedFunctions) do
			if (delayFunctionData.OnRender and onRender) or (not delayFunctionData.OnRender and not onRender) then
				if delayFunctionData.Delay <= 0 then
					if delayFunctionData.Function then
						if delayFunctionData.Args then
							delayFunctionData.Function(table.unpack(delayFunctionData.Args))
						else
							delayFunctionData.Function()
						end
					end
					table.remove(DelayedFunctions, i)
				else
					delayFunctionData.Delay = delayFunctionData.Delay - 1
				end
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	delayFunctionHandling(false)
end)

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	delayFunctionHandling(true)
end)

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	DelayedFunctions = {}
end)

function mod:EsauCheck(player)
	if not player or (player and not player.GetData) then
		return nil
	end
	local currentPlayer = 1
	for i=1, Game():GetNumPlayers() do
		local otherPlayer = Isaac.GetPlayer(i-1)
		local searchPlayer = i
		--added GetPlayerType() to get Jacob and Easu seperatly
		if otherPlayer.ControllerIndex == player.ControllerIndex and otherPlayer:GetPlayerType() == player:GetPlayerType() then
			currentPlayer = searchPlayer
		end
	end
	return currentPlayer
end