return function(test)
    local part = Instance.new('Part', workspace)
    test.clean(part)
    part.CanCollide = false
    part.Position = game:GetService('Players').LocalPlayer.Character.PrimaryPart.Position
    part.Anchored = true

    local clickdetector = Instance.new('ClickDetector')
    clickdetector.Parent = part

    local can_fire = false
    clickdetector.MouseClick:Connect(function()
        can_fire = true
    end)

    fireclickdetector(clickdetector)

    task.wait(1)

    test.assert(can_fire, 'Did not fire off ClickDetector within 1 Second!')
end
