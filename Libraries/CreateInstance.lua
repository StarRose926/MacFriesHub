return function(class, props, insts)
    local inst = Instance.new(class)

    if props then
        for index, value in props do
            inst[index] = value
        end
    end

    if insts then
        for _, _inst in insts do
            _inst.Parent = inst
        end
    end

    return inst
end
