return function(test)
    local bindable = Instance.new('BindableEvent')
    local waitableEvent = Instance.new('BindableEvent')
    test.clean(bindable)
    test.clean(waitableEvent)

    local amount = math.random(1, 3)

    local fired_by = {}
    local event_functions = {}
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

    local running = coroutine.running()
    local thread = task.delay(function()
        test.assert(fired_by[1], 'Did fire the Connection (1)')
        task.spawn(running)
    end, 5)

    task.spawn(function()
        waitableEvent.Event:Wait()
        task.cancel(thread)
    end)

    con:Fire(1)

    return coroutine.yield()
end
