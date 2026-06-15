return function(test)
    local bindable = Instance.new('BindableEvent')
    test.clean(bindable)
  
    local did_fire = false
    bindable.Event:Once(function()
        did_fire = true
    end)

    firesignal(bindable.Event)

    -- Wait for a Signal Update
    task.wait(0.01)

    test.assert(did_fire, 'Did not fire the BindableEvent')
end
