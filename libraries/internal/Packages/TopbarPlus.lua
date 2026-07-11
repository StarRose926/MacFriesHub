local GithubLoader = loadstring(game:HttpGet('hhttps://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/libraries/external/GithubLoader.lua'))()

return function(ScriptService)
    GithubLoader.setGlobal('FakeScriptLoader', ScriptService)

    local TopbarPlus = GithubLoader.load({
        user = '1ForeverHD',
        repo = 'TopbarPlus',
        branch = 'main'
    }, {
        main_zip = 'TopbarPlus-main',
        src_folder = 'src'
    }, {
        Name = 'TopbarPlus',
        Parent = nil
    })

    ScriptService.setScriptEnvirementGlobal(TopbarPlus['TopbarPlus-main'].Attribute, 'print', function(...) end)
    ScriptService.makeModuleCache(TopbarPlus['TopbarPlus-main'].Attribute, game:HttpGet('https://raw.githubusercontent.com/1ForeverHD/TopbarPlus/refs/heads/main/src/Attribute.lua'))

    return TopbarPlus['TopbarPlus-main']
end
