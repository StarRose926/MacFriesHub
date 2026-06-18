-- BY: StarRose
--
-- Solara dosent even have "fireproximityprompt" last time i checked 💀

local function fireproximityprompt(prompt)
	assert(prompt, 'Argument #1 missing or nil')
	assert(typeof(prompt) == 'Instance' and prompt:IsA('ProximityPrompt'), 'Attempted to fire a value that is not a ProximityPrompt')
	
	-- make some saves (so we can restore them later)
	local hold = prompt.HoldDuration
	local dist = prompt.MaxActivationDistance
	local rlos = prompt.RequiresLineOfSight
	local en = prompt.Enabled
	
	-- lets make some changes
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = math.huge
	prompt.RequiresLineOfSight = false
	prompt.Enabled = true
	
	-- holding the prompt
	prompt:InputHoldBegin()
	task.wait(prompt.HoldDuration + 0.05)
	prompt:InputHoldEnd()
	
	-- restore it back!
	prompt.HoldDuration = hold
	prompt.MaxActivationDistance = dist
	prompt.RequiresLineOfSight = rlos
	prompt.Enabled = en
end

return fireproximityprompt
