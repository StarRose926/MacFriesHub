return function(_, ScriptService)
    local Source = game:HttpGet('https://raw.githubusercontent.com/ryanlua/satchel/refs/heads/main/src/init.luau')
    local MainSource = Source:gsub('BindAction', 'BindCoreAction'):gsub('UnbindAction', 'UnbindCoreAction'):gsub('require%(script.Attribution%)', ''):gsub('require%(script.Parent.topbarplus%)', 'require(script.Parent.TopbarPlus)')

    local Module = Instance.new('ModuleScript')
    Module.Name = 'Stachel'

    ScriptService.makeModuleCache(Module, MainSource)

    return Module
end
