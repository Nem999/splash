--[[
	// Description: Camera related functions that can be accessed from client and server.
]]

-- // Services
local PlayersService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- // Modules
local flags = require(script.Parent.flags)
local Frames = require(script.Parent.frames)

-- // Neutrals
local camera = {}
local LocalPlayer = PlayersService.LocalPlayer

-- // Functions

function camera:Rumble(Intensity : number)
	
	
	
	
	for counter_a = 30, 0, -1 do
		local x = math.random(-100,100)/100
		local y = math.random(-100,100)/100
		local z = math.random(-100,100)/100
		local character = LocalPlayer.Character
		local Torso = character:FindFirstChild("Torso")
		if not Torso then break end
		
		local CameraPart = Torso:FindFirstChild("CameraLock")
		if not CameraPart then break end
		CameraPart:FindFirstChildWhichIsA("Weld").C0 = CFrame.new(x,y,z)
		Frames.RenderStepped:Wait()
		
		if Torso and counter_a == 2 then

			local CameraPart = Torso:FindFirstChild("CameraLock")

			if CameraPart then

				local Weld = CameraPart:FindFirstChildWhichIsA("Weld")

				TweenService:Create(Weld, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {C0 = flags.GetFlag("PartCameraC0Offset")}):Play() -- Return it back to normal

			end
		end
		
	end
	
	local character = LocalPlayer.Character
	local Torso = character:FindFirstChild("Torso")
	
end

function camera:BobUpAndDown()
	local Total = 25
	
	
	
	for i = 1, Total do
		
		
		
		
		local height = math.sin(20 * os.clock()) * 0.25
		LocalPlayer.Character.Humanoid.CameraOffset = Vector3.new(LocalPlayer.Character.Humanoid.CameraOffset.X, LocalPlayer.Character.Humanoid.CameraOffset.Y + height, LocalPlayer.Character.Humanoid.CameraOffset.Z)
		
		RunService.RenderStepped:Wait()
		
	end
	
end


function camera.Subscribe()
	
end

-- //


return camera
