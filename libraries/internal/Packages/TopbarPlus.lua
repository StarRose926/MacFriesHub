local cloneref = cloneref or function(obj) return obj end

return function(GithubLoader, ScriptService)
    GithubLoader.setGlobal('FakeScriptLoader', ScriptService)

    local TopbarPlusFolder = GithubLoader.load({
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

    local CoreGui = cloneref(game:GetService('CoreGui'))
    
    local TopbarPlus = TopbarPlusFolder['TopbarPlus-main']
    TopbarPlus.Parent = CoreGui.MacFries.Modules
    TopbarPlus.Name = 'TopbarPlus'
    TopbarPlusFolder:Destroy()

    ScriptService.makeModuleCache(TopbarPlus, game:HttpGet('https://github.com/1ForeverHD/TopbarPlus/blob/main/src/init.lua'):gsub('localPlayer:WaitForChild%("PlayerGui"%)', 'game:GetService("CoreGui").MacFries.Guis'))
    ScriptService.makeModuleCache(TopbarPlus.Reference, [[
    local object = Instance.new("ObjectValue")
    
    return {
        addToReplicatedStorage = function() return object end,
        getObject = function() return object end
    }]])
    
    ScriptService.setScriptEnvirementGlobal(TopbarPlus.Attribute, 'print', function(...) end)
    ScriptService.setScriptEnvirementGlobal(TopbarPlus.Attribute, 'warn', function(...) end)
    ScriptService.makeModuleCache(TopbarPlus.Attribute, game:HttpGet('https://raw.githubusercontent.com/1ForeverHD/TopbarPlus/refs/heads/main/src/Attribute.lua'))

    return TopbarPlus
end
