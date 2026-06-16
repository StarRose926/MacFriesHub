return function(test)
    local function closure()
        print("Constants!")
    end

    local r1, r2 = debug.getconstant(closure, 1) == 'print', debug.getconstant(closure, 2) == 'Constants!'
    test.assert(r1, 'Did not return the correct constant for (constant 1) in the closure provided!')
    test.assert(r2, 'Did not return the correct constant for (constant 2) in the closure provided!')
end
