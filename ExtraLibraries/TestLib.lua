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
        end,
        did_succeed = test.was_test_successfull
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
    return test.test_results[name] and (test.test_results[name].failed ~= false)
end

test.make_note = function(name)
    table.insert(test.orders, name)
    test.tests[name] = {
        is_note = true
    }
end

test.run_tests = function(name)
    print(`{name} | Executor Test Compatibility`)
    print("✅ - Pass, ⛔ - Fail, ⏺️ - No test, ⚠️ - Missing Functionality, 🔧 - Reapir\n")

    local success_counter, missing_counter, fail_counter = 0, 0, 0

    for i, name in pairs(test.orders) do
        local line_down = i == #test.orders and '\n' or ''

        local _test = test.tests[name]
        if _test.is_note then
            print(('⏺️ %s'):format(name))
        else
            local n = type(name) == 'table' and name[1] or name
            local glob = getGlobal(n)

            local found, missing = {}, {}
            
            if type(name) == 'table' and not glob then
                local names = table.clone(name)
                table.remove(names, 1)

                for _, v in names do
                    local global = getGlobal(v)
                    n = v

                    if not glob and global then
                        glob = global
                    end

                    if global then
                        table.insert(found, v)
                    end
                end
            end

            --if missing[1] then
            --    warn('❌ ' .. name[1] .. ' - ' .. table.concat(missing, ', '))
            --end

            if type(name) == 'table' then
                n = name[1] .. (found[1] and ' - ' .. found[1] or '') -- string.format('%s', table.concat(name, ', '))
            end

            if not glob then
                warn(('⛔ %s - Not defined'):format(n .. line_down))
            else
                local legit = type(name) == 'table' and name[1] or name

                local ok, res = pcall(_test.fn, _test.lib)
                local result = test.test_results[legit]
                _test.lib._cleanup:StartCleanup()

                if not ok then
                    fail_counter += 1
                    if _test.repair then
                        print((`🔧 %s - Failed but can be replaced: %s`):format(n, (result.reason or 'no-reason') .. line_down))
                        _test.repair()
                    else		
                        warn(('⛔ %s - Failed: %s'):format(n, res .. line_down))
                    end
                elseif result.missing then
                    missing_counter += 1
                    if typeof(result.missing_items) == 'string' then
                        warn((`⚠️ %s - Missing Functionality: %s`):format(n, result.missing_items .. line_down))
                    elseif typeof(result.missing_items) == 'table' then
                        warn((`⚠️ %s - Missing Functionality: %s`):format(n, table.concat(result.missing_items, ', ') .. line_down))
                    end
                elseif result.failed then
                    fail_counter += 1
                    if _test.repair then
                        print((`🔧 %s - Failed but can be replaced: %s`):format(n, (result.reason or 'no-reason') .. line_down))
                        _test.repair()
                    else
                        warn(('⛔ %s - Failed: %s'):format(n, result.reason .. line_down))
                    end
                else
                    success_counter += 1
                    print(('✅ %s%s'):format(n, (res and ' • ' .. tostring(res) or '') .. line_down))
                end
            end
        end
    end

    print('🏁 Finished Tests 🏁')

    local total = success_counter + missing_counter + fail_counter

    local rate = math.round(success_counter / total * 100)
    
    print(string.format('📊 Tests finished with a test score of %s%% (%s out of %s)', tostring(rate), tostring(success_counter), tostring(total)))
    print(string.format('⛔ %s %s failed!', tostring(fail_counter), (fail_counter > 1 and 'tests' or 'test')))
    print(string.format('⚠️ %s %s is missing some functionality!', tostring(missing_counter), (missing_counter > 1 and 'tests' or 'test')))
end

return test
