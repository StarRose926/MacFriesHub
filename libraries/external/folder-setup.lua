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

if create_placeid then
    _makefolder('MacFries/Saves/' .. tostring(game.PlaceId))
end

_writefile('MacFries/REGISTRY', '')

_writefile('MacFries/settings.ini', '')

return 'MacFries'
