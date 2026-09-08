--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerSetupService = require(ServerScriptService.Services.PlayerSetupService)
local UnitMovementService = require(ServerScriptService.Services.UnitMovementService)
local UnitSpawnService = require(ServerScriptService.Services.UnitSpawnService)

PlayerSetupService.start()
UnitMovementService.start()
UnitSpawnService.start()