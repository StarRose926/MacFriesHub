local url = 'https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/Executor/%s.luau'
local function loadFallbackLibrary(name)
    return loadstring(game:HttpGetAsync(string.format(url, name)))()
end

local SortedList = {
    fireclickdetector = fireclickdetector,
    firetouchinterest = firetouchinterest or firetouchtransmitter,
    fireproximityprompt = fireproximityprompt or loadFallbackLibrary('fireproximityprompt'),
    firesignal = firesignal,
    hookfunction = (hookfunction or hookfunc or replacefunc) or (replaceclosure) or (detourfunction or detour_function) or (detourclosure or detour_closure),
    ishooked = (ishooked or is_hooked) or (isfunctionhooked or is_function_hooked),
    restorefunction = (restorefunction or restorefunc) or (restoreclosure or restore_closure),
    getsenv = getsenv,
    getconnections = getconnections,
    setidentity = (syn and (syn.setthreadidentity or syn.set_thread_identity)) or setthreadidentity or set_thread_identity or setidentity or set_identity,
    getidentity = (syn and (syn.getthreadidentity or syn.get_thread_identity)) or getthreadidentity or get_thread_identity or getidentity or get_identity,
    Drawing = Drawing or loadFallbackLibrary('Drawing'),
    crypt = crypt or loadFallbackLibrary('crypt'),
    clonefunction = (clonefunction or clonefunc) or (cloneclosure or clone_closure) or (clone_function or clone_func),

    -- file-system
    loadfile = loadfile or loadFallbackLibrary('loadfile'),

    -- scripts
    getscripts = (getscripts or get_scripts) or loadFallbackLibrary('getscripts'),
    getscriptclosure = (getscriptfunction or get_script_function) or (getscriptclosure or get_script_closure),
    gettenv = (gettenv) or (getstateenv or get_state_env),
    setclosureidentity = setclosureidentity or setclosurecaps
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
