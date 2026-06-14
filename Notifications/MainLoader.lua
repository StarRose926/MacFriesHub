local create = loadstring(game:HttpGet('https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/Libraries/CreateInstance.lua'), '=CreateInstance')()

local NotificationURLFormat = 'https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/Notifications/%s.lua'

local cloneref = cloneref or function(obj)
    return obj
end

local CoreGui = cloneref(game:GetService('CoreGui'))

local notificationLibraries = {}
local function loadNotificationHandler(name, folder)
    notificationLibraries[name] = loadstring(game:HttpGet(string.format(NotificationURLFormat, name)))():init(folder)
end

local function makeUIMain()
    if CoreGui:FindFirstChild('MacFries') then
        return
    end

    local NotificationFolders = {
        BreakInStory = create('Folder', {
            Name = 'BreakInStory'
        })
    }

    local Gui = create('ScreenGui', {
        Name = 'MacFries',
        SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
        ScreenInsets = Enum.ScreenInsets.None,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    }, {
        create('Folder', {
            Name = 'NotificationHolder'
        }, NotificationFolders)
    })

    for name, folder in NotificationFolders do
        loadNotificationHandler(name, folder)
    end

    Gui.Parent = CoreGui
end

makeUIMain()

return notificationLibraries
