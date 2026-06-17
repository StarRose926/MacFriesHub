local function was_successfull_multi(test, list)
    for _, name in list do
        if not test.was_test_successfull(name) then
            return false
        end
    end

    return true
end

return {
    was_successfull_multi = was_successfull_multi
}
