--#region Mod Config Menu
local mod = ComplianceImmortal

mod.optionNum = 1
mod.optionChance = 20
    local Options = {
        [1] = "Vanilla",
        [2] = "Aladar",
		[3] = "Lifebar",
		[4] = "Beautiful",
		[5] = "Goncholito",
    }

if ModConfigMenu then
    
    local ImmortalMCM = "Immortal Hearts"
	ModConfigMenu.UpdateCategory(ImmortalMCM, {
		Info = {"Configuration for Immortal Hearts mod.",}
	})

    ModConfigMenu.AddSetting(ImmortalMCM, "Settings",
    {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return mod.optionNum
        end,
        Minimum = 1,
        Maximum = 5,
        Display = function()
            return 'Use sprites: ' .. Options[mod.optionNum]
        end,
        OnChange = function(currentNum)
            mod.optionNum = currentNum
        end,
        Info = "Change appearance of immortal hearts."
    })

    ModConfigMenu.AddSetting(ImmortalMCM, "Settings",
    {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return mod.optionChance
        end,
        Default = 20,
        Minimum = 0,
        Maximum = 50,
        Display = function()
            return 'Chance to replace Eternal Heart: '..mod.optionChance..'%'
        end,
        OnChange = function(currentNum)
            mod.optionChance = currentNum
        end,
        Info = "Immortal heart's rarity."
    })

    if EID then
        ModConfigMenu.AddSetting(ImmortalMCM, "Settings",
		{
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				local show = true
                if EID.IgnoredEntities["5.10.902"] then
                    show = false
                end
                return show
			end,
			Default = true,
			Display = function()
				local displaystring = 'Description: '
				if EID.IgnoredEntities["5.10.902"] then
					displaystring = displaystring.."Hide"
				else
					displaystring = displaystring.."Show"
				end
				return displaystring
			end,
			OnChange = function(value)
                if value then
                    EID:removeIgnoredEntity(5,10,902)
                else
                    EID:addIgnoredEntity(5,10,902)
                end
			end,
			Info = "Show or hide toggle for Immortal heart's EID.",
		})
    end
	
end