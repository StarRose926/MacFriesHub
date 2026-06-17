-- getproto/getprotos - maybe work diffirently depending on executor:
local isProtoV2_Behavior = false
pcall(function()
    local function closure()
        local function proto() return 1 end
    end

    local proto = debug.getproto(closure, 1)
    if typeof(proto) ~= 'function' then
        isProtoV2_Behavior = true
    end
end)

local function getprotos(fn)
    if isProtoV2_Behavior then
        return debug.getproto(fn, 1, true)
    else
        return debug.getprotos(fn)
    end
end

local function getproto(fn, index)
    if isProtoV2_Behavior then
        return getprotos(fn)[index]
    else
        return debug.getproto(fn, index)
    end
end

return {
    getproto = getproto,
    getprotos = getprotos
}
