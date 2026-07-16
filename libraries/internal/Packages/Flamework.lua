local cloneref = cloneref or function(obj) return obj end

return function(_, ScriptService)
    local CoreGui = cloneref(game:GetService('CoreGui'))
    local Modules = CoreGui.MacFries.Modules
  
    local Flamework = Instance.new('ModuleScript', Modules)
    Flamework.Name = 'Flamework'

    ScriptService.makeModuleCache(Flamework, [[local Flamework = {}
Flamework.idToObj = {}

function Flamework.resolve(path)
    local dep = Flamework.idToObj[path]
    if not dep then
        warn(string.format("[Flamework]: Dependency '%s' does not exist!", path))
        print(string.format("- Script '%s', Line %s", debug.info(1, 's'), tostring(debug.info(1, 'l'))))

        return
    end

    return dep
end

function Flamework.create(path, dependency)
    if not Flamework.idToObj[path] then
        Flamework.idToObj[path] = dependency
    end
end

return Flamework]])

    return Flamework
end
