--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera") :: Camera

-- StarCraft 2 Aesthetic Constants
local CAMERA_ANGLE = 54.73
local RTS_FOV = 36
local MOVE_SPEED = 60
local ROTATION_SPEED = 100
local ZOOM_SPEED = 6
local MIN_ZOOM = 25
local MAX_ZOOM = 100

-- State Variables (Explicitly set slightly above your Y = -8 Baseplate height)
local cameraTarget = Vector3.new(0, -7, 0)
local currentZoom = 55
local currentRotation = 0

-- CRITICAL: Robustly lock down camera type and block character load overrides
local function enforceCameraSettings()
	camera.CameraType = Enum.CameraType.Scriptable
	camera.FieldOfView = RTS_FOV
end

enforceCameraSettings()
camera:GetPropertyChangedSignal("CameraType"):Connect(enforceCameraSettings)

-- Input Handling (Zoom)
UserInputService.InputChanged:Connect(function(inputObject: InputObject, gameProcessed: boolean)
	if gameProcessed then return end
	if inputObject.UserInputType == Enum.UserInputType.MouseWheel then
		currentZoom = math.clamp(currentZoom - (inputObject.Position.Z * ZOOM_SPEED), MIN_ZOOM, MAX_ZOOM)
	end
end)

-- Core Viewport Matrix Loop
local function updateCamera(deltaTime: number)
	-- Ensure Scriptable type is constantly asserted 
	if camera.CameraType ~= Enum.CameraType.Scriptable then 
		camera.CameraType = Enum.CameraType.Scriptable
		return 
	end

	-- Keyboard Rotation Processing (Q/E)
	if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
		currentRotation = (currentRotation + (ROTATION_SPEED * deltaTime)) % 360
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.E) then
		currentRotation = (currentRotation - (ROTATION_SPEED * deltaTime)) % 360
	end

	-- Calculate orientation vectors relative to the current rotation yaw
	local radRotation = math.rad(currentRotation)
	local forwardVector = Vector3.new(-math.sin(radRotation), 0, -math.cos(radRotation))
	local rightVector = Vector3.new(math.cos(radRotation), 0, -math.sin(radRotation))

	local moveDirection = Vector3.new(0, 0, 0)

	-- Keyboard Translation Controls
	if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then
		moveDirection += forwardVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then
		moveDirection -= forwardVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then
		moveDirection -= rightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then
		moveDirection += rightVector
	end

	-- Apply Delta Movement Vector
	if moveDirection.Magnitude > 0 then
		cameraTarget += moveDirection.Unit * MOVE_SPEED * deltaTime
	end

	-- Compute directional look transformation utilizing a fixed pitch CFrame offset
	local rotationCFrame = CFrame.Angles(0, math.rad(currentRotation), 0) * CFrame.Angles(math.rad(-CAMERA_ANGLE), 0, 0)
	local offsetVector = Vector3.new(0, 0, currentZoom)
	local cameraPosition = cameraTarget + (rotationCFrame * offsetVector)

	-- Lock final viewport position and orientation
	camera.CFrame = CFrame.lookAt(cameraPosition, cameraTarget)
end

RunService.RenderStepped:Connect(updateCamera)