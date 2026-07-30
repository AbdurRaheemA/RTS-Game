--!strict
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera") :: Camera

-- Wait safely for structural workspace geometry to replicate
local baseplate = Workspace:WaitForChild("Baseplate", 5)

local LOG_INTERVAL = 10
local timeElapsed = 0

local function logCameraState(deltaTime: number)
	timeElapsed += deltaTime
	if timeElapsed >= LOG_INTERVAL then
		timeElapsed = 0

		local camCFrame = camera.CFrame
		local lookDirection = camCFrame.LookVector

		-- Setup exhaustive physical raycast parameters
		local raycastParam = RaycastParams.new()
		raycastParam.FilterType = Enum.RaycastFilterType.Exclude
		raycastParam.FilterDescendantsInstances = {}
		raycastParam.IgnoreWater = false

		local raycastResult = Workspace:Raycast(camCFrame.Position, lookDirection * 2000, raycastParam)
		local groundIntersect = "No Surface Intersected"

		if raycastResult then
			groundIntersect = string.format("%s (Hit: %s)", tostring(raycastResult.Position), raycastResult.Instance:GetFullName())
		else
			-- Fallback Mathematical Intersect Check (If baseplate exists at Y = -8)
			local targetY = -8
			if camCFrame.Position.Y > targetY and lookDirection.Y < 0 then
				local t = (targetY - camCFrame.Position.Y) / lookDirection.Y
				local mathPos = camCFrame.Position + lookDirection * t
				groundIntersect = string.format("MISS! Math calculated plane intersect would be at: %s", tostring(mathPos))
			end
		end

		print(string.format(
			"[RTS DEBUG]\n -> Camera Pos: %s\n -> Look Vector: %s\n -> Ground Intersect: %s\n -> Baseplate Loaded: %s",
			tostring(camCFrame.Position),
			tostring(lookDirection),
			groundIntersect,
			tostring(baseplate ~= nil)
			))
	end
end

RunService.RenderStepped:Connect(logCameraState)