--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerSetupService = require(ServerScriptService.Services.PlayerSetupService)
local UnitMovementService = require(ServerScriptService.Services.UnitMovementService)

PlayerSetupService.start()
UnitMovementService.start()