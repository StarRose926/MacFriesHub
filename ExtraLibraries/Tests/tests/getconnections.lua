return function(test)
    local bindable = Instance.new('BindableEvent')
    test.clean(bindable)

    local amount = math.random(1, 3)

    local fired_by = {}
    local event_functions = {}
    for i = 1, amount do
        event_functions[i] = function(res)
            if res == i then
                fired_by[i] = true
            end
        end
        test.clean(bindable.Event:Connect(event_functions[i]))
    end

    local connections = getconnections(bindable.Event);

    test.assert(type(connections) == 'table', 'Connections result expected to be a Table!')
    test.assert(#connections == amount, `Did not find all {tostring(amount)} connections!`)

    for i, con in connections do
        local fn = event_functions[i]
        test.assert(type(con.Function) == 'function', `Function for index {i} did not return a Function! (got {type(con.Function)})`)
        con:Fire(i)

        -- Roblox Queue maybe delayed!
        task.wait(0.1)

        test.assert(fired_by[i], `Did not fire the Connection with Argument ({i})`)
    end
end
