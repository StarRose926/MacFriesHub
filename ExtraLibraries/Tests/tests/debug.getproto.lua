local function compare(t1, t2)
    for i, v in t1 do
        if t2[i] ~= v then
            return false
        end
    end

    return true
end

return function(test)
    local function closure()
        local function proto1() return 10 end
        local function proto2() return 20 end
        local function proto3() return "30" end
        local function proto4() return "40" end
    end

    local per_results = {10, 20, "30", "40"}

    local proto_1_proxy = debug.getproto(closure, 1)
    test.assert(proto_1_proxy, 'Proto 1 in closure is invalid!')
    if not proto_1_proxy then return end

    local results = {}

    local protos = debug.getproto(closure, 1, true)
    if protos then
        for idx, proto in protos do
            local t = type(proto) == 'function'
            test.assert(t, `Prototype #{idx} was not a function`)
            if not t then return end

            table.insert(results, proto())
        end

        test.assert(compare(results, per_results), '1 or more results did not match the expected prototypes')
    end
end
