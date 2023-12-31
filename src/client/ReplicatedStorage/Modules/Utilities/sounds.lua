--[[
	Description: This module is responsible for playing sounds in and cleaning them up after they are finished being played.
]]

-- // Services
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Modules
local Buffer = require(script.Parent.buffer)
local pick = require(script.PickRandom)
local Tools = require(ReplicatedStorage.Modules.Utilities.tools)

-- // Neutrals
local sounds = {}

function sounds:GetSwingSounds(Tool)
	return Tools[Tool].Satistics.SwingSounds
end

function sounds:GenerateSwingSound(Tool)
	local PickedSound = pick(sounds:GetSwingSounds(Tool))
	return PickedSound
end

function sounds:GenerateSwingSoundAndPlay(Tool, parent)
	local picked = self:GenerateSwingSound(Tool)
	self:Play(picked, parent)
end

function sounds:Play(sound, parent, Time, ...)
	if typeof(sound) == "Instance" then
		local newSound = sound:Clone()
		Time = Time or sound.TimeLength
		newSound.Archivable = false
		if typeof(parent) ~= "Instance" then
			Buffer:AddInstance(newSound, Time)
		else
			Buffer:AddInstance(newSound, Time, parent)
		end
		
		local Modifiers = {...}
		
		for a,b in pairs(Modifiers) do
			if typeof(b) == "Instance" then
				b.Parent = newSound
			end
		end
		
		newSound:Play()
		return newSound
	else
		local newSound = Instance.new("Sound")
		newSound.SoundId = sound
		Time = Time or newSound.TimeLength
		newSound.Archivable = false
		
		if typeof(parent) ~= "Instance" then
			Buffer:AddInstance(newSound, Time)
		else
			Buffer:AddInstance(newSound, Time, parent)
		end
		
		local Modifiers = {...}
		
		for a,b in pairs(Modifiers) do
			if typeof(b) == "Instance" then
				b.Parent = newSound
			end
		end
		

		newSound:Play()
		return newSound
	end
	
end

return sounds