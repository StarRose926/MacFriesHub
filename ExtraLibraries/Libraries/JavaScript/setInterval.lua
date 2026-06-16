local function setInterval(handler, timeout, ...)
    local arguments = {...}
    local t = {
        ["Status"] = 1
    }

    if timeout == nil then
        timeout = 0
    end

    local timeoutMs = timeout / 1000
    local func
    func = function()
        task.delay(timeoutMs, function()
            if t["Status"] == 1 then
                handler(table.unpack(arguments))
                func()
            end
        end)
    end
    func()

    return t
end

return setInterval
