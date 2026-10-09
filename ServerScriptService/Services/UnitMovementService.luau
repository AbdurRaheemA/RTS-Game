--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local unitData = require(ReplicatedStorage.Configs.UnitData)

local UnitMovementService = {}
local started = false
local lastRequest: { [Player]: number } = {}
local REQUEST_INTERVAL = 0.1
local MAX_UNITS_PER_REQUEST = 200

local function isFinite(value: number): boolean
	return value == value and math.abs(value) < math.huge
end

function UnitMovementService.start()
	if started then
		return
	end
	started = true
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local moveUnit = remotes:WaitForChild("MoveUnit") :: RemoteEvent

	Players.PlayerRemoving:Connect(function(player: Player)
		lastRequest[player] = nil
	end)

	moveUnit.OnServerEvent:Connect(function(player: Player, units: any, destination: any)
		local now = os.clock()
		local previous = lastRequest[player]
		if previous and now - previous < REQUEST_INTERVAL then
			return
		end
		lastRequest[player] = now
		if typeof(units) ~= "table" or typeof(destination) ~= "Vector3" then
			return
		end
		if not isFinite(destination.X) or not isFinite(destination.Y) or not isFinite(destination.Z) then
			return
		end

		-- Reject sparse/dictionary payloads and cap work before issuing any movement.
		local count = 0
		for key in pairs(units) do
			count += 1
			if count > MAX_UNITS_PER_REQUEST or typeof(key) ~= "number"
				or key % 1 ~= 0 or key < 1 or key > MAX_UNITS_PER_REQUEST then
				return
			end
		end
		for index = 1, count do
			if units[index] == nil then
				return
			end
		end

		local unitsFolder = workspace:FindFirstChild("Units")
		if not unitsFolder or not unitsFolder:IsA("Folder") then
			return
		end
		local seen: { [Model]: boolean } = {}
		for _, unit in ipairs(units) do
			if typeof(unit) ~= "Instance" or not unit:IsA("Model") then
				continue
			end
			if unit.Parent ~= unitsFolder or seen[unit] then
				continue
			end
			seen[unit] = true
			local unitType = unit:GetAttribute("UnitType")
			if typeof(unitType) ~= "string" or not unitData[unitType]
				or unit:GetAttribute("OwnerUserId") ~= player.UserId then
				continue
			end
			local root = unit:FindFirstChild("HumanoidRootPart")
			local humanoid = unit:FindFirstChildOfClass("Humanoid")
			if root and root:IsA("BasePart") and humanoid and humanoid.Health > 0 then
				humanoid:MoveTo(destination)
			end
		end
	end)
end

return UnitMovementService
