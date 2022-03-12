local Config = require("tc_lua.mod_compat.mcm.config")
local Enum = require("tc_lua.core.enums")

local MCM = { }

    local Options = {
        [1] = "Vanilla",
        [2] = "Aladar",
		[3] = "Lifebar",
		[4] = "Beautiful",
		[5] = "Goncholito",
		[6] = "Flashy", 
		[7] = "Better Icons", 
		[8] = "Eternal Update",
		[9] = "Re-color",
    }

if ModConfigMenu ~= nil then
    
    local ImmortalMCM = "Immortal Hearts"
	
    ModConfigMenu.UpdateCategory(ImmortalMCM, {
		Info = {"Configuration for Immortal Hearts mod.",}
	})

    ModConfigMenu.AddSetting(ImmortalMCM, "Settings",
    {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return Config.AltGFX
        end,
        Minimum = 1,
        Maximum = 9,
        Display = function()
            return 'Use sprites: ' .. Options[Config.AltGFX]
        end,
        OnChange = function(currentNum)
            Config.AltGFX = currentNum
        end,
        Info = "Change appearance of immortal hearts."
    })

    ModConfigMenu.AddSetting(ImmortalMCM, "Settings",
    {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return Config.SpawnChance
        end,
        Default = 20,
        Minimum = 0,
        Maximum = 100,
        Display = function()
            return 'Chance to replace Eternal Heart: '..Config.SpawnChance..'%'
        end,
        OnChange = function(currentNum)
            Config.SpawnChance = currentNum
        end,
        Info = "Immortal heart's rarity."
    })

    ModConfigMenu.AddSetting(ImmortalMCM, "Settings",
    {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return Config.HP
        end,
        Default = 18,
        Minimum = 1,
        Maximum = 18,
        Display = function()
            local str = tostring(Config.HP)
            if Config.HP > 12 then
                str = str.." (Maggie's Birthright)"
            end
            return 'Immortal hearts amount: '..str
        end,
        OnChange = function(currentNum)
            Config.HP = currentNum
        end,
        Info = "Amount of Immortal hearts player can have at the time."
    })
	
	ModConfigMenu.AddSetting(ImmortalMCM, "Settings",
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			local current = false
			if Config.Contrition == 1 then
				current = true
			end
			return current
		end,
		Display = function()
			local onOff = "Off"
			if Config.Contrition == 1 then
				onOff = "On"
			end
			return "Act of Contrition gives Immortal Heart: " .. onOff
		end,
		OnChange = function(currentBool)
			if currentBool == true then
				Config.Contrition = 1
			else
				Config.Contrition = 2
			end
		end,
		Info = "Replaces Act of Contrition's Eternal Heart with an Immortal Heart, like in Antibirth."
	})


    if EID then
        local strPickup = "" .. EntityType.ENTITY_PICKUP .. "." .. PickupVariant.PICKUP_HEART .. "." .. Enum.HeartSubType.HEART_IMMORTAL

        ModConfigMenu.AddSetting(ImmortalMCM, "Settings",
		{
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				local show = true
                if EID.IgnoredEntities[strPickup] then
                    show = false
                end
                return show
			end,
			Default = true,
			Display = function()
				local displaystring = 'Description: '
				if EID.IgnoredEntities[strPickup] then
					displaystring = displaystring.."Hide"
				else
					displaystring = displaystring.."Show"
				end
				return displaystring
			end,
			OnChange = function(value)
                if value then
                    EID:removeIgnoredEntity(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, Enum.HeartSubType.HEART_IMMORTAL)
                else
                    EID:addIgnoredEntity(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, Enum.HeartSubType.HEART_IMMORTAL)
                end
			end,
			Info = "Show or hide toggle for Immortal heart's EID.",
		})
    end
	
end

return MCM