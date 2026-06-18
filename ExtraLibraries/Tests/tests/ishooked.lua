return function(test)
    local did_hookfunction_succeed = test.did_succeed('hookfunction')
  
    test.assert(did_hookfunction_succeed, 'Cannot run this test medout hookfunction being successfull!')
    if not did_hookfunction_succeed then return end

    local ishooked = ishooked or isfunctionhooked
  
    local function closure()
        return 'Good!'
    end

    test.assert(ishooked(closure) == false, 'Did not return false when the closure was not hooked')
    
    hookfunction(closure, function()
        return 'HOOKED'
    end)
    test.assert(ishooked(closure) == true, 'Did not return true when the closure was hooked')
end
