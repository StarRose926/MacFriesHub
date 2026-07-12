local cloneref = cloneref or function(obj) return obj end

return function(_, ScriptService)
    local Source = game:HttpGet('https://raw.githubusercontent.com/ryanlua/satchel/refs/heads/main/src/init.luau')
    local MainSource = Source:gsub('BindAction', 'BindCoreAction'):gsub('UnbindAction', 'UnbindCoreAction'):gsub('require%(script.Attribution%)', ''):gsub('require%(script.Parent.topbarplus%)', 'require(script.Parent.TopbarPlus)'):gsub('Players.LocalPlayer:WaitForChild%("PlayerGui"%)', 'game:GetService("CoreGui").MacFries.Guis')

    local Module = Instance.new('ModuleScript')
    Module.Name = 'Satchel'
    Module.Parent = cloneref(game:GetService('CoreGui')).MacFries.Modules

    ScriptService.makeModuleCache(Module, MainSource)

    return Module
end
