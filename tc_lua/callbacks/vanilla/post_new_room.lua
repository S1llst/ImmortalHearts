local Delay = require("tc_lua.helpers.delay")

local function MC_POST_NEW_ROOM(_)
    Delay:OnNewRoom()
end

return MC_POST_NEW_ROOM