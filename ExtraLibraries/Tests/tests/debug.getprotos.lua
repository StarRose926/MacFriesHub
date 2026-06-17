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
        local function proto1()
            return 10
        end

        local function proto2()
            return 30
        end

        local function proto3()
            return "60"
        end
    end

    local results = {10, 30, "60"}
    local protos = debug.getprotos(closure)

    test.assert(#protos == 3, 'Did not return the correct amount of Protos in the Closure')
    if #protos ~= 3 then return end

    local res = {protos[1](), protos[2](), protos[3]()}
    test.assert(compare(res, results), 'Did not return the expected results')
end
