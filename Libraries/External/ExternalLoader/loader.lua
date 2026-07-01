local ScriptFakeLoader = loadstring(game:HttpGet('https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/Libraries/ScriptFakeLoader.lua'))()
local zzlib = loadstring(game:HttpGet('https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/Libraries/External/ExternalLoader/zzlib/zzlib.lua'))()

-- Generated and helped by AI

-- Helper function to transform "react-reconciler" into "ReactReconciler"
local function toPascalCase(str)
	local pascal = string.gsub(str, "([%w])([%w]*)", function(first, rest)
		return string.upper(first) .. rest
	end)
	return string.gsub(pascal, "%-", "")
end

-- Rebuilds the folder structure exactly like Roblox's layout
local function getOrCreateMixedPath(root, pathString)
	local current = root

	-- Since cleanPath looks like: "modules/react-reconciler/src/"
	-- The first segment is always "modules"
	-- The second segment is always the package name
	local isFirstSegment = true
	local isPackageSegment = false

	for chunk in string.gmatch(pathString, "[^/]+") do
		-- Skip the literal "modules" chunk entirely to flatten the folder structure
		if isFirstSegment and chunk == "modules" then
			isFirstSegment = false
			isPackageSegment = true
			continue
		end

		local formattedChunk = chunk

		-- If this is the segment right after "modules", it's the package name!
		if isPackageSegment then
			formattedChunk = toPascalCase(chunk)
			isPackageSegment = false -- Any following chunks (src, forks) are internal
		end

		local found = current:FindFirstChild(formattedChunk)
		if not found then
			found = Instance.new("Folder")
			found.Name = formattedChunk
			found.Parent = current
		end
		current = found
	end
	return current
end

-- Completely strips out extensions like .roblox.luau, .luau, or .lua
local function cleanScriptExtension(fileName)
	-- This pattern matches a dot followed by "luau" or "lua" at the exact end ($) of the string
	local noExt = string.gsub(fileName, "%.luau$", "")
	noExt = string.gsub(noExt, "%.lua$", "")
	return noExt
end

local cache = {
	_cache = {},
	
	set = function(self, name, val)
		self._cache[name] = val
	end,
	get = function(self, name)
		return self._cache[name]
	end,
	forEach = function(self, closure)
		for k, v in self._cache do
			closure(k, v)
		end
	end,
  	clear = function(self)
		table.clear(self._cache)
	end,
}

-- Post-Processing Function to handle custom 'src' lifting and generic 'init' collapsing
local function collapseInitModules(root, OutputFolder)
	-- 1. Traverse deep into the tree first (children first)
	for _, child in ipairs(root:GetChildren()) do
		if child:IsA("Folder") then
			collapseInitModules(child, OutputFolder)
		end
	end

	-- 2. Look for an "init" ModuleScript inside the current folder
	local initFile = root:FindFirstChild("init")

	if initFile and initFile:IsA("ModuleScript") and root ~= OutputFolder then
		local parent = root.Parent

		-- STRATEGY FIX: If the folder is named "src", lift everything to its parent folder
		if root.Name == "src" and parent ~= OutputFolder then
			-- Turn the parent folder into the ModuleScript instead!
			local grandParent = parent.Parent
			local newModule = Instance.new("ModuleScript")
			newModule.Name = parent.Name

			cache:set(newModule, cache:get(initFile))
			-- newModule.Source = initFile.Source

			-- Move all other files/folders out of the parent folder into the new ModuleScript
			for _, item in ipairs(parent:GetChildren()) do
				if item ~= root then -- Skip the old 'src' folder
					item.Parent = newModule
				end
			end

			-- Move all files/folders out of the 'src' folder into the new ModuleScript
			for _, item in ipairs(root:GetChildren()) do
				if item ~= initFile then -- Skip the old 'init' file
					item.Parent = newModule
				end
			end

			-- Final swap: place the package ModuleScript and destroy the old folders
			newModule.Parent = grandParent
			parent:Destroy() -- This automatically deletes the 'src' child folder too!

		else
			-- GENERIC FALLBACK: For non-src folders, collapse normally in place
			local newModule = Instance.new("ModuleScript")
			newModule.Name = root.Name
			
			cache:set(newModule, cache:get(initFile))
			-- newModule.Source = initFile.Source

			for _, item in ipairs(root:GetChildren()) do
				if item ~= initFile then
					item.Parent = newModule
				end
			end

			newModule.Parent = parent
			root:Destroy()
		end
	end
