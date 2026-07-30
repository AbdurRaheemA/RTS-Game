--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UnitMovementService = {}

function UnitMovementService.start()
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local moveUnit = remotes:WaitForChild("MoveUnit") :: RemoteEvent

	moveUnit.OnServerEvent:Connect(function(player: Player, unit: Model, destination: Vector3)
		if not unit or not unit:IsDescendantOf(workspace) then
			return
		end
		local humanoid = unit:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:MoveTo(destination)
		end
	end)
end

return UnitMovementService