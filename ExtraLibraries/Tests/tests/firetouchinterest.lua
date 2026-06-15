return function(test)
    local rootPart = game:GetService('Players').LocalPlayer.Character.PrimaryPart
  
    local part = Instance.new('Part', workspace)
    test.clean(part)
    part.Transparency = 1
    part.CanCollide = false
    part.Anchored = true
    part.Position = rootPart.Position + Vector3.new(100, 100, 100)

    local did_fire = false
    part.Touched:Connect(function(touched)
        if touched == rootPart then
            did_fire = true
        end
    end)

    firetouchinterest(part, rootPart, 0)

    task.wait(0.5)

    test.assert(did_fire, 'Did not touch the Part with the Client(s) Character')
end
