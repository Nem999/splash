--- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")

 -- // Neutrals
local Sounds = ReplicatedStorage.Audio.Sounds
local Animations = ReplicatedStorage:WaitForChild("Animations")

local SwingPriority = Enum.AnimationPriority.Action4
local Action3 = Enum.AnimationPriority.Action3
local Action2 =  Enum.AnimationPriority.Action2
local Action = Enum.AnimationPriority.Action
local Idle = Enum.AnimationPriority.Idle


-- // Functions
function FindTrailCosmetic(player : Player, name)
	if RunService:IsClient() then
		local LocalPlayer = PlayersService.LocalPlayer or player
		local Trails = {}
		if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end
		for i,blade in pairs(LocalPlayer.Character:GetChildren()) do
			if blade:IsA("Tool") and blade.Name == name then
				for i,v in pairs(blade:GetDescendants()) do
					if v:IsA("Trail") then
						table.insert(Trails, v)
					end
				end
			end
		end

		for i,blade in pairs(LocalPlayer.Backpack:GetChildren()) do
			if blade:IsA("Tool") and blade.Name == name then
				for i,v in pairs(blade:GetDescendants()) do
					if v:IsA("Trail") then
						table.insert(Trails, v)
					end
				end
			end
		end

		return Trails
	end
end

--[[
	Note: Generally the more time you use the lower you'll need the knockback to be
]]
	
local tools = {
	["blade"] = {
		Name = "blade",
		["Satistics"] = {
			Knockback = 230, -- The force of the knockback
			KnockbackTime = .5, -- How long the vector force will be added to the character until it gets deleted.
			VFX = "BladeHit", -- This is temp
			VFXBlock = "BladeBlock",
			VFXSpecial0 = "BladeSwing",
			VFXSpecial1 = "BladeTrail",
			HitSound = ReplicatedStorage.Audio.Sounds.bladeHitSuccess,
			SwingSounds = {
				Sounds.bladeAttack,
				
			}
		},
		
		["Data"] = {
			["Right"] = {
				Attack = {
					Anim = Animations.blade_swing_right,
					Name = "SwingRight",
					Speed = 1,
					FadeTime = nil,
					Priority = SwingPriority,
					Weight = nil,
				},
				Block = {
					Anim = Animations.blade_blocking_right,
					Name = "BlockingRight",
					Speed = .7,
					FadeTime = .2,
					Priority = Action3,
					Weight = nil,
				},
				PrepTime = .3,
				PrepSpeed = 1.3,
				RaycastLength = .3,
				RaycastLengthSpeed = 1.1,
				EndTime = 1,
			},
			["Left"] = {
				Attack = {
					Anim = Animations.blade_swing_left,
					Name = "SwingLeft",
					Speed = 1,
					FadeTime = 0,
					Priority = SwingPriority,
					Weight = nil,
				},
				Block = {
					Anim =  Animations.blade_blocking_left,
					Name = "BlockingLeft",
					Speed = .7,
					FadeTime = .2,
					Priority = Action3,
					Weight = nil,
				},
				PrepTime = .3,
				PrepSpeed = 1.6,
				RaycastLength = .3,
				RaycastLengthSpeed = 1,
				EndTime = 1,
			},
			["Up"] = {
				Attack = {
					Anim = Animations.blade_swing_up,
					Name = "SwingUp",
					Speed = 1,
					FadeTime = nil,
					Priority = SwingPriority,
					Weight = nil,
				},
				Block = {
					Anim = Animations.blade_blocking_up,
					Name = "BlockingUp",
					Speed = .7,
					FadeTime = .2,
					Priority = Action3,
					Weight = nil,
				},
				PrepTime = .2,
				PrepSpeed = 1,
				RaycastLength = .3,
				RaycastLengthSpeed = 1,
				EndTime = 1,
			},
			["idle"] = {
				idle = {
					Anim = Animations.blade_Idle,
					Name = "idle",
					Speed = 1,
					FadeTime = nil,
					Priority = Action,
					Weight = nil,
				},
				idle1 = {
					Anim = Animations.blade_Idle_1,
					Name = "idle1",
					FadeTime =  nil,
					Priority = Action2,
					Weight = nil,
				}
			}
		},
		["Cosmetics"] = {
			Trail = FindTrailCosmetic(PlayersService.LocalPlayer, "blade")
		}
	}
}



return tools
