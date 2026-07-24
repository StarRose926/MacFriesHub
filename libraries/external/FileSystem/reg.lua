local RegistryValueKind do
	RegistryValueKind = {
		Unknown = 0,

		String = 1,
		ExpandString = 2,
		Binary = 3,
		DWord = 4,

		MultiString = 7,

		QWord = 11
	}
end

local RegistryOptions do
	RegistryOptions = {
		None = 0,
		Volatile = 1,
	}
end

local RegistryMemory = {}
local RegistryCache = {}

local switch do
	switch = function(o)
		local s = {}

		s.case = function(_o, f)
			if o == _o then
				task.spawn(function()
					s._d(f())
				end)
			end

			return s
		end

		s.default = function(f)
			s._d = f

			return s
		end

		return s
	end
end

local RegistryParser do
	local function makeBinaryEntry(name, bytes)
		local hexBytes = {}

		if type(bytes) == "string" then
			local str = bytes
			bytes = {}
			for i = 1, #str do
				bytes[i] = string.byte(str, i)
			end
		end

		for i, byte in ipairs(bytes) do
			hexBytes[i] = string.format("%02X", byte)
		end

		return string.format(
			'%s=hex:%s',
			name,
			table.concat(hexBytes, ","):lower()
		)
	end

	local function toQwordBytes(value)
		local bytes = {}

		for i = 1, 8 do
			bytes[i] = string.format("%02X", value % 256)
			value = math.floor(value / 256)
		end

		return table.concat(bytes, ","):lower()
	end

	local function toMultiSz(strings)
		local bytes = {}

		for _, str in ipairs(strings) do
			if str ~= "" then
				for i = 1, #str do
					local c = str:byte(i)
					table.insert(bytes, c)
					table.insert(bytes, 0)
				end
			end

			table.insert(bytes, 0)
			table.insert(bytes, 0)
		end

		table.insert(bytes, 0)
		table.insert(bytes, 0)

		local out = {}

		for _, b in ipairs(bytes) do
			out[#out+1] = string.format("%02X", b)
		end

		return table.concat(out, ","):lower()
	end

	local function toExpandSz(str)
		local bytes = {}

		for i = 1, #str do
			local c = str:byte(i)
			table.insert(bytes, c)
			table.insert(bytes, 0)
		end

		table.insert(bytes, 0)
		table.insert(bytes, 0)

		local out = {}

		for _, b in ipairs(bytes) do
			out[#out+1] = string.format("%02X", b)
		end

		return table.concat(out, ","):lower()
	end


	local function stringify_key(k)
		if typeof(k) == 'string' then
			return string.format('"%s"', k:gsub('\\', '\\\\'):gsub('"', '\\"'))
		end
	end

	local stringify
	stringify = function(obj, p, n, s)
		if typeof(obj) ~= 'table' then
			warn('[RegistryParser]: Failed to parse: Cannot parse non-table!')
			print(debug.traceback())
			return ''
		end

		local str = ''

		if not obj.fullname then
			if n then
				str ..= string.format('[%s\\%s]\n', p, n)
			else
				str ..= string.format('[%s]\n', p)
			end
		else
			str = string.format('[%s]\n', obj.fullname)
		end

		if obj.keys then
			for k_n, k_v in obj.keys do
				if k_v.valueKind == nil or k_v.valueKind == RegistryValueKind.String then
					str ..= string.format('%s=%s', stringify_key(k_n), stringify_key(k_v.value))
				elseif k_v.valueKind == RegistryValueKind.DWord then
					str ..= string.format('%s=dword:%08X', stringify_key(k_n), tonumber(k_v.value))
				elseif k_v.valueKind == RegistryValueKind.QWord then
					str ..= string.format('%s=hex(b):%s', stringify_key(k_n), toQwordBytes(k_v.value))
				elseif k_v.valueKind == RegistryValueKind.Binary then
					str ..= makeBinaryEntry(stringify_key(k_n), k_v.value)
				elseif k_v.valueKind == RegistryValueKind.MultiString then
					str ..= string.format('%s=hex(7):%s', stringify_key(k_n), toMultiSz(string.split(k_v.value, '\n')))
				elseif k_v.valueKind == RegistryValueKind.ExpandString then
					str ..= string.format('%s=hex(2):%s', stringify_key(k_n), toExpandSz(k_v.value))
				end

				str ..= '\n'
			end
		end

		str ..= '\n'

		for m_n, m_v in obj.members do
			str ..= stringify(m_v, (n and p .. '\\' .. n or p), m_n)
		end

		return str
	end



	local function parseQword(data)
		local value = 0
		local multiplier = 1

		for hexByte in data:gmatch("[0-9A-Fa-f]+") do
			value += tonumber(hexByte, 16) * multiplier
			multiplier *= 256
		end

		return value
	end

	local function parseBinary(data)
		local bytes = {}

		for hexByte in data:gmatch("[0-9A-Fa-f]+") do
			table.insert(bytes, tonumber(hexByte, 16))
		end

		return bytes
	end

	local function parseMultiSz(data)
		local bytes = {}

		for hexByte in data:gmatch("[0-9A-Fa-f]+") do
			table.insert(bytes, tonumber(hexByte, 16))
		end

		local result = {}
		local current = {}

		local i = 1
		while i <= #bytes do
			local lo = bytes[i]
			local hi = bytes[i + 1]

			if lo == 0 and hi == 0 then
				if #current > 0 then
					table.insert(result, utf8.char(table.unpack(current)))
					current = {}
				end

				if bytes[i + 2] == 0 and bytes[i + 3] == 0 then
					break
				end

				i = i + 2
			else
				local codepoint = lo + hi * 256
				table.insert(current, codepoint)
				i = i + 2
			end
		end

		return result
	end

	local function parseExpandSz(data)
		local chars = {}

		for hexByte in data:gmatch("[0-9A-Fa-f]+") do
			local byte = tonumber(hexByte, 16)

			if byte == 0 then
				break
			end

			table.insert(chars, string.char(byte))
		end

		return table.concat(chars)
	end




	local function parse(str)
		local tbl_mem = {
			members = RegistryMemory,
			keys = {}
		}

		local current_mem
		local multi_string_lines = {}
		local multi_st_name
		local investigating_multi = false
		local multi_type
		for _, underline in string.split(str, '\n') do
			if underline:sub(1, 1) == '[' and underline:sub(#underline) == ']' then
				local paths = string.split(underline:sub(2, #underline - 1), '\\')

				if #paths == 1 then
					if not tbl_mem.members[paths[1]] then
						tbl_mem.members[paths[1]] = {
							members = {},
							keys = {}
						}
					end

					current_mem = tbl_mem.members[paths[1]]
				elseif #paths > 1 then
					local last_top_old
					local last_top
					local old = tbl_mem.members[paths[1]].members
					last_top_old = tbl_mem.members[paths[1]]
					last_top = old
					table.remove(paths, 1)

					for _, p in paths do
						old = old and old[p]
						last_top = old and old.members or last_top

						if not old then
							local o = {
								members = {},
								keys = {}
							}
							last_top[p] = o
							old = o
							last_top = o.members
						end

						last_top_old = old
						old = old.members
					end

					current_mem = last_top_old
				end
			else
				if investigating_multi == false then
					local name, value = underline:match('"(.-)"="(.-)"')
					if name and value then
						current_mem.keys[name] = {
							value = value,
							valueKind = RegistryValueKind.String
						}
					end

					local name, value = underline:match('"(.-)"=dword:(%x+)')

					if name and value then
						current_mem.keys[name] = {
							value = tonumber(value, 16),
							valueKind = RegistryValueKind.DWord
						}
					end

					local name, data = underline:match('"(.-)"=hex%(b%):(.+)')
					if name and data then
						current_mem.keys[name] = {
							value = parseQword(data),
							valueKind = RegistryValueKind.QWord
						}
					end

					local name, data = underline:match('"(.-)"=hex:(.+)')
					if name and data then
						current_mem.keys[name] = {
							value = parseBinary(data),
							valueKind = RegistryValueKind.Binary
						}
					end

					local name, data = underline:match('"(.-)"=hex%(7%):(.+)')
					if name and data then
						if data:sub(#data, #data) == '\\' then
							multi_st_name = name
							investigating_multi = true
							table.insert(multi_string_lines, data:sub(1, #data - 1))
							multi_type = 'String'
						else
							local str = parseMultiSz(data)
							current_mem.keys[name] = {
								value = table.concat(str, '\n'),
								valueKind = RegistryValueKind.MultiString
							}
						end
					end

					local name, data = underline:match('"(.-)"=hex%(2%):(.+)')
					if name and data then
						if data:sub(#data, #data) == '\\' then
							multi_st_name = name
							investigating_multi = true
							table.insert(multi_string_lines, data:sub(1, #data - 1))
							multi_type = 'Expand'
						else
							local str = parseExpandSz(data)
							current_mem.keys[name] = {
								value = str,
								valueKind = RegistryValueKind.ExpandString
							}
						end
					end
				else
					local end_pos = 0
					for i = 1, #underline do
						if underline:sub(i, i) == '\\' then
							end_pos = i - 1
						end
					end
					if end_pos == 0 then
						investigating_multi = false
						end_pos = #underline
					end

					local a, _ = underline:sub(1, end_pos):gsub(' ', '')
					table.insert(multi_string_lines, a)

					if investigating_multi == false then
						if multi_type == 'String' then
							local str = parseMultiSz(table.concat(multi_string_lines, ''))
							current_mem.keys[multi_st_name] = {
								value = table.concat(str, '\n'),
								valueKind = RegistryValueKind.MultiString
							}
						elseif multi_type == 'Expand' then
							local str = parseExpandSz(table.concat(multi_string_lines, ''))
							current_mem.keys[multi_st_name] = {
								value = str,
								valueKind = RegistryValueKind.MultiString
							}
						end
					end
				end
			end
		end

		return tbl_mem
	end

	RegistryParser = {
		stringify = stringify,
		parse = parse
	}
end

local RegistryPersistence = {
	inMemoryPersistence = 1,
	inExperiencePersistence = 2
}

local RegistryKey do
	local function searchAndCreateSubKey(t, p)
		local running = coroutine.running()

		task.spawn(function()
			repeat
				task.wait()
			until coroutine.status(running) == 'suspended'

			switch(RegistryCache.Persistence)
				.default(function(res, l)
					task.spawn(running, res, l)
				end)
				.case(1, function()
					local top = RegistryMemory[t]
					local res = nil
					local last_top = nil

					local _p = t
					if top then
						for _, path in string.split(p, '\\') do
							_p ..= '\\' .. path
							local old = res or top.members
							res = old[path] and old[path].members

							if not res then
								local o = {
									members = {},
									keys = {},
									fullname = _p,
									name = path
								}
								old[path] = o
								res = o.members
							end

							last_top = old[path]
						end
					end

					return res, last_top
				end)
				.case(2, function()
					
				end)
		end)

		return coroutine.yield()
	end


	local reg_key

	local function createSubKey(t, p, wp, r)
		local _, res = searchAndCreateSubKey(t, p)

		return reg_key(res, t, p)
	end


	reg_key = function(obj, t, p)
		local RegistryKey = {}
		local _, mem_obj = searchAndCreateSubKey(t, p)
		RegistryKey._MemoryObject = mem_obj

		function RegistryKey:CreateSubKey(path, writable_permissionCheck, registrySecurity)
			if not path or typeof(path) ~= 'string' then
				warn(`[RegistryKey] 'CreateSubKey' got an invalid path! Expected it to be a string, but got ({typeof(path or nil)})\n\nTraceback:\n{debug.traceback()}`)
				return
			end

			return createSubKey(t, p .. '\\' .. path, writable_permissionCheck, registrySecurity)
		end

		function RegistryKey:SetValue(name, value, valueKind)
			obj.keys[name] = {
				value = value,
				valueKind = valueKind
			}
		end

		function RegistryKey:GetValue(name)
			local k = obj.keys[name]

			return k and k.value
		end

		function RegistryKey:DeleteValue(name)
			obj.keys[name] = nil
		end

		function RegistryKey:DeleteSubKey(subkey, throwOnMissingSubKey)
			local mems = obj.members

			if not mems[subkey] and throwOnMissingSubKey then
				return error("Cannot delete: The key doesn't exist or the path is invalid.", 0)
			end

			mems[subkey] = nil
		end

		function RegistryKey:OpenSubKey(subkey)
			local _, l = searchAndCreateSubKey(t, subkey)

			return RegistryKey(l, t, p .. '\\' .. subkey)
		end

		return RegistryKey
	end

	RegistryKey = reg_key
end

local RegistryHive do
	local function searchAndCreateSubKey(t, p)
		local running = coroutine.running()

		task.spawn(function()
			repeat
				task.wait()
			until coroutine.status(running) == 'suspended'

			switch(RegistryCache.Persistence)
				.default(function(res, l)
					task.spawn(running, res, l)
				end)
				.case(1, function()
					local top = RegistryMemory[t]
					local res = nil
					local last_top = nil

					local _p = t
					if top then
						for _, path in string.split(p, '\\') do
							_p ..= '\\' .. path
							local old = res or top.members
							res = old[path] and old[path].members

							if not res then
								local o = {
									members = {},
									keys = {},
									fullname = _p,
									name = path
								}
								old[path] = o
								res = o.members
							end

							last_top = old[path]
						end
					end

					return res, last_top
				end)
				.case(2, function()
					
				end)
		end)

		return coroutine.yield()
	end

	local function createSubKey(t, p, wp, o)
		local _o, l = searchAndCreateSubKey(t, p)
		_o.options = o or 0

		return RegistryKey(l, t, p)
	end

	RegistryHive = function(target)
		RegistryMemory[target] = RegistryMemory[target] or {
			members = {},
			keys = {}
		}
		local RegistryObject = {}

		function RegistryObject:CreateSubKey(path, writable_permissionCheck, registryOptions)
			if not path or typeof(path) ~= 'string' then
				warn(`[RegistryKey] 'CreateSubKey' got an invalid path! Expected it to be a string, but got ({typeof(path or nil)})\n\nTraceback:\n{debug.traceback()}`)
				return
			end

			return createSubKey(target, path, writable_permissionCheck, registryOptions)
		end

		function RegistryObject:GetSubKeyNames()
			local r = {}

			for n, _ in RegistryMemory[target].members do
				table.insert(r, n)
			end

			return r
		end

		function RegistryObject:SetValue(name, value, valueKind)
			RegistryMemory[target].keys[name] = {
				value = value,
				valueKind = valueKind
			}
		end

		function RegistryObject:GetValue(name)
			local key = RegistryMemory[target].keys[name]

			return key and key.value
		end

		function RegistryObject:DeleteValue(name, throwOnMissingSubKey)
			local key = RegistryMemory[target].keys

			if not key[name] and throwOnMissingSubKey then
				return error("Cannot delete a subkey tree because the subkey does not exist.", 0)
			end

			key[name] = nil
		end

		function RegistryObject:GetValueKind(name)
			local key = RegistryMemory[target].keys[name]

			return key and key.valueKind
		end

		function RegistryObject:DeleteSubKey(subkey, throwOnMissingSubKey)
			local mems = RegistryMemory[target].members

			if not mems[subkey] and throwOnMissingSubKey then
				return error("Cannot delete: The key doesn't exist or the path is invalid.", 0)
			end

			mems[subkey] = nil
		end

		function RegistryObject:OpenSubKey(name, permissionCheck)
			local _, l = searchAndCreateSubKey(target, name)

			return RegistryKey(l, target, name)
		end

		return RegistryObject
	end
end

local Registry do
	local RegistryService = {}
	RegistryService.ClassName = 'RegistryService'
	RegistryService.Name = 'RegistryService'

	function RegistryService:SetPersistence(persistence)
		RegistryCache.Persistence = persistence
	end

	function RegistryService:GetPersistence()
		return RegistryCache.Persistence
	end

	function RegistryService:CreateRegistryHive(p)
		return RegistryHive(p)
	end

	function RegistryService:SaveToFile(file)
		if writefile and type(writefile) == 'function' then
			writefile(file, 'Windows Registry Editor Version 5.00\n\n' .. RegistryParser.stringify(RegistryMemory.HKEY_CURRENT_USER, 'HKEY_CURRENT_USER'))
		else
			warn('[MacFries][FileIO][Registry]: Failed to save file - "writefile" is not a function!')
		end
	end

	function RegistryService:LoadFromFile(file, f_c)
		if readfile and type(readfile) == 'function' then
			return RegistryParser.parse(readfile(file))
		else
			warn('[MacFries][FileIO][Registry]: Failed to read file - "readfile" is not a function!')
		end
	end

	function RegistryService:SaveToFileSpesific(file, registry, reg_name)
		if writefile and type(writefile) == 'function' then
			writefile(file, 'Windows Registry Editor Version 5.00\n\n' .. RegistryParser.stringify(registry._MemoryObject, reg_name))
		else
			warn('[MacFries][FileIO][Registry]: Failed to save file - "writefile" is not a function!')
		end
	end

	RegistryService.RegistryValueKind = RegistryValueKind

	RegistryService.CurrentMachine = RegistryHive('HKEY_LOCAL_MACHINE')
	RegistryService.CurrentConfig = RegistryHive('HKEY_CURRENT_CONFIG')
	RegistryService.CurrentUser = RegistryHive('HKEY_CURRENT_USER')
	RegistryService.ClassesRoot = RegistryHive('HKEY_CLASSES_ROOT')
	RegistryService.Users = RegistryHive('HKEY_USERS')

	Registry = RegistryService
end

return Registry
