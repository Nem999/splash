-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Neutrals
local ani2  = {}
local AnimationCache = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("ViewModel")
local Action4 = Enum.AnimationPriority.Action4
local Action3 = Enum.AnimationPriority.Action3
local Action2 = Enum.AnimationPriority.Action2
local Action = Enum.AnimationPriority.Action
local Idle = Enum.AnimationPriority.Idle

-- //

local Animations = {
	["test"] = {
		Animation = AnimationCache.test,
		Speed = 1,
		FadeTime = nil,
		Priority = Idle,
		tool = false,
		Name = "test",
	},
	["ViewModel_blade_Idle"] = {
		Animation = AnimationCache.ViewModel_blade_Idle,
		Speed = 1,
		FadeTime = 0,
		Priority = Idle,
		tool = true,
		Name = "ViewModel_blade_Idle",
	},
	["ViewModel_Blade_SwingLeft"] = {
		Animation = AnimationCache.ViewModel_Blade_SwingLeft,
		Speed = 1.2,
		FadeTime = 0,
		Priority = Action3,
		tool = true,
		Name = "ViewModel_Blade_SwingLeft",
	},
	["ViewModel_Blade_SwingRight"] = {
		Animation = AnimationCache.ViewModel_Blade_SwingRight,
		Speed = 1,
		FadeTime = 0,
		Priority = Action3,
		tool = true,
		Name = "ViewModel_Blade_SwingRight",
	}
}

function ani2:GetAnimations()
	return Animations
end

function ani2:GetAnimationTracks()
	local Tracks = {}
	
	for _, Animation in pairs(Animations) do
		if Animation["Track"] then
			table.insert(Tracks,  Animation["Track"])
		end
	end
	
	return Tracks
	
end

function ani2:GetAnimation(Track):Animation
	if typeof(Track) == "Instance" then Track = Track.Name end
	
	for _, Animation in pairs(Animations) do
		if Animation.Name == Track then
			return Animation
		end
	end
	
	warn('"'..Track..'" is not a valid animation track.')
	
	return nil
end

return ani2
	