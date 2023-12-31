local Blocker = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function Blocker:UpdateBlock(Direction : IntValue)
	--[[
	    0 = Not blocking
	    1 = Up
	    2 = Left
	    3 = Right
	    
	]]
	ReplicatedStorage.Signals.FightingRemotes.block:FireServer(Direction)
	
end

return Blocker