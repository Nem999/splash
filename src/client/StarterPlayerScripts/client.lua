-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local PlayersService = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

-- // Modules
local Buffer = require(ReplicatedStorage.Modules.Utilities.buffer)
local Flags = require(ReplicatedStorage.Modules.Utilities.flags)
local MainModule = require(script.Parent:WaitForChild("MainModule"))

-- // Neutrals
local LocalPlayer = PlayersService.LocalPlayer
local Character = LocalPlayer.Character
local TransparencyConnection

-- // Functions

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
if not RunService:IsStudio() then
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.SelfView, false)
end
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Captures, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

-- // Manage connections

LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
	Character = NewCharacter
end)

TransparencyConnection = RunService.RenderStepped:Connect(function()
	if Character then
		local Tool = Character:FindFirstChildWhichIsA("Tool")
		if Flags.GetFlag("ViewModelEnabled") then
		if Tool then
			for _, Part in pairs(Tool:GetDescendants()) do
				if Part:IsA("BasePart") then
					
					Part.LocalTransparencyModifier = 1
					end
				end
			end
		end
	end
end)

-- //