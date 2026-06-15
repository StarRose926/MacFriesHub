return function(test)
    local Script = game:FindFirstChildWhichIsA('LocalScript', true)
    local senv = getsenv(Script)

    test.assert(senv, `Could not retrieve the script-env from the Script ({Script:GetFullName()})`)
    test.assert(senv.script == Script, `"script" is not set to the correct Script ({Script:GetFullName()})`)
    test.assert(senv._G ~= _G, '"_G" should not be shared!')
end
