-- WE DO NOT TRUST THE EXECUTORS IN ADDING "crypt"!

local crypt = {
	base64 = {},
	custom = {}
}
local function to_base64(data)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	return ((data:gsub('.', function(x) 
		local r,b='',x:byte()
		for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
		return r;
	end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then return '' end
		local c=0
		for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
		return b:sub(c+1,c+1)
	end)..({ '', '==', '=' })[#data%3+1])
end
crypt.base64encode = to_base64
crypt.base64.encode = to_base64
crypt.base64_encode = to_base64

local function from_base64(data)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	data = string.gsub(data, '[^'..b..'=]', '')
	return (data:gsub('.', function(x)
		if (x == '=') then return '' end
		local r,f='',(b:find(x)-1)
		for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
		return r;
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if (#x ~= 8) then return '' end
		local c=0
		for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
		return string.char(c)
	end))
end
crypt.base64decode = from_base64
crypt.base64.decode = from_base64
crypt.base64_decode = from_base64


local function generatebytes(size)
	local byte = ''
	for i = 1, size do
		byte = byte .. string.char(math.random(33, 126))
	end
	return to_base64(byte)
end
crypt.generatebytes = generatebytes


local function generatekey()
	local key = ''
	for i = 1, 32 do
		key = key .. string.char(({
			[1] = math.random(48, 57),
			[2] = math.random(65, 90),
			[3] = math.random(97, 122)
		})[math.random(1, 3)])
	end
	return to_base64(key)
end
crypt.generatekey = generatekey




local bit = bit32


-- Generate a random IV (initialization vector)
local function generateIV(size)
	size = size or 16
	local chars = {}
	for i = 1, size do
		chars[i] = string.char(math.random(0, 255))
	end
	return table.concat(chars)
end

-- XOR encrypt/decrypt
local function xorData(data, key, iv)
	iv = iv or ""
	local out = {}
	for i = 1, #data do
		local dataByte = string.byte(data, i)
		local keyByte = string.byte(key, ((i - 1) % #key) + 1)
		local ivByte = #iv > 0 and string.byte(iv, ((i - 1) % #iv) + 1) or 0
		out[i] = string.char(bit.bxor(dataByte, keyByte, ivByte))
	end
	return table.concat(out)
end

local function encrypt(plaintext, key, iv, mode)
	mode = mode or "CBC"
	if mode == "CBC" and not iv then
		iv = generateIV(#key)
	end
	local encrypted = xorData(plaintext, key, iv)
	return encrypted, iv
end

local function decrypt(ciphertext, key, iv, mode)
	mode = mode or "CBC"
	return xorData(ciphertext, key, iv)
end

crypt.custom.encrypt = encrypt
crypt.custom.decrypt = decrypt


crypt.encrypt = function(data, key)
	assert(type(data) == "string", "data must be a string")
	assert(type(key) == "string", "key must be a string")
	assert(#key > 0, "key cannot be empty")

	local encrypted = table.create(#data)
	for i = 1, #data do
		local dataByte = string.byte(data, i)
		local keyByte = string.byte(key, ((i - 1) % #key) + 1)
		local encryptedByte = bit32.bxor(dataByte, keyByte)
		encrypted[i] = string.char(encryptedByte)
	end
	return table.concat(encrypted)
end

crypt.decrypt = function(data, key)
	assert(type(data) == "string", "data must be a string")
	assert(type(key) == "string", "key must be a string")
	assert(#key > 0, "key cannot be empty")

	local decrypted = table.create(#data)
	for i = 1, #data do
		local dataByte = string.byte(data, i)
		local keyByte = string.byte(key, ((i - 1) % #key) + 1)
		local decryptedByte = bit32.bxor(dataByte, keyByte)
		decrypted[i] = string.char(decryptedByte)
	end
	return table.concat(decrypted)
end



-- Hash.lua
-- Roblox-compatible hashing module (pure-Lua)
-- Supports: md5, sha1, sha256, sha512, sha384 (sha384 is sha512 truncated)
-- SHA3 (keccak) NOT implemented here — placeholder will error.
local bitand = bit.band

local function toHex(bytes)
	local t = {}
	for i = 1, #bytes do
		t[i] = string.format("%02x", bytes:byte(i))
	end
	return table.concat(t)
end

-- =========================
-- MD5 (RFC 1321) (pure-lua)
-- =========================
-- Implementation adapted for readability and Roblox (uses bit32)
local function md5(msg)
	local s = {
		7,12,17,22, 7,12,17,22, 7,12,17,22, 7,12,17,22,
		5,9,14,20, 5,9,14,20, 5,9,14,20, 5,9,14,20,
		4,11,16,23, 4,11,16,23, 4,11,16,23, 4,11,16,23,
		6,10,15,21, 6,10,15,21, 6,10,15,21, 6,10,15,21
	}
	local K = {}
	for i = 1, 64 do
		K[i] = math.floor(math.abs(math.sin(i)) * 2^32) % 2^32
	end

	local function leftrotate(x, n)
		return bit.lrotate(x, n)
	end

	local function toWordsLE(str)
		local t = {}
		for i = 1, #str, 4 do
			local a = string.byte(str, i) or 0
			local b = string.byte(str, i+1) or 0
			local c = string.byte(str, i+2) or 0
			local d = string.byte(str, i+3) or 0
			t[#t+1] = a + b*256 + c*65536 + d*16777216
		end
		return t
	end

	-- Pre-processing (padding)
	local origlen = #msg
	local bitlen = origlen * 8
	msg = msg .. string.char(0x80)
	while (#msg % 64) ~= 56 do
		msg = msg .. string.char(0)
	end
	-- append original length as 64-bit little-endian
	for i = 0,7 do
		msg = msg .. string.char(bitand(bit.rshift(bitlen, i*8), 0xFF))
	end

	local a0 = 0x67452301
	local b0 = 0xEFCDAB89
	local c0 = 0x98BADCFE
	local d0 = 0x10325476

	for chunkStart = 1, #msg, 64 do
		local chunk = msg:sub(chunkStart, chunkStart + 63)
		local M = toWordsLE(chunk)
		local A, B, C, D = a0, b0, c0, d0

		for i = 1,64 do
			local F, g
			if i <= 16 then
				F = bit.bor(bit.band(B, C), bit.band(bit.bnot(B), D))
				g = i
			elseif i <= 32 then
				F = bit.bor(bit.band(D, B), bit.band(bit.bnot(D), C))
				g = ((5 * (i-1) + 1) % 16) + 1
			elseif i <= 48 then
				F = bit.bxor(B, C, D)
				g = ((3 * (i-1) + 5) % 16) + 1
			else
				F = bit.bxor(C, bit.bnot(D), B)
				g = ((7 * (i-1)) % 16) + 1
			end

			local dTemp = D
			D = C
			C = B
			local sum = (A + F + K[i] + (M[g] or 0)) % 2^32
			B = (B + leftrotate(sum, s[i])) % 2^32
			A = dTemp
		end

		a0 = (a0 + A) % 2^32
		b0 = (b0 + B) % 2^32
		c0 = (c0 + C) % 2^32
		d0 = (d0 + D) % 2^32
	end

	-- produce little-endian bytes
	local function toBytesLE32(x)
		local t = {}
		for i = 0,3 do
			t[#t+1] = string.char(bit.band(bit.rshift(x, i*8), 0xFF))
		end
		return table.concat(t)
	end

	local digest = table.concat{toBytesLE32(a0), toBytesLE32(b0), toBytesLE32(c0), toBytesLE32(d0)}
	return toHex(digest)
end

-- =========================
-- SHA-1 (RFC 3174)
-- =========================
local function sha1(msg)
	local function leftrotate(x, n)
		return bit.lrotate(x, n)
	end

	local h0, h1, h2, h3, h4 = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0

	local origlen = #msg * 8
	msg = msg .. string.char(0x80)
	while (#msg % 64) ~= 56 do
		msg = msg .. string.char(0)
	end
	for i = 0,7 do
		msg = msg .. string.char(bit.band(bit.rshift(origlen, (i*8)), 0xFF))
	end

	for chunkStart = 1, #msg, 64 do
		local chunk = msg:sub(chunkStart, chunkStart+63)
		local w = {}
		for i = 1,16 do
			local j = (i-1)*4
			w[i] = (string.byte(chunk, j+1) * 2^24) + (string.byte(chunk, j+2) * 2^16) + (string.byte(chunk, j+3) * 2^8) + (string.byte(chunk, j+4))
		end
		for i = 17,80 do
			w[i] = leftrotate(bit.bxor(w[i-3], w[i-8], w[i-14], w[i-16]), 1)
		end

		local a, b, c, d, e = h0, h1, h2, h3, h4
		for i = 1,80 do
			local f, k
			if i <= 20 then
				f = bit.bor(bit.band(b, c), bit.band(bit.bnot(b), d))
				k = 0x5A827999
			elseif i <= 40 then
				f = bit.bxor(b, c, d)
				k = 0x6ED9EBA1
			elseif i <= 60 then
				f = bit.bor(bit.band(b, c), bit.band(b, d), bit.band(c, d))
				k = 0x8F1BBCDC
			else
				f = bit.bxor(b, c, d)
				k = 0xCA62C1D6
			end
			local temp = (leftrotate(a,5) + f + e + k + w[i]) % 2^32
			e = d
			d = c
			c = leftrotate(b, 30)
			b = a
			a = temp
		end

		h0 = (h0 + a) % 2^32
		h1 = (h1 + b) % 2^32
		h2 = (h2 + c) % 2^32
		h3 = (h3 + d) % 2^32
		h4 = (h4 + e) % 2^32
	end

	local function toBytesBE32(x)
		local t = {}
		for i = 3,0,-1 do
			t[#t+1] = string.char(bit.band(bit.rshift(x, i*8), 0xFF))
		end
		return table.concat(t)
	end

	local digest = table.concat{toBytesBE32(h0), toBytesBE32(h1), toBytesBE32(h2), toBytesBE32(h3), toBytesBE32(h4)}
	return toHex(digest)
end

-- =========================
-- SHA-2 family (sha256, sha512)
-- Note: sha384 is sha512 truncated to 384 bits
-- =========================

-- Helper: big 64-bit operations via two 32-bit halves (for SHA-512)
local function add64(a_hi, a_lo, b_hi, b_lo)
	local lo = (a_lo + b_lo) % 2^32
	local carry = (a_lo + b_lo - lo) / 2^32
	local hi = (a_hi + b_hi + carry) % 2^32
	return hi, lo
end

local function shr(x, n) return bit.rshift(x, n) end
local function rotr(x, n) return bit.rrotate(x, n) end

-- SHA-256 implementation
local function sha256(msg)
	local k = {
		0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
		0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
		0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
		0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
		0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
		0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
		0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
		0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
	}
	local function ch(x,y,z) return bit.bxor(bit.band(x,y), bit.band(bit.bnot(x), z)) end
	local function maj(x,y,z) return bit.bxor(bit.band(x,y), bit.band(x,z), bit.band(y,z)) end
	local function bigSigma0(x) return bit.bxor(bit.rrotate(x,2), bit.rrotate(x,13), bit.rrotate(x,22)) end
	local function bigSigma1(x) return bit.bxor(bit.rrotate(x,6), bit.rrotate(x,11), bit.rrotate(x,25)) end
	local function smallSigma0(x) return bit.bxor(bit.rrotate(x,7), bit.rrotate(x,18), bit.rshift(x,3)) end
	local function smallSigma1(x) return bit.bxor(bit.rrotate(x,17), bit.rrotate(x,19), bit.rshift(x,10)) end

	-- Preprocess
	local len = #msg
	local bitlen = len * 8
	msg = msg .. string.char(0x80)
	while (#msg % 64) ~= 56 do msg = msg .. string.char(0) end
	for i = 7,0,-1 do
		msg = msg .. string.char(bit.band(bit.rshift(bitlen, i*8), 0xFF))
	end

	local H = {0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19}

	for chunkStart = 1, #msg, 64 do
		local chunk = msg:sub(chunkStart, chunkStart+63)
		local w = {}
		for i = 1,16 do
			local j = (i-1)*4
			w[i] = (string.byte(chunk, j+1) * 2^24) + (string.byte(chunk, j+2) * 2^16) + (string.byte(chunk, j+3) * 2^8) + (string.byte(chunk, j+4))
		end
		for i = 17,64 do
			w[i] = (smallSigma1(w[i-2]) + w[i-7] + smallSigma0(w[i-15]) + w[i-16]) % 2^32
		end

		local a,b,c,d,e,f,g,h = table.unpack(H)
		for i = 1,64 do
			local T1 = (h + bigSigma1(e) + ch(e,f,g) + k[i] + w[i]) % 2^32
			local T2 = (bigSigma0(a) + maj(a,b,c)) % 2^32
			h = g
			g = f
			f = e
			e = (d + T1) % 2^32
			d = c
			c = b
			b = a
			a = (T1 + T2) % 2^32
		end

		H[1] = (H[1] + a) % 2^32
		H[2] = (H[2] + b) % 2^32
		H[3] = (H[3] + c) % 2^32
		H[4] = (H[4] + d) % 2^32
		H[5] = (H[5] + e) % 2^32
		H[6] = (H[6] + f) % 2^32
		H[7] = (H[7] + g) % 2^32
		H[8] = (H[8] + h) % 2^32
	end

	local out = {}
	for i = 1,8 do
		out[#out+1] = string.format("%08x", H[i])
	end
	return table.concat(out)
end

-- SHA-512 implementation (using 64-bit arithmetic via hi/lo halves)
local function sha512(msg)
	-- SHA-512 constants (first 80 words)
	local K = {
		0x428a2f98,0xd728ae22,0x71374491,0x23ef65cd,0xb5c0fbcf,0xec4d3b2f,0xe9b5dba5,0x8189dbbc,
		0x3956c25b,0xf348b538,0x59f111f1,0xb605d019,0x923f82a4,0xaf194f9b,0xab1c5ed5,0xda6d8118,
		0xd807aa98,0xa3030242,0x12835b01,0x45706fbe,0x243185be,0x4ee4b28c,0x550c7dc3,0xd5ffb4e2,
		0x72be5d74,0xf27b896f,0x80deb1fe,0x3b1696b1,0x9bdc06a7,0x25c71235,0xc19bf174,0xcf692694,
		0xe49b69c1,0x9ef14ad2,0xefbe4786,0x384f25e3,0x0fc19dc6,0x8b8cd5b5,0x240ca1cc,0x77ac9c65,
		0x2de92c6f,0x592b0275,0x4a7484aa,0x6ea6e483,0x5cb0a9dc,0xbd41fbd4,0x76f988da,0x831153b5,
		0x983e5152,0xee66dfab,0xa831c66d,0x2db43210,0xb00327c8,0x98fb213f,0xbf597fc7,0xbeef0ee4,
		0xc6e00bf3,0x3da88fc2,0xd5a79147,0x930aa725,0x06ca6351,0xe003826f,0x14292967,0x0a0e6e70,
		0x27b70a85,0x46d22ffc,0x2e1b2138,0x5c26c926,0x4d2c6dfc,0x5ac42aed,0x53380d13,0x9d95b3df,
		0x650a7354,0x8baf63de,0x766a0abb,0x3c77b2a8,0x81c2c92e,0x47edaee6,0x92722c85,0x1482353b,
		0xa2bfe8a1,0x4cf10364,0xa81a664b,0xbc423001,0xc24b8b70,0xd0f89791,0xc76c51a3,0x0654be30,
		0xd192e819,0xd6ef5218,0xd6990624,0x5565a910,0xf40e3585,0x5771202a,0x106aa070,0x32bbd1b8,
		0x19a4c116,0xb8d2d0c8,0x1e376c08,0x5141ab53,0x2748774c,0xdf8eeb99,0x34b0bcb5,0xe19b48a8,
		0x391c0cb3,0xc5c95a63,0x4ed8aa4a,0xe3418acb,0x5b9cca4f,0x7763e373,0x682e6ff3,0xd6b2b8a3,
		0x748f82ee,0x5defb2fc,0x78a5636f,0x43172f60,0x84c87814,0xa1f0ab72,0x8cc70208,0x1a6439ec,
		0x90befffa,0x23631e28,0xa4506ceb,0xde82bde9,0xbef9a3f7,0xb2c67915,0xc67178f2,0xe372532b,
		0xca273ece,0xea26619c,0xd186b8c7,0x21c0c207,0xeada7dd6,0xcde0eb1e,0xf57d4f7f,0xee6ed178,
		0x06f067aa,0x72176fba,0x0a637dc5,0xa2c898a6,0x113f9804,0xbef90dae,0x1b710b35,0x131c471b,
		0x28db77f5,0x23047d84,0x32caab7b,0x40c72493,0x3c9ebe0a,0x15c9bebc,0x431d67c4,0x9c100d4c,
		0x4cc5d4be,0xcb3e42b6,0x597f299c,0xfc657e2a,0x5fcb6fab,0x3ad6faec,0x6c44198c,0x4a475817
	}
	-- initial hash values (hi, lo pairs)
	local H = {
		0x6a09e667,0xf3bcc908, 0xbb67ae85,0x84caa73b, 0x3c6ef372,0xfe94f82b, 0xa54ff53a,0x5f1d36f1,
		0x510e527f,0xade682d1, 0x9b05688c,0x2b3e6c1f, 0x1f83d9ab,0xfb41bd6b, 0x5be0cd19,0x137e2179
	}

	-- helpers for 64-bit operations (hi,lo)
	local function xor64(a_hi,a_lo,b_hi,b_lo) return bit.bxor(a_hi,b_hi), bit.bxor(a_lo,b_lo) end
	local function and64(a_hi,a_lo,b_hi,b_lo) return bit.band(a_hi,b_hi), bit.band(a_lo,b_lo) end

	local function add64_4(a_hi,a_lo,b_hi,b_lo,c_hi,c_lo,d_hi,d_lo)
		local hi, lo = add64(a_hi,a_lo, b_hi,b_lo)
		hi, lo = add64(hi,lo, c_hi,c_lo)
		hi, lo = add64(hi,lo, d_hi,d_lo)
		return hi, lo
	end

	local function rightrotate64(hi, lo, n)
		-- rotate right across 64-bit value by n (0 < n < 64)
		n = n % 64
		if n == 0 then return hi, lo end
		if n < 32 then
			local new_lo = bit.rshift(lo, n) + bit.lshift(hi, 32 - n)
			local new_hi = bit.rshift(hi, n) + bit.lshift(lo, 32 - n)
			return new_hi % 2^32, new_lo % 2^32
		else
			local m = n - 32
			local new_lo = bit.rshift(hi, m) + bit.lshift(lo, 32 - m)
			local new_hi = bit.rshift(lo, m) + bit.lshift(hi, 32 - m)
			return new_hi % 2^32, new_lo % 2^32
		end
	end

	local function shr64(hi, lo, n)
		if n == 0 then return hi, lo end
		if n < 32 then
			local new_hi = bit.rshift(hi, n)
			local new_lo = bit.rshift(lo, n) + bit.lshift(hi, 32 - n)
			return new_hi, new_lo
		else
			local m = n - 32
			local new_hi = 0
			local new_lo = bit.rshift(hi, m)
			return new_hi, new_lo
		end
	end

	-- message preprocessing: append '1' bit then zeros, then 128-bit length (big-endian)
	local bitlen_hi = 0
	local bitlen_lo = (#msg * 8) % 2^32
	-- support messages up to 2^64-1 bits; here we ignore hi length beyond 32 bits for simplicity
	msg = msg .. string.char(0x80)
	while (#msg % 128) ~= 112 do msg = msg .. string.char(0) end
	-- append 128-bit length (we use 0..0 .. hi/lo); for our usage this is sufficient
	for i = 15,0,-1 do
		if i >= 8 then
			msg = msg .. string.char(0)
		else
			msg = msg .. string.char(bit.band(bit.rshift(bitlen_lo, (7-i)*8), 0xFF))
		end
	end

	local function bytes_to_64(chunk, idx)
		local j = (idx-1)*8
		local hi = 0
		local lo = 0
		for b = 1,4 do
			hi = hi * 256 + (string.byte(chunk, j + b) or 0)
		end
		for b = 5,8 do
			lo = lo * 256 + (string.byte(chunk, j + b) or 0)
		end
		return hi % 2^32, lo % 2^32
	end

	for chunkStart = 1, #msg, 128 do
		local chunk = msg:sub(chunkStart, chunkStart+127)
		local W_hi = {}
		local W_lo = {}
		for i = 1,16 do
			local hi, lo = bytes_to_64(chunk, i)
			W_hi[i] = hi
			W_lo[i] = lo
		end
		for t = 17,80 do
			-- s1 = (W[t-2] rotr 19) xor (W[t-2] rotr 61) xor (W[t-2] >> 6)
			local s1_hi, s1_lo = rightrotate64(W_hi[t-2], W_lo[t-2], 19)
			local s1b_hi, s1b_lo = rightrotate64(W_hi[t-2], W_lo[t-2], 61)
			local s1c_hi, s1c_lo = shr64(W_hi[t-2], W_lo[t-2], 6)
			local s1x_hi, s1x_lo = bit.bxor(bit.bxor(s1_hi, s1b_hi), s1c_hi), bit.bxor(bit.bxor(s1_lo, s1b_lo), s1c_lo)

			-- s0 = (W[t-15] rotr 1) xor (W[t-15] rotr 8) xor (W[t-15] >> 7)
			local s0_hi, s0_lo = rightrotate64(W_hi[t-15], W_lo[t-15], 1)
			local s0b_hi, s0b_lo = rightrotate64(W_hi[t-15], W_lo[t-15], 8)
			local s0c_hi, s0c_lo = shr64(W_hi[t-15], W_lo[t-15], 7)
			local s0x_hi, s0x_lo = bit.bxor(bit.bxor(s0_hi, s0b_hi), s0c_hi), bit.bxor(bit.bxor(s0_lo, s0b_lo), s0c_lo)

			-- W[t] = W[t-16] + s0 + W[t-7] + s1
			local hi, lo = add64_4(W_hi[t-16], W_lo[t-16], s0x_hi, s0x_lo, W_hi[t-7], W_lo[t-7], s1x_hi, s1x_lo)
			W_hi[t] = hi
			W_lo[t] = lo
		end

		-- initialize working variables a..h
		local a_hi,a_lo = H[1],H[2]
		local b_hi,b_lo = H[3],H[4]
		local c_hi,c_lo = H[5],H[6]
		local d_hi,d_lo = H[7],H[8]
		local e_hi,e_lo = H[9],H[10]
		local f_hi,f_lo = H[11],H[12]
		local g_hi,g_lo = H[13],H[14]
		local h_hi,h_lo = H[15],H[16]

		for t = 1,80 do
			-- S1 = (e rotr 14) xor (e rotr 18) xor (e rotr 41)
			local S1a_hi,S1a_lo = rightrotate64(e_hi,e_lo,14)
			local S1b_hi,S1b_lo = rightrotate64(e_hi,e_lo,18)
			local S1c_hi,S1c_lo = rightrotate64(e_hi,e_lo,41)
			local S1_hi = bit.bxor(bit.bxor(S1a_hi,S1b_hi), S1c_hi)
			local S1_lo = bit.bxor(bit.bxor(S1a_lo,S1b_lo), S1c_lo)

			-- ch = (e & f) xor ((~e) & g)
			local ch_hi1, ch_lo1 = bit.band(e_hi, f_hi), bit.band(e_lo, f_lo)
			local ne_hi, ne_lo = bit.bnot(e_hi), bit.bnot(e_lo)
			local ch_hi2, ch_lo2 = bit.band(ne_hi, g_hi), bit.band(ne_lo, g_lo)
			local ch_hi, ch_lo = bit.bxor(ch_hi1, ch_hi2), bit.bxor(ch_lo1, ch_lo2)

			-- temp1 = h + S1 + ch + K[t] + W[t]
			local Kt_hi, Kt_lo = K[(t-1)*2+1], K[(t-1)*2+2]
			local Wt_hi, Wt_lo = W_hi[t], W_lo[t]
			local temp1_hi, temp1_lo = add64_4(h_hi, h_lo, S1_hi, S1_lo, ch_hi, ch_lo, Kt_hi, Kt_lo)
			temp1_hi, temp1_lo = add64(temp1_hi, temp1_lo, Wt_hi, Wt_lo)

			-- S0 = (a rotr 28) xor (a rotr 34) xor (a rotr 39)
			local S0a_hi,S0a_lo = rightrotate64(a_hi,a_lo,28)
			local S0b_hi,S0b_lo = rightrotate64(a_hi,a_lo,34)
			local S0c_hi,S0c_lo = rightrotate64(a_hi,a_lo,39)
			local S0_hi = bit.bxor(bit.bxor(S0a_hi,S0b_hi), S0c_hi)
			local S0_lo = bit.bxor(bit.bxor(S0a_lo,S0b_lo), S0c_lo)

			-- maj = (a & b) xor (a & c) xor (b & c)
			local maj1_hi,maj1_lo = bit.band(a_hi,b_hi), bit.band(a_lo,b_lo)
			local maj2_hi,maj2_lo = bit.band(a_hi,c_hi), bit.band(a_lo,c_lo)
			local maj3_hi,maj3_lo = bit.band(b_hi,c_hi), bit.band(b_lo,c_lo)
			local maj_hi = bit.bxor(bit.bxor(maj1_hi, maj2_hi), maj3_hi)
			local maj_lo = bit.bxor(bit.bxor(maj1_lo, maj2_lo), maj3_lo)

			-- temp2 = S0 + maj
			local temp2_hi, temp2_lo = add64(S0_hi, S0_lo, maj_hi, maj_lo)

			-- h = g
			h_hi,h_lo = g_hi,g_lo
			g_hi,g_lo = f_hi,f_lo
			f_hi,f_lo = e_hi,e_lo
			-- e = d + temp1
			e_hi,e_lo = add64(d_hi,d_lo, temp1_hi, temp1_lo)
			d_hi,d_lo = c_hi,c_lo
			c_hi,c_lo = b_hi,b_lo
			b_hi,b_lo = a_hi,a_lo
			-- a = temp1 + temp2
			a_hi,a_lo = add64(temp1_hi, temp1_lo, temp2_hi, temp2_lo)
		end

		-- add chunk's hash to result so far
		H[1],H[2]   = add64(H[1],H[2],   a_hi,a_lo)
		H[3],H[4]   = add64(H[3],H[4],   b_hi,b_lo)
		H[5],H[6]   = add64(H[5],H[6],   c_hi,c_lo)
		H[7],H[8]   = add64(H[7],H[8],   d_hi,d_lo)
		H[9],H[10]  = add64(H[9],H[10],  e_hi,e_lo)
		H[11],H[12] = add64(H[11],H[12], f_hi,f_lo)
		H[13],H[14] = add64(H[13],H[14], g_hi,g_lo)
		H[15],H[16] = add64(H[15],H[16], h_hi,h_lo)
	end

	-- serialize H as hex
	local function hi_lo_to_hex(hi, lo)
		return string.format("%08x%08x", hi, lo)
	end
	local out = {}
	for i = 1,16,2 do
		out[#out+1] = hi_lo_to_hex(H[i], H[i+1])
	end
	return table.concat(out)
end





-- Rotation of a 64-bit value represented as lo,hi by n bits left
local function rol64(lo, hi, n)
	n = n % 64
	if n == 0 then return lo, hi end
	if n < 32 then
		local new_lo = bit.bor(bit.lshift(lo, n), bit.rshift(hi, 32 - n))
		local new_hi = bit.bor(bit.lshift(hi, n), bit.rshift(lo, 32 - n))
		return new_lo % 2^32, new_hi % 2^32
	else
		local m = n - 32
		local new_lo = bit.bor(bit.lshift(hi, m), bit.rshift(lo, 32 - m))
		local new_hi = bit.bor(bit.lshift(lo, m), bit.rshift(hi, 32 - m))
		return new_lo % 2^32, new_hi % 2^32
	end
end

-- 64-bit XOR
local function xor64(a_lo,a_hi,b_lo,b_hi)
	return bit.bxor(a_lo,b_lo), bit.bxor(a_hi,b_hi)
end

-- 64-bit AND
local function and64(a_lo,a_hi,b_lo,b_hi)
	return bit.band(a_lo,b_lo), bit.band(a_hi,b_hi)
end

-- 64-bit NOT
local function not64(a_lo,a_hi)
	return bit.bnot(a_lo), bit.bnot(a_hi)
end

-- 64-bit XOR of three
local function xor64_3(a_lo,a_hi,b_lo,b_hi,c_lo,c_hi)
	local lo = bit.bxor(a_lo, bit.bxor(b_lo, c_lo))
	local hi = bit.bxor(a_hi, bit.bxor(b_hi, c_hi))
	return lo, hi
end

-- 64-bit add (a + b) returning lo,hi (mod 2^32 overflow into hi)
local function add64(a_lo,a_hi,b_lo,b_hi)
	local lo = (a_lo + b_lo) % 2^32
	local carry = math.floor((a_lo + b_lo) / 2^32)
	local hi = (a_hi + b_hi + carry) % 2^32
	return lo, hi
end

-- add four 64-bit values
local function add64_4(a_lo,a_hi,b_lo,b_hi,c_lo,c_hi,d_lo,d_hi)
	local lo, hi = add64(a_lo,a_hi,b_lo,b_hi)
	lo, hi = add64(lo,hi,c_lo,c_hi)
	lo, hi = add64(lo,hi,d_lo,d_hi)
	return lo, hi
end

-- Round constants RC as 64-bit hi/lo pairs
local RC = {
	{0x00000001,0x00000000},{0x00008082,0x00000000},{0x0000808A,0x80000000},{0x80008000,0x80000000},
	{0x0000808B,0x00000000},{0x80000001,0x00000000},{0x80008081,0x80000000},{0x00008009,0x80000000},
	{0x0000008A,0x00000000},{0x00000088,0x00000000},{0x80008009,0x00000000},{0x8000000A,0x00000000},
	{0x8000808B,0x00000000},{0x0000008B,0x80000000},{0x00008089,0x80000000},{0x00008003,0x80000000},
	{0x00008002,0x80000000},{0x00000080,0x80000000},{0x0000800A,0x00000000},{0x8000000A,0x00000000},
	{0x80008081,0x00000000},{0x00008080,0x80000000},{0x00000001,0x00000000},{0x00000082,0x00000000}
}

-- Rotation offsets r[x][y]
local r = {
	{0, 36, 3, 41, 18},
	{1, 44, 10, 45, 2},
	{62, 6, 43, 15, 61},
	{28, 55, 25, 21, 56},
	{27, 20, 39, 8, 14}
}

-- Keccak-f[1600] permutation on state A (25 lanes of 64-bit hi/lo)
local function keccakf(A)
	-- A is array of 25 elements {lo, hi}
	for round = 1,24 do
		-- Theta
		local C = {}
		for x = 0,4 do
			local idx = x+1
			local lo,hi = 0,0
			for y = 0,4 do
				local pos = x + 5*y + 1
				lo = bit.bxor(lo, A[pos][1])
				hi = bit.bxor(hi, A[pos][2])
			end
			C[idx] = {lo,hi}
		end
		local D = {}
		for x = 0,4 do
			local cx1,cx1h = C[((x-1) % 5)+1][1], C[((x-1) % 5)+1][2]
			local cx2,cx2h = C[((x+1) % 5)+1][1], C[((x+1) % 5)+1][2]
			local rot_lo, rot_hi = rol64(cx2, cx2h, 1)
			D[x+1] = { bit.bxor(cx1, rot_lo), bit.bxor(cx1h, rot_hi) }
		end
		for x = 0,4 do
			for y = 0,4 do
				local pos = x + 5*y + 1
				A[pos][1] = bit.bxor(A[pos][1], D[x+1][1])
				A[pos][2] = bit.bxor(A[pos][2], D[x+1][2])
			end
		end

		-- Rho and Pi
		local B = {}
		for x = 0,4 do
			for y = 0,4 do
				local pos = x + 5*y + 1
				local shift = r[x+1][y+1]
				local new_lo, new_hi = rol64(A[pos][1], A[pos][2], shift)
				local nx = y
				local ny = (2*x + 3*y) % 5
				local npos = nx + 5*ny + 1
				B[npos] = {new_lo % 2^32, new_hi % 2^32}
			end
		end

		-- Chi
		for x = 0,4 do
			for y = 0,4 do
				local pos = x + 5*y + 1
				local a = B[pos]
				local b = B[((x+1) % 5) + 5*y + 1]
				local c = B[((x+2) % 5) + 5*y + 1]
				-- A[pos] = B[pos] xor ((not B[x+1]) and B[x+2])
				local nb_lo, nb_hi = not64(b[1], b[2])
				local and_lo, and_hi = and64(nb_lo, nb_hi, c[1], c[2])
				A[pos][1] = bit.bxor(a[1], and_lo)
				A[pos][2] = bit.bxor(a[2], and_hi)
			end
		end

		-- Iota
		local rc = RC[round]
		A[1][1] = bit.bxor(A[1][1], rc[1])
		A[1][2] = bit.bxor(A[1][2], rc[2])
	end
end

-- Initialize empty state
local function stateInit()
	local A = {}
	for i = 1,25 do
		A[i] = {0,0}
	end
	return A
end

-- Absorb input message into state with rate 'r' bits
local function keccak_absorb(msg, rate, suffix)
	suffix = suffix or 0x06 -- SHA3 padding domain by default
	local rateBytes = rate // 8
	local A = stateInit()
	local msgLen = #msg
	local i = 1
	while i <= msgLen do
		local block = msg:sub(i, i + rateBytes - 1)
		-- XOR block into state lanes
		for j = 1, #block do
			local byte = string.byte(block, j)
			local idx = math.floor((j-1) / 8)
			local lanePos = idx + 1 -- lane index within block
			local laneByteIndex = ((j-1) % 8)
			-- place into corresponding lane in A: compute absolute lane
			local absLane = lanePos
			-- convert existing lane to bytes and XOR
			-- we'll XOR into lane little-endian: byte 0 is LSB of lo
			local lo, hi = A[absLane][1], A[absLane][2]
			if laneByteIndex < 4 then
				local shift = laneByteIndex * 8
				lo = bit.bxor(lo, bit.lshift(byte, shift))
			else
				local shift = (laneByteIndex - 4) * 8
				hi = bit.bxor(hi, bit.lshift(byte, shift))
			end
			A[absLane][1], A[absLane][2] = lo % 2^32, hi % 2^32
		end
		keccakf(A)
		i = i + rateBytes
	end

	-- padding: create final block
	local rem = msgLen % rateBytes
	local finalBlock = msg:sub(msgLen - rem + 1)
	local pad = {}
	for j = 1, rateBytes do
		local b = 0
		local pos = msgLen - rem + j
		if pos <= msgLen then b = string.byte(msg, pos) end
		if j == rem + 1 then b = bit.bor(b, suffix) end
		if j == rateBytes then b = bit.bor(b, 0x80) end
		pad[j] = b
	end
	for j = 1, rateBytes do
		local byte = pad[j]
		local idx = math.floor((j-1) / 8)
		local lanePos = idx + 1
		local laneByteIndex = ((j-1) % 8)
		local lo, hi = A[lanePos][1], A[lanePos][2]
		if laneByteIndex < 4 then
			lo = bit.bxor(lo, bit.lshift(byte, laneByteIndex * 8))
		else
			hi = bit.bxor(hi, bit.lshift(byte, (laneByteIndex-4) * 8))
		end
		A[lanePos][1], A[lanePos][2] = lo % 2^32, hi % 2^32
	end
	keccakf(A)
	return A
end

-- Squeeze 'digestBytes' bytes from state with rate 'r' bits
local function keccak_squeeze(A, rate, digestBytes)
	local rateBytes = rate // 8
	local out = {}
	local outLen = 0
	while outLen < digestBytes do
		-- extract block
		for lane = 1, rateBytes do
			local idx = math.floor((lane-1) / 8) + 1
			local laneByteIndex = (lane-1) % 8
			local lo, hi = A[idx][1], A[idx][2]
			local byte
			if laneByteIndex < 4 then
				byte = bit.band(bit.rshift(lo, laneByteIndex * 8), 0xFF)
			else
				byte = bit.band(bit.rshift(hi, (laneByteIndex-4) * 8), 0xFF)
			end
			outLen = outLen + 1
			out[outLen] = string.char(byte)
			if outLen >= digestBytes then break end
		end
		if outLen >= digestBytes then break end
		keccakf(A)
	end
	return table.concat(out)
end

-- =========================
-- Public API: Hash.hash(str, mode)
-- mode: one of the provided strings (case-insensitive)
-- =========================
crypt.custom.hash = function(str, mode)
	assert(type(str) == "string", "first arg must be a string")
	assert(type(mode) == "string", "mode must be a string")

	mode = mode:lower()
	if mode == "md5" then
		return md5(str)
	elseif mode == "sha1" then
		return sha1(str)
	elseif mode == "sha256" then
		return sha256(str)
	elseif mode == "sha512" then
		return sha512(str)
	elseif mode == "sha384" then
		-- sha384 is first 384 bits (48 bytes) of sha512 digest
		local full = sha512(str)
		return full:sub(1, 96) -- 96 hex chars = 384 bits
	elseif mode == 'sha3-224' then
		local rate = 1152
		local A = keccak_absorb(str, rate, 0x06)
		local out = keccak_squeeze(A, rate, 224/8)
		return (out:gsub('.', function(c) return string.format('%02x', string.byte(c)) end))
	elseif mode == 'sha3-256' then
		local rate = 1088
		local A = keccak_absorb(str, rate, 0x06)
		local out = keccak_squeeze(A, rate, 256/8)
		return (out:gsub('.', function(c) return string.format('%02x', string.byte(c)) end))
	elseif mode == 'sha3-384' then
		local rate = 832
		local A = keccak_absorb(str, rate, 0x06)
		local out = keccak_squeeze(A, rate, 384/8)
		return (out:gsub('.', function(c) return string.format('%02x', string.byte(c)) end))
	elseif mode == 'sha3-512' then
		local rate = 576
		local A = keccak_absorb(str, rate, 0x06)
		local out = keccak_squeeze(A, rate, 512/8)
		return (out:gsub('.', function(c) return string.format('%02x', string.byte(c)) end))
	else
		-- error("Unsupported hash mode: " .. mode)
		return
	end
end

crypt.derive = function(value, len)
	assert(type(value) == "string", "value must be a string")
	assert(type(len) == "number" and len > 0, "len must be a positive number")

	local output = {}
	local counter = 0
	while #output < len do
		counter = counter + 1
		-- hash value + counter
		local hash = crypt.custom.hash(value .. string.char(counter % 256), "sha3-256")
		-- convert hex hash to bytes
		for i = 1, #hash, 2 do
			if #output >= len then break end
			local byte = tonumber(hash:sub(i,i+1), 16)
			table.insert(output, string.char(byte))
		end
	end
	return table.concat(output)
end

crypt.random = function(size)
	assert(type(size) == "number", "size must be a number")
	assert(size >= 0 and size <= 1024, "size must be between 0 and 1024")

	local rand = Random.new()
	local out = {}

	for i = 1, size do
		-- Generate a random byte (0-255)
		table.insert(out, string.char(rand:NextInteger(0, 255)))
	end

	return table.concat(out)
end

crypt.hash = function(data)
	assert(type(data) == "string", "data must be a string")

	local hash = 2166136261 -- FNV offset basis (FNV-1a style)
	for i = 1, #data do
		hash = bit32.bxor(hash, string.byte(data, i))
		hash = (hash * 16777619) % 2^32 -- FNV prime, 32-bit wraparound
	end

	-- Convert to a readable hex string
	local hex = {}
	for i = 0, 3 do
		table.insert(hex, string.format("%02x", bit32.extract(hash, i * 8, 8)))
	end
	return table.concat(hex)
end

return crypt
