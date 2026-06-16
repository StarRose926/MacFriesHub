local VirtualInputManager = game:GetService('VirtualInputManager')

local function getButtonScreenVector(button)
    local pos, size = button.AbsolutePosition, button.AbsoluteSize
    local x, y = pos.X + (size.X / 2), pos.Y + (size.Y / 2)

    return Vector2.new(x, y)
end

local MouseButton = {
    Left = 0,
    Right = 1
}

local function holdbutton(button, click_type)
    local vec = getButtonScreenVector(button)

    VirtualInputManager:SendMouseButtonEvent(vec.X, vec.Y, MouseButton[click_type], true, game, 0)
end

local function releasebutton(button, click_type)
    local vec = getButtonScreenVector(button)

    VirtualInputManager:SendMouseButtonEvent(vec.X, vec.Y, MouseButton[click_type], false, game, 0)
end

local function clickbutton(button, click_type, hold_duration)
    holdbutton(button, click_type)
    task.wait(hold_duration or 0)
    releasebutton(button, click_type)
end

return {
    holdbutton = holdbutton,
    releasebutton = releasebutton,
    clickbutton = clickbutton
}
