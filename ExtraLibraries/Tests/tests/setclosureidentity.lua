return function(test)
    local setclosureidentity = setclosureidentity or setclosurecaps

    local coregui_check = function()
        return game:GetService('CoreGui') == nil
    end

    setclosureidentity(coregui_check, 2)
    test.assert(coregui_check(), 'Closure Identity 2 should not be able to access the CoreGui')
end
