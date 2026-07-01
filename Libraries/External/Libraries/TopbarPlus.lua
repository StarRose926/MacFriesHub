-- Main code from (1ForeverHD): https://github.com/1ForeverHD/TopbarPlus/tree/main
-- TopbarPlus LICENSE: https://github.com/1ForeverHD/TopbarPlus/tree/main?tab=License-1-ov-file
--
-- NOTE: LOADER CODE NOT BY 1ForeverHD

local loader = loadstring(game:HttpGet('https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/Libraries/External/ExternalLoader/loader.lua'))()

return function(Packages, ScriptFakeLoader)
    local TopbarPlusModule = loader.load({
        user = '1ForeverHD',
        repo = 'TopbarPlus',
        branch = 'main'
    }, {
        main_zip = 'TopbarPlus-main',
        src_folder = 'src'
    }, {
        Parent = nil,
        Name = 'TopbarPlusFolder'
    });

    local TopbarModule = TopbarPlusModule:WaitForChild('TopbarPlus-main');
    TopbarModule.Name = 'TopbarPlus'
    TopbarModule.Parent = Packages
    TopbarPlusModule:Destroy()

    -- Set and reload env!
    ScriptFakeLoader.setScriptEnvirementGlobal(TopbarModule.Attribute, 'print', function(...) end)
    ScriptFakeLoader.makeModuleCache(TopbarModule.Attribute, game:HttpGet('https://raw.githubusercontent.com/1ForeverHD/TopbarPlus/refs/heads/main/src/Attribute.lua'))

    -- Lets fix it up a little, shall we?
    ScriptFakeLoader.makeModuleCache(TopbarModule.Reference, game:HttpGet('https://raw.githubusercontent.com/1ForeverHD/TopbarPlus/refs/heads/main/src/Reference.lua'):gsub('ReplicatedStorage', 'RobloxReplicatedStorage'))
    ScriptFakeLoader.makeModuleCache(TopbarModule, game:HttpGet('https://raw.githubusercontent.com/1ForeverHD/TopbarPlus/refs/heads/main/src/init.lua'):gsub('localPlayer:WaitForChild(%"PlayerGui%")', 'game:GetService(%"CoreGui%")'))
    
    return TopbarModule
end
