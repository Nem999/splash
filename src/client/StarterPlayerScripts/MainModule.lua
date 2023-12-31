-- // Neutrals
local Main = {}
Main.__index = Main

-- // Functions

function Main.new()
	local self = setmetatable({}, Main)
	self.tilt = require(script:WaitForChild("CharacterTilt"))
	self.camera = require(script:WaitForChild("CameraController"))
	self.backpack = require(script:WaitForChild("backpack"))
	self.windcontroller = require(script:WaitForChild("WindController"))
	self.viewmodel = require(script:WaitForChild("ViewModel"))
	
	task.spawn(require, script:WaitForChild("BattleScript"))
	task.spawn(require, script:WaitForChild("subscribe"))
	
	return self
end

function Main:GetBackpack()
	return self.backpack
end

function Main:GetViewModel()
	return self.viewmodel
end

function Main:GetCameraController()
	return self.camera
end

function Main:GetWindController()
	return self.windcontroller
end

return Main.new()