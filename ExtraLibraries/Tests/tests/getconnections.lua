return function(test)
    local bindable = Instance.new('BindableEvent')
    local waitableEvent = Instance.new('BindableEvent')
    test.clean(bindable)
    test.clean(waitableEvent)

    local amount = math.random(1, 3)

    local fired_by = {}
    for i = 1, amount do
        test.clean(bindable.Event:Connect(function(res)
            if res == i then
                fired_by[i] = true
                waitableEvent:Fire()
            end
        end))
    end

    local connections = getconnections(bindable.Event);

    test.assert(type(connections) == 'table', 'Connections result expected to be a Table!')
    test.assert(#connections == amount, `Did not find all {tostring(amount)} connections!`)

    for i, con in connections do
        test.assert(type(con.Function) == 'function', `Function for index {i} did not return a Function! (got {type(con.Function)})`)
    end

    local con = connections[1]
    
    test.assert(con.Fire, 'Connection does not have :Fire!')
    if not con.Fire then return end

    local running = coroutine.running()
    local thread = task.delay(5, function()
        test.assert(fired_by[1], 'Did not fire the Connection (1)')
        task.spawn(running)
    end)

    task.spawn(function()
        waitableEvent.Event:Wait()
        task.cancel(thread)
        task.spawn(running)
    end)

    task.delay(0.05, function()
        if coroutine.status(running) ~= 'suspended' then
            repeat
                task.wait()
            until coroutine.status(running) == 'suspended'
        end
        
        for _, con in connections do
            if con.Fire then
                con:Fire(1)
            end
        end
    end)

    return coroutine.yield()
end
