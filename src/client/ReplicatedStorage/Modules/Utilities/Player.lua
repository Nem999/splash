-- // Services
local PlayersService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- // Module

local Signal = ReplicatedStorage:WaitForChild("Signals"):WaitForChild("RemoteEvents"):WaitForChild("Player")

local Player = {}

Player.OnSignal = nil

local CheckPlayer = function(player)
	assert(player)
	
	if typeof(player) ~= "Instance" then
		error("Not a player.")
	end
	if not player:IsA("Player") then
		error("Not a player.")
	end
end

local IsControlsLocked = false
local IsMovementLocked = false

function Player:LockControls(player : Player)
	if RunService:IsClient() then
		if not Player:ControlsLocked() then
			RunService.Heartbeat:Wait()
			local LocalPlayer = PlayersService.LocalPlayer or player
			local PlayerModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
			local MainModule = require(LocalPlayer.PlayerScripts:WaitForChild("MainModule"))
			local Controls = PlayerModule:GetControls()
			local Backpack =  MainModule:GetBackpack()
			Controls:Disable()
			Backpack:Disable()
			IsControlsLocked = true
		end
	else
		CheckPlayer(player)
		Signal:FireClient(player, "Lock")
	end
end

function Player:UnlockControls(player : Player)
	if RunService:IsClient() then
		if Player:ControlsLocked() then
			RunService.Heartbeat:Wait()
			local LocalPlayer = PlayersService.LocalPlayer or player
			local PlayerModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
			local MainModule = require(LocalPlayer.PlayerScripts:WaitForChild("MainModule"))
			local Controls = PlayerModule:GetControls()
			local Backpack =  MainModule:GetBackpack()
			Controls:Enable()
			Backpack:Enable()
			IsControlsLocked = false
		end
	else
		CheckPlayer(player)
		Signal:FireClient(player, "Unlock")
	end
end

function Player:LockMovement(player : Player)
	if RunService:IsClient() then
		if not Player:IsMovementLocked() then
			local LocalPlayer = PlayersService.LocalPlayer or player
			local PlayerModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
			local Controls = PlayerModule:GetControls()
			Controls:Disable()
			IsMovementLocked = true
		end
	else
		CheckPlayer(player)
		Signal:FireClient(player, "StopMovement")
	end
end

function Player:UnlockMovement(player : Player)
	if RunService:IsClient() then
		if Player:IsMovementLocked() then
			local LocalPlayer = PlayersService.LocalPlayer or player
			local PlayerModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
			local Controls = PlayerModule:GetControls()
			Controls:Enable()
			print("movement called to unlock")
			IsMovementLocked = true
		end
	else
		CheckPlayer(player)
		Signal:FireClient(player, "Move")
	end
end

function Player:ControlsLocked()
	if RunService:IsClient() then
		return IsControlsLocked
	end
end

function Player:IsMovementLocked()
	if RunService:IsClient() then
		return IsMovementLocked
	end
end

function Player.Subscribe()
	if RunService:IsClient() then
		local LocalPlayer = PlayersService.LocalPlayer
		Player.OnSignal = Signal.OnClientEvent
		Signal.OnClientEvent:Connect(function(Intruction)
			if Intruction == "Lock" then
				Player:LockControls(LocalPlayer)
			elseif Intruction == "Unlock" then
				Player:UnlockControls(LocalPlayer)
			elseif Intruction == "StopMovement" then
				Player:LockMovement()
			elseif Intruction == "Move" then
				Player:UnlockMovement()
			end
		end)
	end
end

return Player
