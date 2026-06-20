local function getscripts()
    local scripts = game:QueryDescendants('LocalScript')

    for _, v in game:QueryDescendants('Script') do
        if v.RunContext == Enum.RunContext.Client then
            table.insert(scripts, v)
        end
    end

    if (getnilinstances or get_nil_instances) then
        local function insertScript(v)
            if v:IsA('LocalScript') then
                table.insert(scripts, v)
            elseif v:IsA('Script') and v.RunContext == Enum.RunContext.Client then
                table.insert(scripts, v)
            end
        end
      
        for _, v in (getnilinstances or get_nil_instances)() do
            insertScript(v)

            for _, c in v:QueryDescendants('LocalScript') do
                insertScript(c)
            end
            for _, c in v:QueryDescendants('Script') do
                insertScript(c)
            end
        end
    end

    return scripts
end

return getscripts
