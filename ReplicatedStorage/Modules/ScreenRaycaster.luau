--!strict

local Workspace = game:GetService("Workspace")

local ScreenRaycaster = {}

function ScreenRaycaster.raycast(screenPosition: Vector2): RaycastResult?
	local camera = Workspace.CurrentCamera
	assert(camera, "CurrentCamera is nil")

	local ray = camera:ViewportPointToRay(screenPosition.X, screenPosition.Y)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true

	return Workspace:Raycast(
		ray.Origin,
		ray.Direction * 1000,
		params
	)
end

return ScreenRaycaster