local function switch(switchParam)
    local s
    s = {
        case = function(param, fn)
            if param == switchParam then
                fn(switchParam)
            end

            return s
        end
    }

    return s
end

local function safeGet(table, index, fallback)
    local ok, res = pcall(function()
        return table[index]
    end)

    if not ok then return fallback end

    return res
end

local function safeRawGet(table, index, fallback)
    local ok, res = pcall(rawget, table, index)

    if not ok then return fallback end

    return res
end

local function selectPcall(index, f, ...)
    return select(index, pcall(f, ...))
end

local function listSearch(table, list, fn)
    for _, item in list do
        if not fn(table, item) then
            return false
        end
    end

    return true
end

local validate
validate = function(table, template)
    if typeof(table) ~= "table" then
        return template
    end

    for k, v in template do
        if typeof(k) == "number" then
            continue
        end

        if typeof(v) == "table" then
            table[k] = validate(table[k], v)
        elseif table[k] == nil then
            table[k] = v
        end
    end

    return table
end


local Orchestrator = {}
Orchestrator.__index = {}

function Orchestrator.GetCleanerName(cleaner): string
    -- Detect a "Maid" Cleaner!
    if listSearch(cleaner, {'isMaid', 'GiveTask', 'DoCleaning', 'Destroy'}, function(t, k)
        return safeGet(t, k, nil)
    end) then
        return 'Maid'
    end

    if listSearch(cleaner, {'GivePromise', 'AddPromise', 'AddObject', 'GiveObject', 'Remove', 'Get', 'Cleanup', 'Clean', 'Destroy', 'LinkToInstance', 'LinkToInstances'}, function(t, k)
        return safeGet(t, k, nil)
    end) then
        return 'Janitor'
    end

    if listSearch(cleaner, {'Extend', 'Clone', 'Construct', 'Connect', 'BindToRenderStep', 'AddPromise', 'Add', 'Remove', 'Pop', 'Clean', 'WrapClean', 'AttachToInstance', 'Destroy'}, function(t, k)
        return safeGet(t, k, nil)
    end) then
        return 'Trove'
    end

    return 'Unknown'
end

function Orchestrator.GetConnectionName(connection): knownSignals | 'Unknown'
    -- NOTE (GoodSignal): Looks like a Normal Signal. So we have to relay on it erroring!
    do
        local err = selectPcall(2, function()
            connection._trash_collector_con()
        end)

        if err and (err:find('Attempt to get Connection::') and err:sub(-20) == '(not a valid member)' and safeGet(connection, '_signal')) then
            return 'GoodSignal'
        end
    end

    -- NOTE (FastSignal): Also simular to "GoodSignal", however, a few diffirences we can attempt to detect for!
    do
        if (safeGet(connection, '_node') and safeGet(connection._node, '_signal') and safeGet(connection._node._signal, 'ConnectOnce') and safeGet(connection._node._signal, 'IsActive')) and safeGet(connection, 'Destroy') then
            return 'FastSignal'
        end
    end

    -- NOTE (LemonSignal)
    do
        if (safeGet(connection, 'Reconnect')) and (safeGet(connection, '_signal') and safeGet(connection._signal, 'Destroy') and safeGet(connection._signal, 'wrap') and safeGet(connection._signal, 'RBXScriptConnection')) then
            return 'LemonSignal'
        end
    end

    -- NOTE (SignalPlus)
    do
        if (safeGet(connection, 'Signal') and safeGet(connection.Signal, 'Destroy') and safeGet(connection, 'Callback')) then
            return 'SignalPlus'
        end
    end

    return 'Unknown'
end

function Orchestrator.new(...: any): typeof(Orchestrator.__index)
    return setmetatable({
        _objects = {...},
        _cleaning = false
    }, Orchestrator)
end

local templates = {
    cleanup_advanced_settings = {
        connections = {
            all = true
        },
        threads = {
            all = true,

            use_task_cleanup = true
        }
    }
}

function Orchestrator.__index:StartCleanup(advancedSettings: advancedSettings?)
    local settings = validate(advancedSettings, templates.cleanup_advanced_settings)

    local has_cleaned = function(idx)
        table.remove(self._objects, idx)
    end

    for idx, _task in next, self._objects do
        switch(typeof(_task))
            .case('RBXScriptConnection', function(_)
                if settings.connections.all or settings.connections.roblox then
                    _task:Disconnect()
                    has_cleaned(idx)
                end
            end)
            .case('thread', function(_)
                if (settings.threads.all or settings.threads.roblox) then    
                    local ok, res = pcall(coroutine.close, _task)

                    if not ok and settings.threads.use_task_cleanup then
                        ok, res = pcall(task.cancel, _task)
                    end

                    if not ok then
                        warn(`[Orchestrator.StartCleanup] Errored while cleaning up (thread) ({tostring(task)}): {res}\n\n{debug.traceback()}`)
                    end
                end
            end)
            .case('Instance', function(_)
                _task:Destroy()
            end)
    end
end

function Orchestrator.__index:AddObject(object: any)
    table.insert(self._objects, object)
end

return Orchestrator
