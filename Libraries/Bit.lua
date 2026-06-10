-- DEPRECATED --
--
-- PLEASE USE THE "bit32" LIBRARY IN ROBLOX INSTEAD!

local bit = {}

bit.band = function(val, by)
	val = math.floor(tonumber(val) or 0)
	by = math.floor(tonumber(by) or 0)

	local result = 0
	local bitval = 1

	for i = 0, 31 do
		local a = val % 2
		local b = by % 2

		if a == 1 and b == 1 then
			result = result + bitval
		end

		val = math.floor(val / 2)
		by = math.floor(by / 2)
		bitval = bitval * 2
	end

	return result
end

bit.bor = function(val, by)
	val = math.floor(tonumber(val) or 0)
	by = math.floor(tonumber(by) or 0)

	local result = 0
	local bitval = 1

	for i = 0, 31 do
		local a = val % 2
		local b = by % 2

		if a == 1 or b == 1 then
			result = result + bitval
		end

		val = math.floor(val / 2)
		by = math.floor(by / 2)
		bitval = bitval * 2
	end

	return result
end

bit.bxor = function(val, by)
	val = math.floor(tonumber(val) or 0)
	by = math.floor(tonumber(by) or 0)

	local result = 0
	local bitval = 1

	for i = 0, 31 do
		local a = val % 2
		local b = by % 2

		-- XOR logic: result bit is 1 if a and b are different
		if (a + b) == 1 then
			result = result + bitval
		end

		val = math.floor(val / 2)
		by = math.floor(by / 2)
		bitval = bitval * 2
	end

	return result
end

bit.bnot = function(val)
	val = math.floor(tonumber(val) or 0)

	local result = 0
	local bitval = 1

	for i = 0, 31 do
		local a = val % 2
		if a == 0 then
			result = result + bitval
		end
		val = math.floor(val / 2)
		bitval = bitval * 2
	end

	return result
end

bit.bmul = function(val, by)
	val = math.floor(tonumber(val) or 0)
	by = math.floor(tonumber(by) or 0)

	local result = 0

	for i = 0, 31 do
		-- Check if the current bit in 'by' is set
		if (by % 2) == 1 then
			result = (result + val) % 4294967296 -- Keep only 32 bits
		end
		-- Shift val left by one bit (multiply by 2)
		val = (val * 2) % 4294967296
		-- Shift by right by one bit (integer divide by 2)
		by = math.floor(by / 2)
	end

	return result
end

bit.bswap = function(val)
	val = math.floor(tonumber(val) or 0)

	local b0 = val % 256                -- lowest byte
	local b1 = math.floor(val / 256) % 256
	local b2 = math.floor(val / 65536) % 256
	local b3 = math.floor(val / 16777216) % 256  -- highest byte

	-- Swap byte order: b0 ↔ b3, b1 ↔ b2
	local result = b0 * 16777216 + b1 * 65536 + b2 * 256 + b3

	return result
end

bit.ror = function(val, by)
	val = math.floor(tonumber(val) or 0) % 4294967296
	by = math.floor(tonumber(by) or 0) % 32

	if by == 0 then return val end

	-- Right shift part
	local right = math.floor(val / (2 ^ by))
	-- Left shift part (wrap-around)
	local left = (val % (2 ^ by)) * (2 ^ (32 - by))

	return (right + left) % 4294967296
end

bit.rol = function(value, shiftCount)
	value = math.floor(tonumber(value) or 0) % 4294967296
	shiftCount = math.floor(tonumber(shiftCount) or 0) % 32

	if shiftCount == 0 then return value end

	-- Left shift part
	local left = (value * (2 ^ shiftCount)) % 4294967296
	-- Bits that wrap around
	local wrap = math.floor(value / (2 ^ (32 - shiftCount)))

	return (left + wrap) % 4294967296
end

bit.tohex = function(val)
	val = math.floor(tonumber(val) or 0) % 4294967296  -- ensure 32-bit unsigned
	return string.format("%08X", val)
end

bit.tobit = function(val)
	val = tonumber(val) or 0
	-- Keep only the lowest 32 bits
	return val % 4294967296
end

bit.lshift = function(val, by)
	val = math.floor(tonumber(val) or 0) % 4294967296
	by = math.floor(tonumber(by) or 0)

	if by <= 0 then return val end
	if by >= 32 then return 0 end

	-- Left shift, modulo 2^32 to simulate 32-bit overflow
	return (val * (2 ^ by)) % 4294967296
end

bit.rshift = function(val, by)
	val = math.floor(tonumber(val) or 0) % 4294967296
	by = math.floor(tonumber(by) or 0)

	if by <= 0 then return val end
	if by >= 32 then return 0 end

	-- Logical right shift: integer divide by 2^by
	local result = math.floor(val / (2 ^ by))
	return result
end

bit.arshift = function(value, shiftCount)
	value = math.floor(tonumber(value) or 0)
	shiftCount = math.floor(tonumber(shiftCount) or 0)

	if shiftCount <= 0 then return value end
	if shiftCount >= 32 then
		return value < 0 and -1 or 0
	end

	local isNeg = value < 0
	if isNeg then
		value = value + 4294967296 -- convert to unsigned 32-bit
	end

	local shifted = math.floor(value / (2 ^ shiftCount))

	if isNeg then
		-- Fill leftmost bits with 1s
		local fill = 0
		for i = 32 - shiftCount, 31 do
			fill = fill + 2 ^ i
		end
		shifted = shifted + fill
		if shifted >= 2147483648 then
			shifted = shifted - 4294967296
		end
	end

	return shifted
end

bit.bdiv = function(dividend, divisor)
	dividend = math.floor(tonumber(dividend) or 0)
	divisor = math.floor(tonumber(divisor) or 0)
	if divisor == 0 then
		return 0
	end
	-- Integer division
	return math.floor(dividend / divisor)
end

bit.badd = function(a, b)
	a = math.floor(tonumber(a) or 0)
	b = math.floor(tonumber(b) or 0)
	return (a + b) % 4294967296
end

bit.bsub = function(a, b)
	a = math.floor(tonumber(a) or 0)
	b = math.floor(tonumber(b) or 0)
	return (a - b) % 4294967296
end

bit.btest = function(val, mask)
	return bit.band(val, mask) == mask and 1 or 0
end

bit.getbyte = function(val, index)
	index = math.floor(index or 0)
	if index < 0 or index > 3 then
		return error("byte index out of range (0–3)")
	end
	
	return bit.band(bit.rshift(val, index * 8), 0xFF)
end

bit.mask = function(n)
	n = math.clamp(math.floor(n or 0), 0, 32)
	if n == 0 then
		return 0
	end
	
	return bit.bsub(bit.lshift(1, n), 1)
end

bit.byteswap = bit.bswap
bit.rrotate = bit.ror
bit.lrotate = bit.rol

return bit
