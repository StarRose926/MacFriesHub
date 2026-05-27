-- To ensure Executors that are SO TRASH, they dont even include a Drawing Library :skull:
--
-- By: StarRose

local Library = {}

local Cache = {
	Line = {},
	Circle = {},
	Text = {},
	Square = {},
	Quad = {},
	Image = {},
	Triangle = {},
	Clear = function(self)
		table.clear(self.Line)
		table.clear(self.Circle)
		table.clear(self.Text)
		table.clear(self.Square)
		table.clear(self.Quad)
		table.clear(self.Image)
		table.clear(self.Triangle)
	end,
}

local drawings = {
	properties = {
		Line = {
			"Thickness",
			"From",
			"To"
		},
		Text = {
			"Text",
			"Size",
			"Center",
			"Outline",
			"OutlineColor",
			"Position",
			"TextBounds",
			"Font"
		},
		Image = {
			"Data",
			"Size",
			"Position",
			"Rounding"
		},
		Circle = {
			"Thickness",
			"NumSides",
			"Radius",
			"Filled",
			"Position"
		},
		Square = {
			"Thickness",
			"Size",
			"Position",
			"Filled"
		},
		Quad = {
			"Thickness",
			"PointA",
			"PointB",
			"PointC",
			"PointD"
		},
		Triangle = {
			"Thickness",
			"PointA",
			"PointB",
			"PointC"
		},
		Base = {
			"Visible",
			"ZIndex",
			"Transparency",
			"Color"
		}
	},
	default = {
		Line = {
			Thickness = 1,
			From = Vector2.zero,
			To = Vector2.zero
		},
		Text = {
			Text = '',
			Size = 12,
			Center = false,
			Outline = false,
			OutlineColor = Color3.new(1, 1, 1),
			Position = Vector2.zero,
			Font = 1
		},
		Image = {
			Data = '',
			Size = 50,
			Position = Vector2.zero,
			Rounding = 0
		},
		Circle = {
			Thickness = 1,
			NumSides = 0,
			Radius = math.huge,
			Filled = false,
			Position = Vector2.zero
		},
		Square = {
			Thickness = 1,
			Size = Vector2.zero,
			Position = Vector2.zero,
			Filled = false
		},
		Quad = {
			Thickness = 1,
			PointA = 0,
			PointB = 0,
			PointC = 0,
			PointD = 0
		},
		Triangle = {
			Thickness = 1,
			PointA = Vector2.zero,
			PointB = Vector2.zero,
			PointC = Vector2.zero
		},
		Base = {
			Visible = true,
			ZIndex = 1,
			Transparency = 0,
			Color = Color3.new(1, 1, 1)
		}
	}
}


local drawing_auth_key = {}
local drawing_auth_return_token = {}

local functions = {}
functions.getRotation = function(from, to)
	local direction = to - from
	return math.deg(math.atan2(direction.Y, direction.X))
end

functions.getDistance = function(from, to)
	return (to - from).Magnitude
end

functions.merge = function(a1, a2)
	local a3 = table.clone(a1)

	for v1, v2 in a2 do
		a3[a1] = a2
	end

	return a3
end


local DrawingScreen


Library.injectGui = function(gui)
	DrawingScreen = Instance.new('ScreenGui', gui)
	DrawingScreen.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	DrawingScreen.ScreenInsets = Enum.ScreenInsets.None
	DrawingScreen.DisplayOrder = 999999999
end


