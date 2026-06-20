local url = 'https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/Executor/%s.luau'
local function loadFallbackLibrary(name)
    return loadstring(game:HttpGetAsync(string.format(url, name)))()
end

local SortedList = {
    fireclickdetector = (fireclickdetector or fire_clickdetector or fire_click_detector),
    firetouchinterest = (firetouchinterest or fire_touchinterest or fire_touch_interest) or firetouchtransmitter,
    fireproximityprompt = (fireproximityprompt or fire_proximityprompt or fire_proximity_prompt) or loadFallbackLibrary('fireproximityprompt'),
    firesignal = firesignal or fire_signal,
    hookfunction = (hookfunction or hookfunc or replacefunc) or (replaceclosure) or (detourfunction or detour_function) or (detourclosure or detour_closure),
    ishooked = (ishooked or is_hooked) or (isfunctionhooked or is_function_hooked),
    restorefunction = (restorefunction or restorefunc) or (restoreclosure or restore_closure) or (restore_function or restore_func),
    getsenv = getsenv or (getscriptenv or get_script_env),
    setidentity = (syn and (syn.setthreadidentity or syn.set_thread_identity)) or (setthreadidentity or set_thread_identity) or (setidentity or set_identity) or (setthreadcontext or set_thread_context) or (setcontext or set_context),
    getidentity = (syn and (syn.getthreadidentity or syn.get_thread_identity)) or (getthreadidentity or get_thread_identity) or (getidentity or get_identity) or (getthreadcontext or get_thread_context) or (getcontext or get_context),
    Drawing = Drawing or loadFallbackLibrary('Drawing'),
    crypt = crypt or loadFallbackLibrary('crypt'),
    clonefunction = (clonefunction or clonefunc) or (cloneclosure or clone_closure) or (clone_function or clone_func),
    
    -- Signal
    getconnections = (getconnections or get_connections),
    issignalhooked = (issignalhooked or is_signal_hooked),
    hooksignal = (hooksignal or hook_signal),


    getnilinstances = getnilinstances or get_nil_instances,

    -- file-system
    loadfile = loadfile or loadFallbackLibrary('loadfile'),

    -- scripts
    getscripts = (getscripts or get_scripts) or loadFallbackLibrary('getscripts'),
    getmodules = (getmodules or get_modules) or loadFallbackLibrary('getmodules'),
    getscriptclosure = (getscriptfunction or get_script_function) or (getscriptclosure or get_script_closure),
    gettenv = (gettenv) or (getstateenv or get_state_env),
    setclosureidentity = (setclosureidentity or set_closure_identity) or (setclosurecaps or set_closure_caps),
    getcallingscript = (getcallingscript or get_calling_script) or (getscriptcaller or get_script_caller) or (getcaller or get_caller)
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
