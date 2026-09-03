--!strict

local Workspace = game:GetService("Workspace")

local SelectionUtils = {}

--// Returns all units in workspace.Units whose HumanoidRootPart projects
--// on-screen within the given screen-space rectangle.
function SelectionUtils.raycastUnitsInScreenRect(topLeft: Vector2, bottomRight: Vector2): { Model }
	local camera = Workspace.CurrentCamera
	assert(camera, "CurrentCamera is nil")

	local unitsFolder = Workspace:FindFirstChild("Units")
	if not unitsFolder then
		return {}
	end

	local minX = math.min(topLeft.X, bottomRight.X)
	local maxX = math.max(topLeft.X, bottomRight.X)
	local minY = math.min(topLeft.Y, bottomRight.Y)
	local maxY = math.max(topLeft.Y, bottomRight.Y)

	local selected: { Model } = {}

	for _, unit in ipairs(unitsFolder:GetChildren()) do
		if not unit:IsA("Model") then
			continue
		end

		local rootPart = unit.PrimaryPart
		if not rootPart then
			continue
		end

		local screenPoint, onScreen = camera:WorldToViewportPoint(rootPart.Position)
		if not onScreen then
			continue
		end

		if screenPoint.X >= minX and screenPoint.X <= maxX and screenPoint.Y >= minY and screenPoint.Y <= maxY then
			table.insert(selected, unit)
		end
	end

	return selected
end

return SelectionUtils