Library.new = function(type)
	local object
	local save = {}
	local saves = {}

	if not Cache[type] or typeof(Cache[type]) ~= 'table' then
		error(`{type} is not a valid Drawing type!`, 0)
	end

	if type == 'Text' then
		object = Instance.new('TextLabel', DrawingScreen)
		object.Size = UDim2.fromScale(0, 0)
		object.AutomaticSize = Enum.AutomaticSize.XY
		object.Text = ''
		object.Name = 'Text'
		object.BackgroundTransparency = 1
		object.TextColor3 = Color3.new(1, 1, 1)
		object.BorderSizePixel = 0

		local stroke = Instance.new('UIStroke', object)
		stroke.Enabled = false
		stroke.Name = 'Outline'
	elseif type == 'Line' then
		object = Instance.new('Frame', DrawingScreen)
		object.Name = 'Line'
		object.AnchorPoint = Vector2.new(0.5, 0.5)
		object.BackgroundColor3 = Color3.new(1, 1, 1)
		object.BorderSizePixel = 0
		object.Size = UDim2.fromScale(0, 0)
	elseif type == 'Circle' then
		object = Instance.new('Frame', DrawingScreen)
		object.Name = 'Circle'
		object.AnchorPoint = Vector2.new(0.5, 0.5)
		object.BackgroundColor3 = Color3.new(1, 1, 1)
		object.BackgroundTransparency = 1
		object.BorderSizePixel = 0
		-- object.BorderColor3 = Color3.new(1, 1, 1)

		local corner = Instance.new('UICorner', object)
		corner.CornerRadius = UDim.new(1, 0)
		corner.Name = 'Corner'

		local aspect = Instance.new('UIAspectRatioConstraint', object)
		aspect.Name = 'Aspect'
		aspect.AspectType = Enum.AspectType.ScaleWithParentSize

		local stroke = Instance.new('UIStroke', object)
		stroke.Color = Color3.new(1, 1, 1)
		stroke.Thickness = 1
		stroke.Name = 'Stroke'
	elseif type == 'Square' then
		object = Instance.new('Frame', DrawingScreen)
		object.Name = 'Square'
		object.AnchorPoint = Vector2.new(0.5, 0.5)
		object.Size = UDim2.fromOffset(0, 0)
		object.BackgroundColor3 = Color3.new(1, 1, 1)
		object.BorderSizePixel = 0
		object.BackgroundTransparency = 1

		local stroke = Instance.new('UIStroke', object)
		stroke.Enabled = true
		stroke.Thickness = 1
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Color = Color3.new(1, 1, 1)
	end

	local drawingObject = newproxy(true)
	local mt = getmetatable(drawingObject)

	local function updateLineFromTo()
		if save.From and save.To then
			object.Size = UDim2.fromOffset(functions.getDistance(save.From, save.To), save.Thickness or 2)
			object.Rotation = functions.getRotation(save.From, save.To)
			object.Position = UDim2.fromOffset((save.From.X + save.To.X) / 2, (save.From.Y + save.To.Y) / 2)
		end
	end

	local function updateCircleNumsides()
		if save.Visible == false then
			for i, line in pairs(saves) do
				if line then
					line:Remove()
				end
				saves[i] = nil
			end
		end

		if (save.NumSides and save.NumSides > 2) and (save.Position and save.Visible == true) then
			object:FindFirstChildOfClass('UIStroke').Thickness = 0
			object.BackgroundTransparency = 1
			local points = {}
			local step = (2 * math.pi) / save.NumSides
			for i = 0, save.NumSides - 1 do
				local angle = i * step
				local x = save.Position.X + math.cos(angle) * (save.Radius or 20)
				local y = save.Position.Y + math.sin(angle) * (save.Radius or 20)

				points[i + 1] = Vector2.new(x, y)
			end

			if #saves == 0 then
				local lines = {}
				for i = 1, save.NumSides do
					local a = points[i]
					local b = points[(i % save.NumSides) + 1]
					local line = Library.new('Line')

					line.From = a
					line.To = b
					line.Color = save.Color or Color3.new(1, 1, 1)
					line.Visible = true

					table.insert(lines, line)
				end

				saves = lines
			else
				for i, line in pairs(saves) do
					local a = points[i]
					local b = points[(i % save.NumSides) + 1]

					line.From = a
					line.To = b
					line.Color = save.Color or Color3.new(1, 1, 1)
					line.Visible = true
				end
			end
		else
			object.BackgroundTransparency = save.Filled and 0 or 1
			object:FindFirstChildOfClass('UIStroke').Thickness = save.Thickness or 1
		end
	end

	local debounce_remove = false
	save.Remove = function(_)
		table.clear(save)
		if object then
			object:Destroy()
		end

		if #saves ~= 0 and not debounce_remove then
			debounce_remove = true

			for i, object in pairs(saves) do
				object:Remove()
				saves[i] = nil
			end

			debounce_remove = false
		end
	end
	save.Destroy = save.Remove

	mt.__newindex = function(self, key, value)
		save[key] = value

		if type == 'Line' then
			if (key == 'From' and save.To ~= nil) or (key == 'To' and save.From ~= nil) then
				updateLineFromTo()
			end

			if key == 'Transparency' then
				object.BackgroundTransparency = (-value + 1)
			elseif key == 'Thickness' then
				updateLineFromTo()
			end
		elseif type == 'Text' then
			if key == 'Center' then
				object.AnchorPoint = value and Vector2.new(0.5, 0.5) or Vector2.zero
			elseif key == 'Position' then
				object.Position = UDim2.fromOffset(value.X, value.Y)
			elseif key == 'Size' then
				object.TextSize = value
			elseif key == 'Outline' then
				local outline = object:FindFirstChildOfClass('UIStroke')
				if outline then
					outline.Enabled = value
				end
			elseif key == 'OutlineColor' then
				local outline = object:FindFirstChildOfClass('UIStroke')
				if outline then
					outline.Color = value
				end
			elseif key == 'OutlineTransparency' then
				local outline = object:FindFirstChildOfClass('UIStroke')
				if outline then
					outline.Transparency = (-value + 1)
				end
			elseif key == 'Text' then
				object.Text = value
			elseif key == 'ZIndex' then
				object.ZIndex = value
			elseif key == 'Font' then
				if value == 0 then
					object.Font = Enum.Font.SourceSans
				elseif value == 1 then
					object.Font = Enum.Font.Legacy
				elseif value == 2 then
					object.Font = Enum.Font.Gotham
				elseif value == 3 then
					object.Font = Enum.Font.Code
				end
			end
		elseif type == 'Circle' then
			if key == 'Thickness' then
				if not ((save.NumSides and save.NumSides > 2) and save.Position) then
					object:FindFirstChildOfClass('UIStroke').Thickness = value
				end
			elseif key == 'Radius' then
				save[key] = value
				object.Size = UDim2.fromOffset(value, 0)
			elseif key == 'Filled' then
				if not ((save.NumSides and save.NumSides > 2) and save.Position) then
					object.BackgroundTransparency = value and 0 or 1
					object:FindFirstChildOfClass('UIStroke').Enabled = not value
				end
			elseif key == 'Position' then
				object.Position = UDim2.fromOffset(value.X, value.Y)
				updateCircleNumsides()
			elseif key == 'NumSides' or key == 'Visible' then
				task.spawn(updateCircleNumsides)
			elseif key == 'Transparency' then
				object:FindFirstChildOfClass('UIStroke').Transparency = (-value + 1)
			elseif key == 'ZIndex' then
				object.ZIndex = value
			elseif key == 'Color' then
				object:FindFirstChildOfClass('UIStroke').Color = value
			end
		elseif type == 'Square' then
			if key == 'Thickness' then
				local stroke = object:FindFirstChildOfClass('UIStroke')
				if stroke then
					stroke.Thickness = value
				end
			elseif key == 'Size' then
				object.Size = UDim2.fromOffset(value.X, value.Y)
			elseif key == 'Position' then
				object.Position = UDim2.fromOffset(value.X, value.Y)
			elseif key == 'Filled' then
				local stroke = object:FindFirstChildOfClass('UIStroke')
				object.BackgroundTransparency = value and 0 or 1

				if stroke then
					stroke.Enabled = not value
				end
			elseif key == 'Color' then
				local stroke = object:FindFirstChildOfClass('UIStroke')
				if stroke then
					stroke.Color = value
				end
			elseif key == 'Transparency' then
				object:FindFirstChildOfClass('UIStroke').Transparency = (-value + 1)
			elseif key == 'ZIndex' then
				object.ZIndex = value
			end
		elseif type == 'Quad' then
			if key == 'PointA' or key == 'PointB' or key == 'PointC' or key == 'PointD' then
				if (save.PointA and save.PointB and save.PointC and save.PointD) then
					if #saves == 0 then
						local function makeLine(a, b)
							local line = Library.new('Line')
							line.From = a
							line.To = b
							line.Color = save.Color or Color3.new(1, 1, 1)
							line.Thickness = save.Thickness or 1
							line.Visible = save.Visible or false
							line.ZIndex = save.ZIndex or 1
							table.insert(saves, line)
						end

						makeLine(save.PointA, save.PointB)
						makeLine(save.PointB, save.PointC)
						makeLine(save.PointC, save.PointD)
						makeLine(save.PointD, save.PointA)
					else
						for int, line in pairs(saves) do
							if int == 1 then
								line.From = save.PointA
								line.To = save.PointB
							elseif int == 2 then
								line.From = save.PointB
								line.To = save.PointC
							elseif int == 3 then
								line.From = save.PointC
								line.To = save.PointD
							elseif int == 4 then
								line.From = save.PointD
								line.To = save.PointA
							end
						end
					end
				end
			elseif key == 'Color' then
				for _, line in pairs(saves) do
					line.Color = value
				end
			elseif key == 'Visible' then
				for _, v in pairs(saves) do
					v.Visible = value
				end
			elseif key == 'Transparency' then
				for _, v in pairs(saves) do
					v.Transparency = value
				end
			elseif key == 'ZIndex' then
				for _, v in pairs(saves) do
					v.ZIndex = value
				end
			elseif key == 'Thickness' then
				for _, v in pairs(saves) do
					v.Thickness = value
				end
			end
		elseif type == 'Triangle' then
			if key == 'PointA' or key == 'PointB' or key == 'PointC' then
				if save.PointA and save.PointB and save.PointC then
					if #saves == 0 then
						local function makeline(a, b)
							local line = Library.new('Line')
							line.From = a
							line.To = b
							line.Color = save.Color or Color3.new(1, 1, 1)
							line.Thickness = save.Thickness or 1
							line.Visible = save.Visible or true
							line.ZIndex = save.ZIndex or 1
							table.insert(saves, line)
						end
						
						makeline(save.PointA, save.PointB)
						makeline(save.PointB, save.PointC)
						makeline(save.PointC, save.PointA)
					else
						for int, line in pairs(saves) do
							if int == 1 then
								line.From = save.PointA
								line.To = save.PointB
							elseif int == 2 then
								line.From = save.PointB
								line.To = save.PointC
							elseif int == 3 then
								line.From = save.PointC
								line.To = save.PointA
							end
						end
					end
				end
			elseif key == 'Color' then
				for _, line in pairs(saves) do
					line.Color = value
				end
			elseif key == 'Visible' then
				for _, v in pairs(saves) do
					v.Visible = value
				end
			elseif key == 'Transparency' then
				for _, v in pairs(saves) do
					v.Transparency = value
				end
			elseif key == 'ZIndex' then
				for _, v in pairs(saves) do
					v.ZIndex = value
				end
			elseif key == 'Thickness' then
				for _, v in pairs(saves) do
					v.Thickness = value
				end
			end
		end

		if object then
			if key == 'Visible' then
				object.Visible = value
			elseif key == 'Color' then
				if object:IsA('TextLabel') then
					object.TextColor3 = value
				else
					object.BackgroundColor3 = value
					object.BorderColor3 = value
				end
			end
		end
	end

	mt.__index = function(self, key, value)
		if key == 'TextBounds' and (object and object:IsA('TextLabel')) then
			return object.TextBounds
		end

		if type == 'Text' and key == 'Font' then
			if object.Font == Enum.Font.SourceSans then
				return 0
			elseif object.Font == Enum.Font.Legacy then
				return 1
			elseif object.Font == Enum.Font.Gotham then
				return 2
			elseif object.Font == Enum.Font.Code then
				return 3
			end
		end

		if key == 'Type' then
			return type
		end

		if key == drawing_auth_key then
			return drawing_auth_return_token
		end

		return save[key]
	end

	table.insert(Cache[type], drawingObject)


	for a, b in pairs(drawings.default.Base) do
		drawingObject[a] = b
	end

	if drawings.properties[type] then
		for a, b in pairs(drawings.properties[type]) do
			drawingObject[a] = b
		end
	end


	return drawingObject
