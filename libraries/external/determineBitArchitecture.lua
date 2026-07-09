return function()
    local address = tonumber(string.sub(tostring({math.huge}), 8))

    if #tostring(address) <= 10 then
        return 32
    end

    return 64
end
