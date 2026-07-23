local Bin = {}
local BinData = {}
BinData.__index = BinData

function BinData.new(reporting, data)
	local self = setmetatable({}, BinData)
	self.writePosition = 0
	self.readPosition = 0

	if reporting == 'buffer' then
		self.buffer = data
	else
		self.buffer = buffer.fromstring(data)
	end

	self.length = buffer.len(self.buffer)
	self.size = self.length

	return self
end

function BinData:read(mode, bitCount)
	local data
	local offset = self.readPosition

	if mode == 'u8' then
		self.readPosition += 1
		data = buffer.readu8(self.buffer, offset)
	elseif mode == 'u16' then
		self.readPosition += 2
		data = buffer.readu16(self.buffer, offset)
	elseif mode == 'u32' then
		self.readPosition += 4
		data = buffer.readu32(self.buffer, offset)
	elseif mode == 'i8' then
		self.readPosition += 1
		data = buffer.readi8(self.buffer, offset)
	elseif mode == 'i16' then
		self.readPosition += 2
		data = buffer.readi16(self.buffer, offset)
	elseif mode == 'i32' then
		self.readPosition += 4
		data = buffer.readi32(self.buffer, offset)
	elseif mode == 'f32' then
		self.readPosition += 4
		data = buffer.readf32(self.buffer, offset)
	elseif mode == 'f64' then
		self.readPosition += 8
		data = buffer.readf64(self.buffer, offset)
	elseif mode == 'string' then
		local len = bitCount or self:read('u32')
		data = buffer.readstring(self.buffer, self.readPosition, len)
		self.readPosition += len
	end

	return data
end

function BinData:write(mode, data, bitCount, storeLength)
	if mode == 'u8' then
		buffer.writeu8(self.buffer, self.writePosition, data)
		self.writePosition += 1
	elseif mode == 'u16' then
		buffer.writeu16(self.buffer, self.writePosition, data)
		self.writePosition += 2
	elseif mode == 'u32' then
		buffer.writeu32(self.buffer, self.writePosition, data)
		self.writePosition += 4
	elseif mode == 'i8' then
		buffer.writei8(self.buffer, self.writePosition, data)
		self.writePosition += 1
	elseif mode == 'i16' then
		buffer.writei16(self.buffer, self.writePosition, data)
		self.writePosition += 2
	elseif mode == 'i32' then
		buffer.writei32(self.buffer, self.writePosition, data)
		self.writePosition += 4
	elseif mode == 'f32' then
		buffer.writef32(self.buffer, self.writePosition, data)
		self.writePosition += 4
	elseif mode == 'f64' then
		buffer.writef64(self.buffer, self.writePosition, data)
		self.writePosition += 8
	elseif mode == 'string' then
		local str = tostring(data or "")
		local len = bitCount or #str

		if storeLength then
			self:write('u32', len)
		end

		buffer.writestring(self.buffer, self.writePosition, str, len)
		self.writePosition += len
	end
end

function BinData:getBuffer()
	return self.buffer
end

function BinData:setBuffer(b)
	self.buffer = b
	self.length = buffer.len(b)
	self.size = self.length
end

function BinData:replaceBuffer(b)
	self:setBuffer(b)
	self.readPosition = 0
	self.writePosition = 0
end

function BinData:tostring()
	return buffer.tostring(self.buffer)
end

-- Static helper constructor methods
Bin.parse = function(data)
	return BinData.new('string', data)
end

Bin.stringify = function(data)
	return data:tostring()
end

Bin.newBinData = function(len)
	return BinData.new('buffer', buffer.create(len))
end

Bin.fromString = function(str)
	return BinData.new('string', str)
end

return Bin
