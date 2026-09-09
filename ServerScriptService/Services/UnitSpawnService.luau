--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local UnitFactory = require(ServerScriptService.Services.UnitFactory)
local unitData = require(ReplicatedStorage.Configs.UnitData)

local UnitSpawnService = {}

-- Deterministic per-player spawn offset so units don't stack on top of each
-- other. This is a placeholder until Phase 5 base-building provides real,
-- per-player spawn points.
local SPAWN_ORIGIN = Vector3.new(0, -7, 0)
local SPAWN_SPACING = 10

function UnitSpawnService.start()
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local spawnUnit = remotes:WaitForChild("SpawnUnit") :: RemoteEvent

	spawnUnit.OnServerEvent:Connect(function(player: Player, unitType: string)
		if typeof(unitType) ~= "string" then
			return
		end
		if not unitData[unitType] then
			warn(`SpawnUnit: unknown unit type "{unitType}" requested by {player.Name}`)
			return
		end

		-- NOTE: no cost/economy gate yet — Phase 3 adds ResourceService and
		-- charges UnitData[type].Cost before allowing this to succeed.
		local offset = Vector3.new((player.UserId % 10) * SPAWN_SPACING, 0, 0)
		local spawnCFrame = CFrame.new(SPAWN_ORIGIN + offset)

		UnitFactory.createUnit(unitType, spawnCFrame, player)
	end)
end

return UnitSpawnService