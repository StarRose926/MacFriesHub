local XmlParser = {}

local function unescape(str)
	return string.gsub(str, "(&%a+;)", function(entity)
		return XML_ENTITIES[entity] or entity
	end)
end

-- Escapes special characters back into XML entities
local function escape(str)
	return string.gsub(str, "([<>&\"'])", function(char)
		return XML_ESCAPES[char] or char
	end)
end

local function parseAttributes(attrString)
	local attributes = {}
	for key, value in string.gmatch(attrString, '([%w_:-]+)%s*=%s*"([^"]*)"') do
		attributes[key] = unescape(value)
	end
	return attributes
end

-- Main function to parse XML string into a Luau table tree
function XmlParser.parse(xmlString)
	xmlString = string.gsub(xmlString, "<!%-%-.-%-%->", "")

	local stack = {}
	local root: XmlNode? = nil
	local current: XmlNode? = nil

	local pattern = "<(/?)([%w_:-]+)(.-)(/?)>"
	local lastPos = 1

	for isClosing, tagName, attrString, isSelfClosing in string.gmatch(xmlString, pattern) do
		local escapedTagName = string.gsub(tagName, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
		local startPos, endPos = string.find(xmlString, "<" .. isClosing .. escapedTagName .. ".-" .. isSelfClosing .. ">", lastPos)

		if not startPos then continue end

		if current and startPos > lastPos then
			local content = string.sub(xmlString, lastPos, startPos - 1)
			content = string.match(content, "^%s*(.-)%s*$")
			if content and content ~= "" then
				local cleanContent = unescape(content)
				current.content = (current.content or "") .. cleanContent
			end
		end

		if isClosing == "/" then
			table.remove(stack)
			current = stack[#stack]
		else
			local node: XmlNode = {
				name = tagName,
				attributes = parseAttributes(attrString),
				children = {},
				content = nil
			}

			if not root then
				root = node
			else
				table.insert(current.children, node)
			end

			if isSelfClosing ~= "/" then
				table.insert(stack, node)
				current = node
			end
		end

		lastPos = endPos + 1
	end

	return root
end

-- NEW FEATURE: Converts a Luau XmlNode tree back into an XML string
function XmlParser.stringify(node, indentCharacter, currentDepth)
	currentDepth = currentDepth or 0
	local indentStr = indentCharacter or ""
	local currentIndent = string.rep(indentStr, currentDepth)
	local nextIndent = string.rep(indentStr, currentDepth + 1)
	local newline = indentCharacter and "\n" or ""

	-- 1. Build the attributes string
	local attrParts = {}
	for key, value in pairs(node.attributes) do
		table.insert(attrParts, string.format('%s="%s"', key, escape(value)))
	end
	-- Sort attributes so they always appear in a predictable order
	table.sort(attrParts)
	local attrStr = #attrParts > 0 and (" " .. table.concat(attrParts, " ")) or ""

	-- 2. Check if the node is empty (self-closing tag option)
	local hasChildren = #node.children > 0
	local hasContent = node.content and node.content ~= ""

	if not hasChildren and not hasContent then
		return string.format("%s<%s%s />", currentIndent, node.name, attrStr)
	end

	-- 3. Open the tag
	local xml = string.format("%s<%s%s>", currentIndent, node.name, attrStr)

	-- 4. Process nested content or children
	if hasContent then
		xml = xml .. escape(node.content or "")
	elseif hasChildren then
		xml = xml .. newline
		for _, child in ipairs(node.children) do
			xml = xml .. XmlParser.stringify(child, indentCharacter, currentDepth + 1) .. newline
		end
		xml = xml .. currentIndent
	end

	-- 5. Close the tag
	xml = xml .. string.format("</%s>", node.name)
	return xml
end

return XmlParser
