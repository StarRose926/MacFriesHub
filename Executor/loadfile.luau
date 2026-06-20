local function loadfile(path)
    return loadstring(readfile(path), '=' .. path)
end

return loadfile
