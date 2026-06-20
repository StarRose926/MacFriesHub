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
        print("Hello world")
    end

    local constants = debug.getconstants(closure)

    test.assert(type(constants) == 'table', `Constants result expected to be a Table (got {type(constants)})`)
    if type(constants) ~= 'table' then return end

    test.assert(compare(constants, {
        "print",
        "Hello world"
    }), 'Constants does not match the expected outcome!')
end
