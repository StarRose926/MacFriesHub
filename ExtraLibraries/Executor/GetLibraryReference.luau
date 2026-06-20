local SortedList = {
    fireclickdetector = fireclickdetector,
    firetouchinterest = firetouchinterest or firetouchtransmitter,
    fireproximityprompt = fireproximityprompt,
    firesignal = firesignal,
    hookfunction = hookfunction, -- add the rest later
    ishooked = ishooked or isfunctionhooked,
    restorefunction = restorefunction, -- add the rest later
    getsenv = getsenv,
    getconnections = getconnections,
    setidentity = (syn and (syn.setthreadidentity or syn.set_thread_identity)) or setthreadidentity or set_thread_identity or setidentity,
    getidentity = (syn and (syn.getthreadidentity or syn.get_thread_identity)) or getthreadidentity or get_thread_identity or getidentity
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
