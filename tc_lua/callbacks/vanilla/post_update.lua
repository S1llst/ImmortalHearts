local Delay = require("tc_lua.helpers.delay")

local function MC_POST_UPDATE(_)
    Delay:OnUpdate()
end

return MC_POST_UPDATE