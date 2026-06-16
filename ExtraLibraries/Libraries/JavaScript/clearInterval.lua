local function clearInterval(interval)
    if type(interval) == 'table' and interval.Status == 1 then
        interval.Status = 0
    end
end

return clearInterval
