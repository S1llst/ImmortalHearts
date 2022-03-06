local Delay = { }

local delayFunctions = { }

--ripairs stuff from revel
local function ripairs_it(t,i)
    i=i-1
    local v=t[i]
    if v==nil then return v end
    return i,v
end
local function ripairs(t)
    return ripairs_it, t, #t+1
end

function Delay:DelayFunction(_function, delay, removeOnNewRoom, ...)
    local args = {...}
    if _function == nil then
        return
    end
    local delayFunctionData = {
        Function = _function,
        Delay = delay or 0,
        Args = args or { },
        RemoveOnNewRoom = removeOnNewRoom or true
    }
    table.insert(delayFunctions, delayFunctionData)
end

function Delay:OnNewRoom()
    for i, delayFunctionData in ripairs(delayFunctions) do
        if delayFunctionData.RemoveOnNewRoom then
            table.remove(delayFunctions, i)
        end
    end
end

function Delay:OnUpdate()
    for i, delayFunctionData in ripairs(delayFunctions) do
        if delayFunctionData.Delay <= 0 then
            delayFunctionData.Function(table.unpack(delayFunctionData.Args))
            table.remove(delayFunctions, i)
        else
            delayFunctionData.Delay = delayFunctionData.Delay - 1
        end
    end
end

function Delay:OnGameStart(_, isSavedGame)
    delayFunctions = { }
end

return Delay