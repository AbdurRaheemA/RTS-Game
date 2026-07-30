--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScreenRaycaster = require(ReplicatedStorage.Modules.ScreenRaycaster)
local player = Players.LocalPlayer
assert(player, "LocalPlayer is nil")
--// GUI SAFE BINDING (fixes race conditions)
local playerGui = player:WaitForChild("PlayerGui")
local rtsGui = playerGui:WaitForChild("RtsGui", 10)
if not rtsGui then
	error("RtsGui failed to load into PlayerGui")
end
local selectionBoxInstance = rtsGui:WaitForChild("SelectionBox", 10)
if not selectionBoxInstance then
	error("SelectionBox failed to load inside RtsGui")
end
local selectionBox = selectionBoxInstance :: Frame
--// REMOTES
local MoveUnit = ReplicatedStorage.Remotes:WaitForChild("MoveUnit") :: RemoteEvent
--// STATE
local dragging = false
local mouseDown = false
local dragStart = Vector2.zero
local DRAG_THRESHOLD = 5
local selectedUnit: Model? = nil
--// SINGLE UNIT SELECTION
local function selectUnit(screenPosition: Vector2)
	local result = ScreenRaycaster.raycast(screenPosition)
	if not result then
		selectedUnit = nil
		return
	end
	local model = result.Instance:FindFirstAncestorOfClass("Model")
	if not model or not model:GetAttribute("UnitType") then
		selectedUnit = nil
		return
	end
	selectedUnit = model
	print("Selected:", model.Name)
end
--// MOVE COMMAND
local function moveSelectedUnit(screenPosition: Vector2)
	if not selectedUnit then
		return
	end
	local result = ScreenRaycaster.raycast(screenPosition)
	if not result then
		return
	end
	MoveUnit:FireServer(selectedUnit, result.Position)
end
--// BOX UPDATE
local function updateSelectionBox(currentMouse: Vector2)
	local minX = math.min(dragStart.X, currentMouse.X)
	local minY = math.min(dragStart.Y, currentMouse.Y)
	local width = math.abs(currentMouse.X - dragStart.X)
	local height = math.abs(currentMouse.Y - dragStart.Y)
	selectionBox.Position = UDim2.fromOffset(minX, minY)
	selectionBox.Size = UDim2.fromOffset(width, height)
end
--// INPUT START
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		mouseDown = true
		dragging = false
		dragStart = UserInputService:GetMouseLocation()
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		moveSelectedUnit(UserInputService:GetMouseLocation())
	end
end)
--// INPUT MOVE
UserInputService.InputChanged:Connect(function(input)
	if not mouseDown then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end
	local mousePos = UserInputService:GetMouseLocation()
	if not dragging then
		if (mousePos - dragStart).Magnitude >= DRAG_THRESHOLD then
			dragging = true
			selectionBox.Visible = true
		else
			return
		end
	end
	updateSelectionBox(mousePos)
end)
--// INPUT END
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end
	local mousePos = UserInputService:GetMouseLocation()
	if dragging then
		selectionBox.Visible = false
	else
		selectUnit(mousePos)
	end
	mouseDown = false
	dragging = false
end)