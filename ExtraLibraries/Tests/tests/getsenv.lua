return function(test)
    local Players = game:GetService('Players')
    local lplr = Players.LocalPlayer or Players:GetPropertyChangedSignal('LocalPlayer'):Wait()
    local Character = lplr.Character or lplr.CharacterAdded:Wait()
    
    local senv = getsenv(Character.Animate)

    test.assert(senv, `Could not retrieve the script-env from the Script ({Script:GetFullName()})`)
    if not senv then return end
    
    test.assert(senv.script == Script, `"script" is not set to the correct Script ({Script:GetFullName()})`)
    test.assert(senv._G ~= _G, '"_G" should not be shared!')
end
