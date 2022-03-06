TC_ImmortalHeart = RegisterMod("Edith", 1)

local Enums = require("tc_lua.core.enums")
local Globals = require("tc_lua.core.globals")


require("tc_lua.helpers.class")

--[[
-- Pickup related callbacks
local PostPickupInit = require("tc_lua.callbacks.vanilla.post_pickup_init")
-- Level related callbacks
local PostNewRoom = require("tc_lua.callbacks.vanilla.post_new_room")
-- Game related callbacks
local PostUpdate = require("tc_lua.callbacks.vanilla.post_update")
local PostGameStarted = require("tc_lua.callbacks.vanilla.post_game_started")
local PreGameExit = require("tc_lua.callbacks.vanilla.pre_game_exit")


-- Pickup related callbacks
EdithMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, PostPickupInit)
-- Level related callbacks
EdithMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)
-- Game related callbacks
EdithMod:AddCallback(ModCallbacks.MC_POST_UPDATE, PostUpdate)
EdithMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, PreGameExit)
EdithMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, PostGameStarted)
--]]

require("tc_lua.items.pickups.hearts.immortal_heart")
