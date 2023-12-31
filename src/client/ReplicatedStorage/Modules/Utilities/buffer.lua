--[[
	Description: This module is responsible for cleaning up parts where the code is not garanteed to be finished. (like if a script was deleted before an action could be completed.)
]]

-- // Services 
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- // Moudles
local Signal = require(script.Parent:WaitForChild("signal"))

-- // Neutrals
local rbxtostring = buffer.tostring
local rbxcreate = buffer.create
local rbxlen = buffer.len
local rbxcopy = buffer.copy
local rbxfill = buffer.fill
local rbxreadi8 = buffer.readi8
local rbxreadu8 = buffer.readu8
local rbxreadf32 = buffer.readf32
local rbxreadf64 = buffer.readf64
local rbxreadi16 = buffer.readi16
local rbxreadi32 = buffer.readi32



local buffer = {}

function buffer:AddInstance(instance : Instance, time : number?, Parent : Instance)
	Debris:AddItem(instance, time)
	if Parent then
		if instance then
			instance.Parent = Parent
		end
	else
		if instance then
			instance.Parent = workspace.Terrain
		end
	end
end

function buffer:DelayTask(Task : thread, time : number?) -- We need to execute it in a different script
	local function exe()
		if time then task.delay(time, Task) else
			task.spawn(Task)
		end
	end
	
	exe()
end


return buffer