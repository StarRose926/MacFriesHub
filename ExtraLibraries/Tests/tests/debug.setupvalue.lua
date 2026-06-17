return function(test)
    local up_1 = 1
    local function closure(a)
        up_1 += a

        return up_1
    end

    debug.setupvalue(closure, 1, 5)
    test.assert(closure(5) == 10, 'Did not edit the upvalue 1!')
    test.assert(up_1 == 10, 'Did not edit the upvalue 1 for the entire script closure!')
end
