-- DeviceService Fourms: https://devforum.roblox.com/t/os-and-device-detection-module/3841990
--
-- Fallback for: UserInputService:GetPlatform

local getArchitecture = loadstring(game:HttpGet('https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/libraries/external/determineBitArchitecture.lua'))()

local DeviceService = {}
DeviceService.__index = DeviceService

local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local VRService = game:GetService("VRService")
local TextService = game:GetService("TextService")
local Enumate do
	Enumate = {}

	Enumate.DeviceType = {
		Phone = 0x01,
		Tablet = 0x02,
		SmallPhone = 0x04,
		Console = 0x08,
		Computer = 0x10,
		Unknown = 0xFFFF,
		Potato = 0x40,
		Name = {
			[0x01] = "Phone",
			[0x02] = "Tablet",
			[0x04] = "SmallPhone",
			[0x08] = "Console",
			[0x10] = "Computer",
			[0x40] = "Potato",
			[0xFFFF] = "Unknown",
		}
	}

	Enumate.Platform = {
		UWP = 0x1a,
		XboxOne = 0x1b,
		Linux = 0x1c,
		Windows = 0x1d,
		OSX = 0x1e,
		PS4 = 0x1f,
		PS5 = 0x2a,
		Android = 0x2b,
		IOS = 0x2c,
		VR = 0x2d,
		MetaOS = 0x2e,
		Unknown = 0xFFFF,
		Name = {
			[0x1a] = "UWP",
			[0x1b] = "XboxOne",
			[0x1c] = "Linux",
			[0x1d] = "Windows",
			[0x1e] = "OSX",
			[0x1f] = "PS4",
			[0x2a] = "PS5",
			[0x2b] = "Android",
			[0x2c] = "IOS",
			[0x2d] = "VR",
			[0x2e] = "MetaOS",
			[0xFFFF] = "Unknown"
		}
	}


	--ts how you define groups gurt
	Enumate.DeviceGroup = {
		Mobile = bit32.bor(Enumate.DeviceType.Phone, Enumate.DeviceType.Tablet, Enumate.DeviceType.SmallPhone),
		Desktop = bit32.bor(Enumate.DeviceType.Computer, Enumate.DeviceType.Console),
	}

	Enumate.PlatformGroup = {
		Mobile = bit32.bor(Enumate.Platform.IOS,Enumate.Platform.Android),
		Desktop = bit32.bor(Enumate.Platform.Windows,Enumate.Platform.Linux,Enumate.Platform.OSX,Enumate.Platform.UWP),
		Console = bit32.bor(Enumate.Platform.PS4,Enumate.Platform.PS5,Enumate.Platform.XboxOne),
	}
end

local sub = string.sub
local match = string.match
local len = string.len
local lower = string.lower

-- Create Signals
local function createSignal()
	local bindable = Instance.new("BindableEvent")
	local signal = {}

	function signal:Connect(fn)
		return bindable.Event:Connect(fn)
	end

	function signal:Fire(...)
		bindable:Fire(...)
	end

	return signal
end

-- Signals we create events so gurt
DeviceService.CheckDeviceType = createSignal()
DeviceService.CheckDevicePlatform = createSignal()

-- Text check setup
local TextSettings = {
	16,
	"SourceSans",
	Vector2.one * 1000,
}

local invalidSize = TextService:GetTextSize("\u{FFFF}", unpack(TextSettings))

local function isValidCharacter(character)
	local size = TextService:GetTextSize(character, unpack(TextSettings))
	return size.Magnitude ~= invalidSize.Magnitude
end

-- Device Type detection
function DeviceService:_internalDetect()
	wait()

	local size = workspace.CurrentCamera.ViewportSize

	if UserInputService.TouchEnabled then
		if tonumber(size.X) >= 1024 and tonumber(size.Y) >= 768 then
			return 'Tablet'
		elseif tonumber(size.X) >= 800 and tonumber(size.Y) >= 480 then
			return 'Phone'
		elseif tonumber(size.X) < 800 then
			return 'SmallPhone'
		else
			return 'Unknown'
		end
	else
		if UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
			return 'Computer'
		elseif UserInputService.GamepadEnabled then
			return 'Console'
		end
		
		return 'Unknown'
	end
end

--get platform i just got ts off devforum thank you @ChatGGPT from dev forum and @SomeFedoraGuy
function DeviceService:GetDevicePlatform()
	local version = version()
	local Desktop = match(version, "^0%.") ~= nil
	local Console = GuiService:IsTenFootInterface() or (match(version, "^1%.") ~= nil)
	local Mobile = match(version, "^2%.") ~= nil
	local VR = UserInputService.VREnabled and VRService.VREnabled

	if GuiService.IsWindows then
		if Mobile then
			return Enum.Platform.UWP
		elseif Console then
			return Enum.Platform.XBoxOne
		elseif isValidCharacter("\u{E0FF}") then
			return Enum.Platform.Linux
		end
		return Enum.Platform.Windows
	elseif Desktop then
		return Enum.Platform.OSX
	elseif Console then
		local ButtonSelect = lower(UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonSelect))
		if match(ButtonSelect, "ps4") then
			return Enum.Platform.PS4
		elseif match(ButtonSelect, "ps5") then
			return Enum.Platform.PS5
		elseif match(ButtonSelect, "xbox") then
			return Enum.Platform.XboxOne
		end
	elseif Mobile then
		if VR then
			return Enum.Platform.MetaOS
		elseif getArchitecture() == 32 or not isValidCharacter("\u{F8FF}") then
			if not UserInputService.TouchEnabled then
				return Enum.Platform.Linux
			end
			return Enum.Platform.Android
		end
		return Enum.Platform.IOS
	elseif VR then
		return Enum.Platform.VR
	end

	return Enum.Platform.Unknown
end

function DeviceService:IsInGroup(deviceType, group)
	return bit32.band(group, deviceType) ~= 0
end

-- Call this to fire device + platform info
function DeviceService:Emit()
	local device = self:_internalDetect()
	local platform = self:GetDevicePlatform()

	self.CheckDeviceType:Fire(device)
	self.CheckDevicePlatform:Fire(platform)
end

function DeviceService:Init()
	local device = self:_internalDetect()
	local platform = self:GetDevicePlatform()

	task.defer(function()
		self.CheckDeviceType:Fire(device)
		self.CheckDevicePlatform:Fire(platform)
	end)
end

-- Exports
DeviceService.Enumate = Enumate
DeviceService.DeviceType = Enumate.DeviceType

return DeviceService
