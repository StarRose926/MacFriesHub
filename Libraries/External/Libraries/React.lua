local loader = loadstring(game:HttpGet('https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/Libraries/External/ExternalLoader/loader.lua'))()

-- NOTE: ScriptFakeLoader must be SHARED to load the other external libraries!
return function(Package, ScriptFakeLoader)
    local ReactModule = loader.load({
    	user = 'Roblox',
    	repo = 'react-luau',
    	branch = 'main'
    }, {
    	main_zip = 'react-luau-main',
    	src_folder = 'modules'
    }, {
    	Parent = game:GetService('ReplicatedStorage'),
    	Name = 'ReactFolder'
    });
    loader.put(ReactModule, 'react-luau-main', Packages)
    ReactModule:Destroy()
    
    local LuauPolyfillModule = loader.load({
    	user = 'Roblox',
    	repo = 'luau-polyfill',
    	branch = 'main'
    }, {
    	main_zip = 'luau-polyfill-main',
    	src_folder = 'modules'
    }, {
    	Parent = game:GetService('ReplicatedStorage'),
    	Name = 'LuauPolyfillFolder'
    });
    loader.put(LuauPolyfillModule, 'luau-polyfill-main', Packages)
    LuauPolyfillModule:Destroy()
    
    local SymbolModule = loader.load({
    	user = 'Roblox',
    	repo = 'symbol-luau',
    	branch = 'main'
    }, {
    	main_zip = 'symbol-luau-main',
    	src_folder = 'src'
    }, {
    	Parent = game:GetService('ReplicatedStorage'),
    	Name = 'SymbolFolder'
    });
    local Symbol = SymbolModule:WaitForChild('symbol-luau-main')
    Symbol.Name = 'Symbol'
    Symbol.Parent = Packages
    SymbolModule:Destroy()
    
    -- SafeFlags are required to be loaded manually!
    local function loadSafeFlags()
    	local SafeFlags = Instance.new('ModuleScript', Packages)
    	SafeFlags.Name = 'SafeFlags'
    	
    	ScriptFakeLoader.makeModuleCache(SafeFlags, game:HttpGet('https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/bed638621b68cd2ce5e9de4da707767e31a0f804/LuaPackages/Packages/_Index/SafeFlags/SafeFlags/init.lua'))
    	
    	local createGetFFlag = Instance.new('ModuleScript', SafeFlags)
    	createGetFFlag.Name = 'createGetFFlag'
    	
    	ScriptFakeLoader.makeModuleCache(createGetFFlag, game:HttpGet('https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/bed638621b68cd2ce5e9de4da707767e31a0f804/LuaPackages/Packages/_Index/SafeFlags/SafeFlags/createGetFFlag.lua'))
    	
    	local createGetFInt = Instance.new('ModuleScript', SafeFlags)
    	createGetFInt.Name = 'createGetFInt'
    	
    	ScriptFakeLoader.makeModuleCache(createGetFInt, game:HttpGet('https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/bed638621b68cd2ce5e9de4da707767e31a0f804/LuaPackages/Packages/_Index/SafeFlags/SafeFlags/createGetFInt.lua'))
    	
    	local createGetFString = Instance.new('ModuleScript', SafeFlags)
    	createGetFString.Name = 'createGetFString'
    	
    	ScriptFakeLoader.makeModuleCache(createGetFString, game:HttpGet('https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/bed638621b68cd2ce5e9de4da707767e31a0f804/LuaPackages/Packages/_Index/SafeFlags/SafeFlags/createGetFString.lua'))
    	
    	return SafeFlags
    end
    loadSafeFlags()
end
