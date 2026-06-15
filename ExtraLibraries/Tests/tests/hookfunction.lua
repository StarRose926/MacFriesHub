return function(test)
    local function closure(a, b)
        if a == b then
            return 'GOOD'
        end

        return 'BAD'
    end

    local org
    org = hookfunction(closure, function(...)
        local args = {...}
        args[2] = args[1]

        return org(table.unpack(args))
    end)

    local res = closure('HELLO!', 'BAD!')

    test.assert(res == 'GOOD', 'Did not hook the function!')
    test.assert(org('HELLO!', 'BAD') == 'BAD', 'Did not return the original function!')
end
