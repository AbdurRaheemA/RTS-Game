--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
assert(player, "LocalPlayer is nil")

local SpawnUnit = ReplicatedStorage.Remotes:WaitForChild("SpawnUnit") :: RemoteEvent

-- Temporary test-only spawn trigger. Replace with a real UI button once one
-- exists (tracked alongside Phase 3's resource HUD).
local HOTKEY_UNIT_MAP: { [Enum.KeyCode]: string } = {
	[Enum.KeyCode.One] = "Swordsman",
	[Enum.KeyCode.Two] = "Archer",
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	local unitType = HOTKEY_UNIT_MAP[input.KeyCode]
	if unitType then
		SpawnUnit:FireServer(unitType)
	end
end)