end


Library.Fonts = {
	UI = 0,
	System = 1,
	Plex = 2,
	Monospace = 3
}


Library.isrenderproperty = function(obj)
	if type(obj) ~= 'userdata' then
		return false
	end

	local random = math.random(1, 2)

	local ok, suc = pcall(function()
		for i = 1, 2 do
			if random == 1 then
				if obj[drawing_auth_key] ~= drawing_auth_return_token then
					drawing_auth_key = {}
					drawing_auth_return_token = {}

					return false
				end

				random = 2
			end

			if random == 2 then
				if obj[drawing_auth_key] == {} then
					drawing_auth_key = {}
					drawing_auth_return_token = {}

					return false
				end

				random = 1
			end
		end

		return true
	end)

	if not ok then
		return false
	end

	return suc
end
Library.is_render_property = Library.isrenderproperty
Library.isrenderobj = Library.isrenderproperty


Library.setrenderproperty = function(obj, property, value)
	if not Library.isrenderobj(obj) then return end
	local props = drawings.properties[obj.Type]
	if not props then
		return
	end

	if table.find(drawings.properties.Base, property) then
		obj[property] = value
		return
	end

	if not table.find(props, property) then
		return
	end

	props[property] = value
end
Library.set_render_property = Library.setrenderproperty
Library.setrenderobj = Library.setrenderproperty


Library.getrenderproperty = function(obj, property)
	if not Library.isrenderobj(obj) then return end
	local props = drawings.properties[obj.Type]
	if not props then
		return
	end

	if table.find(drawings.properties.Base, property) then
		return obj[property]
	end

	if not table.find(props, property) then
		return
	end

	return obj[property]
end
Library.get_render_property = Library.getrenderproperty
Library.getrenderobj = Library.getrenderproperty


Library.cleardrawcache = function(type)
	for a, caches in pairs(Cache) do
		if typeof(caches) == 'table' then
			if not (type and a ~= type) then
				for i, drawing in pairs(caches) do
					if Library.isrenderobj(drawing) then
						pcall(drawing.Remove, drawing)
					end

					caches[i] = nil
				end
			end
		end
	end

	Cache:Clear()
end


Library.getDrawings = function(type)
	local cache = {}

	for a, caches in pairs(Cache) do
		if typeof(caches) == 'table' then
			if not (type and a ~= type) then
				for _, drawing in pairs(caches) do
					table.insert(cache, drawing)
				end
			end
		end
	end

	return cache
end


return Library
