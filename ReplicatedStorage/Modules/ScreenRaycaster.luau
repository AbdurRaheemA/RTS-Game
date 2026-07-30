--!strict

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local ScreenRaycaster = {}

function ScreenRaycaster.raycast(screenPosition: Vector2): RaycastResult?
	local camera = Workspace.CurrentCamera
	assert(camera, "CurrentCamera is nil")

	local ray = camera:ViewportPointToRay(screenPosition.X, screenPosition.Y)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true

	local exclude: { Instance } = {}
	local localPlayer = Players.LocalPlayer
	if localPlayer and localPlayer.Character then
		table.insert(exclude, localPlayer.Character)
	end
	params.FilterDescendantsInstances = exclude

	return Workspace:Raycast(
		ray.Origin,
		ray.Direction * 1000,
		params
	)
end

return ScreenRaycaster