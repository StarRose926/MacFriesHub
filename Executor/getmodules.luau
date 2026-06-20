local function getmodules()
    local modules = game:QueryDescendants('ModuleScript')

    if (getnilinstances or get_nil_instances) then
        for _, v in (getnilinstances or get_nil_instances)() do
            if v:IsA('ModuleScript') then
                table.insert(modules, v)
            end

            for _, c in v:QueryDescendants('ModuleScript') do
                table.insert(modules, c)
            end
        end
    end

    return modules
end

return getmodules