end

local loader = {}

loader.put = function(loaded_package, name, parent)
	local inst
	
	if name then
		inst = loaded_package:FindFirstChild(name)
	else
		inst = loaded_package
	end
	
	if inst then
		for _, v in inst:GetChildren() do
			v.Parent = parent
		end
	end
end

loader.setGlobal = function(name, glob)
	if name == 'FakeScriptLoader' then
		ScriptFakeLoader = glob
	end
end

loader.load = function(git, zip_info, inst_info, fixes)
	-- 2. Setup output folder
	local OutputFolder = inst_info.Instance
	
	if not OutputFolder then
		OutputFolder = Instance.new("Folder")
		OutputFolder.Name = inst_info.Name
		OutputFolder.Parent = inst_info.Parent
	end

	-- 1. Fetch the zip archive from GitHub
	local zipContent = game:HttpGet(string.format("https://github.com/%s/%s/archive/refs/heads/%s.zip", git.user, git.repo, git.branch))

	-- 2. Strip GitHub's ZIP comment so zzlib doesn't crash
	local eocdSignature = "PK\005\006"
	local eocdIndex = string.find(zipContent, eocdSignature, 1, true)
	if eocdIndex then
		local commentLengthPos = eocdIndex + 20
		if #zipContent >= commentLengthPos + 1 then
			zipContent = string.sub(zipContent, 1, commentLengthPos - 1) .. "\000\000"
		end
	end
	
	-- 3. Optimized extraction loop (Kept completely untouched)
	for _, name, offset, size, packed, crc in zzlib.files(zipContent) do
		if not string.match(name, "/$") and string.find(name, string.format("%s/%s/", zip_info.main_zip, zip_info.src_folder), 1, true) then

			-- Clean up path (removes the GitHub root folder)
			local cleanPath = string.gsub(name, "react-luau-main/", "")
			local dirPath, fileName = string.match(cleanPath, "(.-)([^/]+)$")

			-- Only extract scripts
			if string.match(fileName, "%.luau$") or string.match(fileName, "%.lua$") then
				local success, fileData = pcall(function()
					if packed then
						-- The file is compressed, use the unzip function
						return zzlib.unzip(zipContent, offset, crc)
					else
						-- The file is uncompressed raw text, grab it directly with string.sub!
						return string.sub(zipContent, offset, offset + size - 1)
					end
				end)

				if success and fileData then
					-- 4. Rebuild the path structure
					local targetFolder = getOrCreateMixedPath(OutputFolder, dirPath)

					-- Create and name the ModuleScript
					local module = Instance.new("ModuleScript")

					-- Clean name fully handles variations like init.roblox.luau -> init
					local cleanName = cleanScriptExtension(fileName)

					module.Name = cleanName
					-- module.Source = fileData
					module.Parent = targetFolder
					
					cache:set(module, fileData)
				else
					if fixes and fixes[name] then
						fileData = fixes[name]
						
						-- 4. Rebuild the path structure
						local targetFolder = getOrCreateMixedPath(OutputFolder, dirPath)

						-- Create and name the ModuleScript
						local module = Instance.new("ModuleScript")

						-- Clean name fully handles variations like init.roblox.luau -> init
						local cleanName = cleanScriptExtension(fileName)

						module.Name = cleanName
						-- module.Source = fileData
						module.Parent = targetFolder

						cache:set(module, fileData)
					else
						warn("Failed to extract:", name, ' -', fileData)
					end
				end
			end
		end
	end
	
	collapseInitModules(OutputFolder, OutputFolder)
	
	cache:forEach(function(module, content)
		ScriptFakeLoader.makeModuleCache(module, content)
	end)

  	cache:clear()
	
	return OutputFolder
end

return loader
