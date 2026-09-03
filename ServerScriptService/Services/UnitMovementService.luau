--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UnitMovementService = {}

function UnitMovementService.start()
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local moveUnit = remotes:WaitForChild("MoveUnit") :: RemoteEvent

	moveUnit.OnServerEvent:Connect(function(player: Player, units: { Model }, destination: Vector3)
		if typeof(units) ~= "table" then
			return
		end

		for _, unit in ipairs(units) do
			if typeof(unit) ~= "Instance" or not unit:IsA("Model") then
				continue
			end
			if not unit:IsDescendantOf(workspace) then
				continue
			end
			-- NOTE: no ownership check yet — Phase 2 adds an Owner attribute
			-- and restricts this to units owned by `player`.
			local humanoid = unit:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:MoveTo(destination)
			end
		end
	end)
end

return UnitMovementService