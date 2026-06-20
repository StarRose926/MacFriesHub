local function getmodules(parent)
    return parent:QueryDescendants('ModuleScript')
end

return getmodules
