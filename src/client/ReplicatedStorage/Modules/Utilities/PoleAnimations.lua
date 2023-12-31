-- [[ SERVICES ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- [[ VARAIBLES ]]
local AniCache = ReplicatedStorage:WaitForChild("Animations")
local Action4 = Enum.AnimationPriority.Action4
local Action3 = Enum.AnimationPriority.Action3
local Action2 = Enum.AnimationPriority.Action2
local Action = Enum.AnimationPriority.Action
local Idle = Enum.AnimationPriority.Idle
local ani1 = {}

local Animations = {
	["Pole_Test"] = {
		Animation = AniCache.Pole_Test,
		Speed = 1,
		FadeTime = 0,
		Priority = Action,
		Camera = true,
		Looped = false,
		ResetWhenFinished = false
	},
	["PoleLook"] = {
		Animation = AniCache.PoleLook,
		Speed = 1,
		FadeTime = 0,
		Priority = Action,
		Camera = true,
		Looped = false,
		ResetWhenFinished = false
	},
	
	["MatchEndedAnim"] = {
		Animation = AniCache.MatchEndedAnim,
		Speed = 1,
		FadeTime = 0,
		Priority = Action,
		Camera = true,
		Looped = true,
		ResetWhenFinished = false
	}
}

function ani1:GetAnimations()
	return Animations
end

function ani1:GetAnimationTracks()
	local Tracks = {}

	for _, Animation in pairs(Animations) do
		if Animation["Track"] then
			table.insert(Tracks,  Animation["Track"])
		end
	end

	return Tracks

end

function ani1:GetPlayingAnimationTracks()
	local Pole = workspace:WaitForChild("Contents"):WaitForChild("Map"):WaitForChild("Pole")
	
	if not Pole then
		repeat RunService.Heartbeat:Wait() until workspace.Contents.Map:FindFirstChild("Pole")
		
		Pole = workspace.Contents.Map.Pole
		
	end
	
	local Animator = Pole:WaitForChild("AnimationController"):WaitForChild("Animator")
	
	return Animator:GetPlayingAnimationTracks()
	
end

function ani1:GetAnimation(Track):Animation
	if typeof(Track) == "Instance" then Track = Track.Name end

	for _, Animation in pairs(Animations) do
		if Animation.Name == Track then
			return Animation
		end
	end

	warn('"'..Track..'" is not a valid animation track.')

	return nil
end

return ani1