-- [[ SERVICES ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- [[ MODULES ]]
local ani1 = require(script.PoleAnimations)
local Flags = require(ReplicatedStorage.Modules.Utilities.flags)

-- [[ VARAIBLES ]]
local Pole = workspace.Contents.Map.Pole

local IconicPole = {}

function LoadAnimations()
	
	if not Pole then repeat RunService.Heartbeat:Wait() until workspace.Contents.Map:FindFirstChild("Pole") end if not Pole then Pole = workspace.Contents.Map:FindFirstChild("Pole") end
	
	for _, Animation in pairs(ani1:GetAnimations()) do
		local Track : AnimationTrack = Pole:WaitForChild("AnimationController"):WaitForChild("Animator"):LoadAnimation(Animation.Animation)
		Track.Priority = Animation.Priority
		Animation.Track = Track
		Track.Name = Animation.Animation.Name
		Animation.Name = Animation.Animation.Name
		Animation.Track.Looped = Animation.Looped
	end

end

function ResetCamera()
	local Camera = workspace.CurrentCamera
	Camera.CameraType = Enum.CameraType.Custom
	Camera.FieldOfView = Flags.GetFlag("DefaultFOV")
end

task.spawn(LoadAnimations)

function IconicPole:PlayAnimation(Animation):AnimationTrack
	
	if not Pole then repeat RunService.Heartbeat:Wait() until workspace.Contents.Map:FindFirstChild("Pole") end if not Pole then Pole = workspace.Contents.Map:FindFirstChild("Pole") end

	local Animations = ani1:GetAnimations()

	if typeof(Animation) == "Instance" then
		Animation = Animation.Name
	end

	if Animations[Animation] then

		Animations[Animation].Track:Play(Animations[Animation].FadeTime)

		Animations[Animation].Track:AdjustSpeed(Animations[Animation].Speed)
		
		task.spawn(function()
			if Animations[Animation].Camera then
				local Tracking = Pole:WaitForChild("Camera")
				workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

				while Animations[Animation].Track.IsPlaying do
					RunService.RenderStepped:Wait()
					workspace.CurrentCamera.CFrame = Tracking.CFrame
				end
				
				if Animations[Animation].ResetWhenFinished then
					ResetCamera()
				end

			end
		end)

		return Animations[Animation]

	else
		Flags:Log("Non existant animation was called to play: "..Animation, script)
		warn('"'..Animation..'" is not a valid animation. Be sure it is added to the script called: '..script.PoleAnimations.Name)
	end
end


return IconicPole