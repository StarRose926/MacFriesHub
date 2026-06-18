local cloneref = cloneref or function(obj)
    return obj
end

local HttpService = cloneref(game:GetService('HttpService'))

local TestLib = loadstring(game:HttpGet('http://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/ExtraLibraries/TestLib.lua'))()

local test_info = HttpService:JSONDecode(game:HttpGet('https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/ExtraLibraries/Tests/tests.json'))
local url = 'https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/ExtraLibraries/Tests/tests/%s.lua'

for _, v in test_info.tests do
    local name = type(v) == 'table' and v[1] or v
    local test_str = game:HttpGet(string.format(url, name))

    if test_str ~= '404: Not Found' then
        local func = loadstring(test_str)()
            
        local data = game:HttpGet(('https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/Executor/%s.luau'):format(v))

        TestLib.create(v, func, data ~= '404: Not Found' and function()
            return loadstring(data)()
        end)
    end
end

TestLib.run_tests('MacFries')

return TestLib
