local cache = {}
local script_env_changes = {}

local clonefunc = clonefunc or clonefunction or function(func)
	return function(...)
		return func(...)
	end
end

local function setScriptEnvirementGlobal(script, glob, newGlob)
	script_env_changes[script] = script_env_changes[script] or {}
	
	script_env_changes[script][glob] = newGlob
end

local function makeCacheRequire(module)
	local moduleCache = cache[module]

	if moduleCache then
		if not moduleCache.cache then
			moduleCache.cache = moduleCache.Function()
		end

		return moduleCache.cache
	end

	return require(module)
end

local function makeModuleCache(module, code, path)
	local fenv = getfenv()
	local req = clonefunc(makeCacheRequire)
	
	local spesific_env = script_env_changes[module]

	local env = setmetatable({}, {
		__index = function(self, index)
			if index == 'require' then
				return req
			elseif index == 'script' then
				return module
			elseif spesific_env and spesific_env[index] then
				return spesific_env[index]
			end

			return fenv[index]
		end,
		__newindex = function(self, index, newIndex)
			if index == 'require' then
				req = newIndex
				return
			elseif index == 'script' then
				module = newIndex
				return
			elseif spesific_env and spesific_env[index] then
				spesific_env[index] = newIndex
				fenv[index] = newIndex
				return
			end

			fenv[index] = newIndex
		end
	})

	local func = loadstring(code, '=' .. (path or module:GetFullName()))
	setfenv(func, env)

	cache[module] = {
		cache = nil,
		Function = func
	}
end

local function makeLocalScript(script, code, path)
	local fenv = getfenv()
	local req = clonefunc(makeCacheRequire)
	
	local spesific_env = script_env_changes[module]

	local env = setmetatable({}, {
		__index = function(self, index)
			if index == 'require' then
				return req
			elseif index == 'script' then
				return script
			elseif spesific_env and spesific_env[index] then
				return spesific_env[index]
			end

			return fenv[index]
		end,
		__newindex = function(self, index, newIndex)
			if index == 'require' then
				req = newIndex
				return
			elseif index == 'script' then
				script = newIndex
				return
			elseif spesific_env and spesific_env[index] then
				spesific_env[index] = newIndex
				fenv[index] = newIndex
				return
			end

			fenv[index] = newIndex
		end
	})

	local func = loadstring(code, '=' .. (path or script:GetFullName()))
	setfenv(func, env)

	return func()
end

return {
	setScriptEnvirementGlobal = setScriptEnvirementGlobal,
	makeCacheRequire = makeCacheRequire,
	makeModuleCache = makeModuleCache,
	makeLocalScript = makeLocalScript
}
