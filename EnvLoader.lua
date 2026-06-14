local env = loadstring(game:HttpGet('https://raw.githubusercontent.com/StarRose926/MacFriesHub/refs/heads/main/Libraries/LibraryLoader.lua'), '=LibraryLoader')();

local translations = {{'Cryptic', 'crypt'}, {'Signal', 'SynSignal'}}

return function(fenv)
    for _, trans in translations do
        local lib = env[trans[1]]

        if lib then
            env[trans[2]] = lib
            env[trans[1]] = nil
        end
    end

    for name, lib in env do
        if not fenv[name] then
            fenv[name] = lib
        end
    end

    return fenv
end
