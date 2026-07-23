local Bin = {}
local BinData = {}

function BinData:new(reporting, data)
	self.writePosition = 0
	self.readPosition = 0
	
	self.buffer = reporting == 'buffer' and data or buffer.fromstring(data)
	
	self.length = buffer.len(self.buffer)
	self.size = self.length
	
	return self
end

function BinData:read(mode, bitCount)
	local data
	local offset = self.readPosition
	
	if mode == 'u8' then
		self.readPosition = offset + 1
		data = buffer.readu8(self.buffer, offset)
	elseif mode == 'u16' then
		self.readPosition = offset + 2
		data = buffer.readu16(self.buffer, offset)
	elseif mode == 'u32' then
		self.readPosition = offset + 4
		data = buffer.readu32(self.buffer, offset)
	elseif mode == 'i8' then
		self.readPosition = offset + 1
		data = buffer.readi8(self.buffer, offset)
	elseif mode == 'i16' then
		self.readPosition = offset + 2
		data = buffer.readi16(self.buffer, offset)
	elseif mode == 'i32' then
		self.readPosition = offset + 4
		data = buffer.readi32(self.buffer, offset)
	elseif mode == 'f32' then
		self.readPosition = offset + 4
		data = buffer.readf32(self.buffer, offset)
	elseif mode == 'f64' then
		self.readPosition = offset + 8
		data = buffer.readf64(self.buffer, offset)
	elseif mode == 'bits' then
		local len = bitCount or self:read('u32')
		self.readPosition += len
		data = buffer.readbits(self.buffer, offset, len)
	elseif mode == 'string' then
		local len = bitCount or self:read('u32')
		self.readPosition += len
		data = buffer.readstring(self.buffer, offset, len)
	end
	
	return data
end

function BinData:write(mode, data, bitCount, storeBit)
	local offset = self.writePosition

	if mode == 'u8' then
		self.writePosition = offset + 1
		buffer.writeu8(self.buffer, offset, data)
	elseif mode == 'u16' then
		self.writePosition = offset + 2
		buffer.writeu16(self.buffer, offset, data)
	elseif mode == 'u32' then
		self.writePosition = offset + 4
		buffer.writeu32(self.buffer, offset, data)
	elseif mode == 'i8' then
		self.writePosition = offset + 1
		buffer.writei8(self.buffer, offset, data)
	elseif mode == 'i16' then
		self.writePosition = offset + 2
		buffer.writei16(self.buffer, offset, data)
	elseif mode == 'i32' then
		self.writePosition = offset + 4
		buffer.writei32(self.buffer, offset, data)
	elseif mode == 'f32' then
		self.writePosition = offset + 4
		buffer.writef32(self.buffer, offset, data)
	elseif mode == 'f64' then
		self.writePosition = offset + 8
		buffer.writef64(self.buffer, offset, data)
	elseif mode == 'bits' then
		self.writePosition = offset + bitCount
		
		if storeBit then
			self:write('u32', bitCount)
		end
		
		buffer.writebits(self.buffer, offset + (storeBit and 4 or 0), bitCount, data)
	elseif mode == 'string' then
		local len = bitCount or #data
		self.writePosition = offset + len
		
		if storeBit then
			self:write('u32', len)
		end
		
		buffer.writestring(self.buffer, offset + (storeBit and 4 or 0), data)
	end
end

function BinData:getBuffer(): buffer
	return self.buffer
end

function BinData:setBuffer(b: buffer)
	self.buffer = b
end

function BinData:replaceBuffer(b: buffer)
	self.buffer = b
	self.readPosition = 0
	self.writePosition = 0
end

function BinData:tostring()
	return buffer.tostring(self.buffer)
end

local BinRead = {}
local BinWrite = {}

Bin.__index = BinData

Bin.parse = function(data)
	local self = setmetatable({}, Bin)
	
	return self:new(data)
end

Bin.stringify = function(data)
	return data:tostring()
end

Bin.newBinData = function(len)
	local self = setmetatable({}, Bin)

	return self:new('buffer', buffer.create(len))
end

Bin.fromString = function(str)
	return setmetatable({}, Bin):new('string', str)
end

return Bin
