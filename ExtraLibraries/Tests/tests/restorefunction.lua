return function(test)
    local did_hookfunction_succeed = test.did_succeed('hookfunction')
  
    test.assert(did_hookfunction_succeed, 'Cannot run test medout hookfunction being successfull!')
    if not did_hookfunction_succeed then return end

    local closure = function()
        return 'GOOD'
    end

    hookfunction(closure, function()
        return 'HOOKED'
    end)
    restorefunction(closure)

    test.assert(closure() == 'GOOD', 'Did not restore the function from the hook!')
end
