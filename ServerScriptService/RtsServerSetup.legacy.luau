--!strict
local Players = game:GetService("Players")

local PROXY_POSITION = CFrame.new(0, 0, 0)

local function hideAndFreezeCharacter(character: Model)
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5) :: BasePart?
	if not humanoidRootPart then
		return
	end

	-- Anchor character directly over the baseplate plane so client replication never breaks.
	-- This also gives the engine a fixed streaming anchor point, since the client has
	-- no controllable avatar to stream content around otherwise.
	humanoidRootPart.Anchored = true
	humanoidRootPart.CFrame = PROXY_POSITION

	-- Freeze and hide the proxy - it must never be seen, collided with, or moved by input.
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.JumpHeight = 0
		humanoid.PlatformStand = true
	end

	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Transparency = 1
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
		elseif descendant:IsA("Decal") or descendant:IsA("Accessory") then
			descendant.Parent = nil
		end
	end
end

-- Configure player properties when they enter the server
Players.PlayerAdded:Connect(function(player: Player)
	player.CharacterAdded:Connect(hideAndFreezeCharacter)

	-- CharacterAutoLoads is intentionally off (SC2-style freecam, no player-controlled
	-- avatar). We still spawn an invisible, frozen proxy character manually here:
	-- Roblox's content streaming defaults to following the character's position, and
	-- StarterGui only copies into PlayerGui on first character spawn - both of which
	-- we still need even though the player never sees or controls this character.
	player:LoadCharacterAsync()
end)