--!strict
local StarterGui = game:GetService("StarterGui")

-- Safely disable standard Roblox player gameplay UIs
task.spawn(function()
	local success = false
	while not success do
		local result = pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		end)
		if result then
			success = true
		else
			task.wait(0.1)
		end
	end
end)