return function(test)
    local up_1, up_2 = math.random(1, 7), math.random(1, 14)

    -- Shift them around! (makes it harder too spoof!)
    local function closure()
        local old_up = up_1
        up_1 = up_2
        up_2 = old_up
    end

    local did_fail = false
    local function runUpvalueCheck()
        closure()
        local upvalues = {
            debug.getupvalue(closure, 1),
            debug.getupvalue(closure, 2)
        }
    
        test.assert(upvalues[1] == up_1, `Did not return the correct value of upvalue (1) (expected {up_1}, got {tostring(upvalues[1])})`)
        test.assert(upvalues[2] == up_2, `Did not return the correct value of upvalue (2) (expected {up_2}, got {tostring(upvalues[2])})`)

        if up_1 ~= upvalues[1] or up_2 ~= upvalues[2] then
            did_fail = true
        end
    end

    for _ = 1, math.random(1, 5) do
        runUpvalueCheck()

        if did_fail then return end
    end
end
