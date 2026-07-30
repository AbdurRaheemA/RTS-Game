--!strict

export type UnitStats = {
	Health: number,
	Speed: number,
	AttackRange: number,
	Cost: number,
	ModelAssetId: string,
}

export type UnitDictionary = {
	[string]: UnitStats,
}

local unitData: UnitDictionary = {
	Swordsman = {
		Health = 100,
		Speed = 16,
		AttackRange = 5,
		Cost = 100,
		ModelAssetId = "rbxassetid://0",
	},

	Archer = {
		Health = 75,
		Speed = 14,
		AttackRange = 25,
		Cost = 150,
		ModelAssetId = "rbxassetid://0",
	},
}

local function validateUnit(name: string, stats: UnitStats)
	assert(stats.Health > 0, `${name}: Health must be greater than 0`)
	assert(stats.Speed >= 0, `${name}: Speed cannot be negative`)
	assert(stats.AttackRange >= 0, `${name}: AttackRange cannot be negative`)
	assert(stats.Cost >= 0, `${name}: Cost cannot be negative`)
	assert(stats.ModelAssetId ~= "", `${name}: ModelAssetId is empty`)
end

for name, stats in pairs(unitData) do
	validateUnit(name, stats)
	table.freeze(stats)
end

table.freeze(unitData)

return unitData