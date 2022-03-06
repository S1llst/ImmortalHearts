local Delay = require("tc_lua.helpers.delay")

local function MC_POST_GAME_STARTED(_, isExistingRun)
    Delay:OnGameStart(isExistingRun)
end

return MC_POST_GAME_STARTED