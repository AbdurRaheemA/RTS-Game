--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local unitData = require(ReplicatedStorage.Configs.UnitData)
local UnitFactory = {}
export type Unit = Model
function UnitFactory.createUnit(unitType: string, spawnCFrame: CFrame, owner: Player): Unit
	local stats = unitData[unitType]
	assert(stats, `Unknown unit type: {unitType}`)
	local model = Instance.new("Model")
	model.Name = unitType
	local rootPart = Instance.new("Part")
	rootPart.Name = "HumanoidRootPart"
	rootPart.Size = Vector3.new(2, 2, 2)
	rootPart.Anchored = false
	rootPart.CanCollide = true
	rootPart.CFrame = spawnCFrame
	rootPart.Parent = model
	model.PrimaryPart = rootPart
	local humanoid = Instance.new("Humanoid")
	humanoid.WalkSpeed = stats.Speed
	humanoid.Parent = model
	model:SetAttribute("UnitType", unitType)
	model:SetAttribute("Health", stats.Health)
	model:SetAttribute("Speed", stats.Speed)
	model:SetAttribute("AttackRange", stats.AttackRange)
	model:SetAttribute("Cost", stats.Cost)
	model:SetAttribute("ModelAssetId", stats.ModelAssetId)
	-- Attributes can't hold an Instance/Player reference directly, so ownership
	-- is tracked via UserId. UnitMovementService checks this before acting.
	model:SetAttribute("OwnerUserId", owner.UserId)
	local unitsFolder = workspace:WaitForChild("Units") :: Folder
	model.Parent = unitsFolder
	return model
end
return UnitFactory