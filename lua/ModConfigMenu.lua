--#region Mod Config Menu
local mod = ComplianceImmortal

mod.optionNum = 1
mod.optionChance = 20
mod.optionImmortalNum = 18
mod.optionContrition = 1
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
        Maximum = 9,
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
        Maximum = 100,
        Display = function()
            return 'Chance to replace Eternal Heart: '..mod.optionChance..'%'
        end,
        OnChange = function(currentNum)
            mod.optionChance = currentNum
        end,
        Info = "Immortal heart's rarity."
    })

    ModConfigMenu.AddSetting(ImmortalMCM, "Settings",
    {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return mod.optionImmortalNum
        end,
        Default = 18,
        Minimum = 1,
        Maximum = 18,
        Display = function()
            return 'Immortal hearts amount: '..mod.optionImmortalNum..(mod.optionImmortalNum > 12 and " (Maggie's Birthright)" or "")
        end,
        OnChange = function(currentNum)
            mod.optionImmortalNum = currentNum
        end,
        Info = "Amount of Immortal hearts player can have at the time."
    })
	
	ModConfigMenu.AddSetting(ImmortalMCM, "Settings",
	{
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			local current = false
			if mod.optionContrition == 1 then
				current = true
			end
			return current
		end,
		Display = function()
			local onOff = "Off"
			if mod.optionContrition == 1 then
				onOff = "On"
			end
			return "Act of Contrition gives Immortal Heart: " .. onOff
		end,
		OnChange = function(currentBool)
			if currentBool == true then
				mod.optionContrition = 1
			else
				mod.optionContrition = 2
			end
		end,
		Info = "Replaces Act of Contrition's Eternal Heart with an Immortal Heart, like in Antibirth."
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