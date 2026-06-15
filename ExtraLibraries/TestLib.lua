local Orchestrator = loadstring(game:HttpGet('https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/ExtraLibraries/Orchestrator.lua'))()

local env = getfenv()

local function getGlobal(path)
    local value = env

    while value ~= nil and path ~= "" do
        local name, nextValue = string.match(path, "^([^.]+)%.?(.*)$")
        value = value[name]
        path = nextValue
    end

    return value
end

local test = {}
test.orders = {}
test.results = {
    fails = 0,
    success = 0,
    could_repair = 0
}
test.notes = {}
test.test_results = setmetatable({}, {
    __index = function(self, idx)
        if not rawget(self, idx) then
            rawset(self, idx, {})
        end

        return rawget(self, idx)
    end,
})
test.tests = {}

local function expect(name)
    local self
    self = {
        _cleanup = Orchestrator.new(),
        failed = function(reason)
            if test.test_results[name].failed then return end
            test.test_results[name].failed = true
            test.test_results[name].reason = reason
        end,
        missing = function(missing_items)
            test.test_results[name].missing = true
            test.test_results[name].missing_items = missing_items
        end,
        clean = function(obj)
            self._cleanup:AddObject(obj)
        end
    }
  
    self.assert = function(con, reason)
        if not con and self.failed then
            self.failed(reason)
        end
    end
  
    return self
end

test.create = function(name, fn, repair)
    table.insert(test.orders, name)
    test.tests[name] = {
        fn = fn,
        lib = expect(name),
        repair = repair
    }
end

test.was_test_successfull = function(name)
    return test.test_results[name] and (test.test_results[name].failed ~= false) and table.find(test.orders, name)
end

test.make_note = function(name)
    table.insert(test.orders, name)
    test.tests[name] = {
        is_note = true
    }
end

test.run_tests = function(name)
    print(`{name} | Executor Test Compatibility`)
    print("✅ - Pass, ⛔ - Fail, ⏺️ - No test, 🔧 - Reapir\n")

    local success_counter, fail_counter = 0, 0

    for _, name in pairs(test.orders) do
        local _test = test.tests[name]
        if _test.is_note then
            print(('⏺️ %s'):format(name))
        else
            local glob = getGlobal(name)
            if not glob then
                warn(('⛔ %s - Is not defined'):format(name))
            else
                local ok, res = pcall(_test.fn, _test.lib)
                local result = test.test_results[name]
                _test._cleanup:StartCleanup()

                if not ok then
                    fail_counter += 1
                    if _test.repair then
                        print((`🔧 %s - Failed but can be replaced: %s`):format(name, res))
                        _test.repair()
                    else		
                        warn(('⛔ %s - Failed: %s'):format(name, res))
                    end
                elseif result.failed then
                    fail_counter += 1
                    if _test.repair then
                        print((`🔧 %s - Failed but can be replaced: %s`):format(name, result.reason))
                        _test.repair()
                    else
                        warn(('⛔ %s - Failed: %s'):format(name, result.reason))
                    end
                else
                    success_counter += 1
                    print(('✅ %s'):format(name))
                end
            end
        end
    end

    print('\n')
    print('🏁 Finished Tests 🏁')

    local rate = math.round(success_counter / (success_counter + fail_counter) * 100)
    
    print(string.format('📊 Tests finished with a test score of %s% (%s out of %s)'):format(tostring(rate), tostring(success_counter), tostring(success_counter + fail_counter)))
    print(string.format('⛔ %s %s failed!', tostring(fail_counter), (fail_counter > 1 and 'tests' or 'test')))
end

return test
