local Config = require("tc_lua.mod_compat.mcm.config")
local Enum = require("tc_lua.core.enums")

local MCM = { }

local Options = {
    [1] = "Vanilla",
    [2] = "Aladar",
    [3] = "Lifebar",
    [4] = "Beautiful",
    [5] = "Goncholito",
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
        Maximum = 5,
        Display = function()
            return 'Use sprites: ' .. Options[Config.AltGFX]
        end,
        OnChange = function(currentNum)
            Config.AltGFX = currentNum
        end,
        Info = "Change appearance of immortal hearts."
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