local path = '=mac-fries/Libraries/%s'
local url = 'https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/Libraries/%s.lua'

local libraries = {}
local function load(name)
    libraries[name] = loadstring(game:HttpGet(string.format(url, name)), string.format(path, name))()
end

load('Bit')
load('Cryptic')
load('Drawing')
load('Signal')

load('fireproximityprompt')

load('vm')

return libraries
