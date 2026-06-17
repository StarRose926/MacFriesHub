return function(test)
    local function closure()
        local function proto1() end
        local function proto2() end
        local function proto3() end
    end

    local protos = debug.getprotos(closure)

    test.assert(#protos == 3, 'Did not return the correct amount of Protos in the Closure')
    if #protos ~= 3 then return end
end
