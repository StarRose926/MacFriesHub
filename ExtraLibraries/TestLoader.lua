local cloneref = cloneref or function(obj)
    return obj
end

local HttpService = cloneref(game:GetService('HttpService'))

local TestLib = loadstring(game:HttpGet('http://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/ExtraLibraries/TestLib.lua'))()

local test_info = HttpService:JSONDecode(game:HttpGet('https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/ExtraLibraries/Tests/tests.json'))
local url = 'https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/ExtraLibraries/Tests/tests/%s.lua'

for _, v in test_info.tests do
    if typeof(v) == 'string' do
        local test_str = game:HttpGet(string.format(url, v))

        if test_str ~= '404: Not Found' then
            local func = loadstring(test_str)()

            TestLib.create(v, func)
        end
    end
end

TestLib.run_tests('MacFries')

return TestLib
