local cloneref = cloneref or function(obj) return obj end

local CoreGui = cloneref(game:GetService('CoreGui'))

local MacFries = Instance.new('Folder', CoreGui)
MacFries.Name = 'MacFries'

local Modules = Instance.new('Folder', MacFries)
Modules.Name = 'Modules'

local Guis = Instance.new('Folder', MacFries)
Guis.Name = 'Guis'

return function(GithubLoader, ScriptService)
    for _, name in {'TopbarPlus', 'Stachel'} do
        loadstring(game:HttpGet(string.format('https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/libraries/internal/Packages/%s.lua', name)))()(GithubLoader, ScriptService)
    end
end
