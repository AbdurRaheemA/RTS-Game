--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MoveUnit = ReplicatedStorage.Remotes:WaitForChild("MoveUnit") :: RemoteEvent

MoveUnit.OnServerEvent:Connect(function(player: Player, unit: Model, destination: Vector3)
	if not unit or not unit:IsDescendantOf(workspace) then
		return
	end
	local humanoid = unit:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:MoveTo(destination)
	end
end)