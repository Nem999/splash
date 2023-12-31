-- // Services
local PlayersService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- //
return function(NearestPlayer, HumanoidRootPart)
	task.spawn(function() -- FOR DUMMIES
		task.wait()
		local Player = PlayersService:GetPlayerFromCharacter(NearestPlayer)

		if not Player then
			local Object = NearestPlayer:FindFirstChildWhichIsA("ObjectValue")
			if not Object then
				local vector = require(ReplicatedStorage.Modules.Utilities.vectorhelper)
				if not NearestPlayer:FindFirstChild("HumanoidRootPart") then return end
				if not HumanoidRootPart then return end
				if vector:Compare(HumanoidRootPart, NearestPlayer.HumanoidRootPart, 50) then
					ReplicatedStorage.Signals.FightingRemotes.REQUEST_NETWORK_OWNERSHIP:FireServer(NearestPlayer.HumanoidRootPart)
				end
			else
				if Object.Value == nil then
					local vector = require(ReplicatedStorage.Modules.Utilities.vectorhelper)
					if not NearestPlayer:FindFirstChild("HumanoidRootPart") then return end
					if vector:Compare(HumanoidRootPart, NearestPlayer.HumanoidRootPart, 50) then
						ReplicatedStorage.Signals.FightingRemotes.REQUEST_NETWORK_OWNERSHIP:FireServer(NearestPlayer.HumanoidRootPart)

					end
				end
			end
		end
	end)
end