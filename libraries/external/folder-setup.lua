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

if create_placeid then
    _makefolder('MacFries/Saves/' .. tostring(game.PlaceId))
end

_writefile('MacFries/Registry', '')

return 'MacFries'
