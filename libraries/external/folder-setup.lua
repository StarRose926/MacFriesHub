local HttpService = game:GetService('HttpService')

local create_placeid = ...

local function _makefolder(path)
    if not isfolder(path) then
        makefolder(path)
    end
end

local function _writefile(path, content)
    if not isfile(path) then
        writefile(path, content)
    end
end

_makefolder('MacFries')

_makefolder('MacFries/Saves')
_makefolder('MacFries/Translations')
_makefolder('MacFries/Logs')

_writefile('MacFries/config.json', HttpService:JSONEncode({
    translationVersion = "0.0.0"
}))

if create_placeid then
    _makefolder('MacFries/Saves/' .. tostring(game.PlaceId))
end

_writefile('MacFries/REGISTRY', '')

_writefile('MacFries/settings.ini', '')


local translationList = HttpService:JSONDecode(game:HttpGet('https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/Translations/list.json'))
local config = HttpService:JSONDecode(readfile('MacFries/config.json'))

if config.translationVersion ~= translationList.version then
    for _, n in translationList.list do
        _writefile(string.format('MacFries/Translations/%s.%s', n, translationList.extension), game:HttpGet(string.format('https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/Translations/%s.%s', n, translationList.extension)))
    end
    
    config.translationVersion = translationList.version
end
writefile('MacFries/config.json', HttpService:JSONEncode(config))

return 'MacFries'
