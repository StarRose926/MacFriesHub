return function(test)
    local part = Instance.new('Part', workspace)
    test.clean(part)
    part.CanCollide = false
    part.Position = game:GetService('Players').LocalPlayer.Character.PrimaryPart.Position
    part.Anchored = true

    local prompt = Instance.new('ProximityPrompt')
    prompt.Parent = part

    local can_fire = false
    prompt.Triggered:Connect(function()
        can_fire = true
    end)

    fireproximityprompt(prompt)

    task.wait(1)

    test.assert(can_fire, 'Did not fire off ProximityPrompt within 1 Second!')
end
