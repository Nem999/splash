-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- // Modules
local Flags = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utilities"):WaitForChild("flags"))
local Signal = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utilities"):WaitForChild("signal"))
local Buffer = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utilities"):WaitForChild("buffer"))

-- // Neutrals
local cam = {}
cam.__index = cam
local LocalPlayer = PlayersService.LocalPlayer
local Character = LocalPlayer.Character
local Humanoid
local Status

local function Bob(addition)
	return math.sin(tick() * addition * 0.8) * 0.2
end

local Turn = 0

local Lerp = function(a, b, t)
	return a + (b - a) * t
end;

-- // Functions

function cam:ChangeCharacter(character)
	Character = character 
end

function cam:ChangeCamera(camera)
	self.Camera = camera
	if LocalPlayer.Character then
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
	end
end

function cam:GetRollAngle()
	
	local Cf = workspace.CurrentCamera.CFrame
	
	return -Cf.RightVector:Dot(Humanoid.MoveDirection)
end

local rad = math.rad
local Rot = CFrame.new()

function cam:OnRenderStepped(DeltaTime)
	Character = Character or LocalPlayer.Character
	if not Character then return end
	if not Humanoid then return end
	if Humanoid.Parent ~= Character then return end
	if not Character:FindFirstChild("Head") then return end
	if Character.Head.Parent ~= Character then return end
	if not Character:FindFirstChild("HumanoidRootPart") then return end
	
	local Delta = UserInputService:GetMouseDelta()

	local Roll = self:GetRollAngle() * 2
	local newroll = math.clamp(Roll, -20, 20)
	Rot = Rot:Lerp(CFrame.Angles(0, 0, rad(newroll)),0.075)

	Turn = Lerp(Turn, math.clamp(Delta.X, -4, 3), math.clamp((15 * DeltaTime), 0.18, 0.29))
	workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.Angles(0, 0, math.rad(Turn))
	
	Humanoid.CameraOffset = (Character.HumanoidRootPart.CFrame + Vector3.new(0, 1.5, 0)):PointToObjectSpace(Character.Head.Position + Flags.GetFlag("PartCameraC0Offset"))

	workspace.CurrentCamera.CFrame *= Rot	
end

function RenderStepped(DeltaTime)
	cam:OnRenderStepped(DeltaTime)
end

function cam.init()
	
	local self = setmetatable({}, cam)
	
	self.OnCameraChange = Signal.new()
	
	local TotalDelta = 0
	
	LocalPlayer.CharacterAdded:Connect(function(char)
		self:ChangeCharacter(char)
		Humanoid = char:WaitForChild("Humanoid")
	end)
	
	task.spawn(function()
		if Character then
			Humanoid = Character:WaitForChild("Humanoid")
		end
	end)
	
	cam.Status = true
	
	RunService:BindToRenderStep("TiltCamera", Enum.RenderPriority.Camera.Value + 2, RenderStepped)
	return self

end

function cam:PauseTiltingFeature()
	Status = false
	RunService:UnbindFromRenderStep("TiltCamera")
end

function cam:ResumeTiltingFeature()
	
	if Status == true then warn("The tilting feature is currently enabled.") return end
	
	local Rot = CFrame.new()
	local rad = math.rad

	Status = true
	
	RunService:BindToRenderStep("TiltCamera", Enum.RenderPriority.Camera.Value + 2, RenderStepped)
end

function cam:IsTiltingFeatureEnabled()
	return Status
end

-- // 

if not LocalPlayer then -- Fix local player
	PlayersService:GetPropertyChangedSignal("LocalPlayer"):Wait()
	LocalPlayer = PlayersService.LocalPlayer
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	
	Flags:Log("Camera was weirdly changed or deleted.", script)
	warn("Camera changed!")
	
	local NewCamera = workspace.CurrentCamera
	cam:ChangeCamera(NewCamera)
end)



return cam.init()