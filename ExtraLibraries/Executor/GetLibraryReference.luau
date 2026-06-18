local SortedList = {
    fireclickdetector = fireclickdetector,
    firetouchinterest = firetouchinterest or firetouchtransmitter,
    fireproximityprompt = fireproximityprompt,
    firesignal = firesignal,
    hookfunction = hookfunction, -- add the rest later
    ishooked = ishooked or isfunctionhooked,
    restorefunction = restorefunction, -- add the rest later
    getsenv = getsenv,
    getconnections = getconnections
}

return function(listOrName)
    if type(listOrName) == "table" then
        local list = {}
    
        for _, name in listOrName do
            list[name] = SortedList[name]
        end

        return list
    else
        return SortedList[listOrName]
    end
end
