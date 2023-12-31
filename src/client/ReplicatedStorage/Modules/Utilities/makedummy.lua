-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterPlayer = game:GetService("StarterPlayer")
local ServerScriptService = game:GetService("ServerScriptService")

-- // Modules
local CharacterValues = require(ReplicatedStorage.Modules.Utilities.getcharactervalues)
local felloff = require(ReplicatedStorage.Modules.Utilities.IsPlayerOnAir)

-- //
local GetDummy = {}

function GetDummy.MakeDummy(rigType : Enum.HumanoidRigType)
	if rigType == Enum.HumanoidRigType.R6 then
		local D = ReplicatedStorage.Assets.R6:Clone()
		D.Name = ""
		return D
	elseif rigType == Enum.HumanoidRigType.R15 then
		local D = ReplicatedStorage.Assets.R15:Clone()
		D.Name = ""
		return D
	end
end

function GetDummy.ApplyScript(dummy)
	if typeof(dummy) ~= "Instance" then
		return nil
	end
	if not dummy:IsA("Model") then
		return nil
	end
	
	if not PlayersService:GetPlayerFromCharacter(dummy) then -- Make sure this is not a real player
		GetDummy.Run(dummy.Humanoid.RigType, dummy)
	end
end

local function CheckForDummyArea(Dummy)
	local b = RaycastParams.new()
	b.FilterDescendantsInstances = {Dummy}
	b.IgnoreWater = true
	b.FilterType = Enum.RaycastFilterType.Exclude

	if Dummy then
		if Dummy:FindFirstChild("Torso") then

			local PartDown = false
			local PartUp = false
			local PartRight = false
			local PartLeft = false

			for i, v in pairs(Dummy:GetChildren()) do
				if v:IsA("BasePart") then
					local Direction = Vector3.new(0,-1,0)
					local WorldDirection = v.CFrame:VectorToWorldSpace(Direction)
					local Raycast = workspace:Raycast(v.Position, WorldDirection, b)

					if Raycast then
						PartDown = true
						break
					end

					local Direction = 	Vector3.new(0,1,0)
					local WorldDirection = v.CFrame:VectorToWorldSpace(Direction)
					local Raycast = workspace:Raycast(v.Position, WorldDirection, b)

					if Raycast then
						PartUp = true
						break
					end

					local Direction = 	Vector3.new(1,0,0)
					local WorldDirection = v.CFrame:VectorToWorldSpace(Direction)
					local Raycast = workspace:Raycast(v.Position, WorldDirection, b)

					if Raycast then
						PartRight = true
						break
					end

					local Direction = 	Vector3.new(-1,0,0)
					local WorldDirection = v.CFrame:VectorToWorldSpace(Direction)
					local Raycast = workspace:Raycast(v.Position, WorldDirection, b)

					if Raycast then
						PartLeft = true
						break
					end
				end
			end
print(PartUp, PartDown, PartLeft, PartRight)
			if PartUp or PartDown or PartLeft or PartRight then
				print('going')
				task.delay(2, function()
					print(Dummy)
					Dummy:Destroy()
				end)
				for _, BasePart in pairs(Dummy:GetDescendants()) do

					if BasePart:IsA("BasePart") then
						local Animation = TweenService:Create(BasePart, TweenInfo.new(1.4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), { Transparency = 1})
						Animation:Play()

					end

				end



			end

		end
	end
end

function GetDummy.Run(rigType : Enum.HumanoidRigType, Dummy)
	local RagdollModule = require(ServerScriptService.Modules.Utilities.ragdoll)
	local idle = 180435571
	local Humanoid = Dummy:WaitForChild("Humanoid")
	local Animator = Humanoid:WaitForChild("Animator")
	
	task.spawn(function()
		while Humanoid do
			task.wait()
			Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			-- print(math.random(1,9))
		end
	end)
	
	
	if rigType == Enum.HumanoidRigType.R6 then
		
		
		for i,v in pairs(StarterPlayer.StarterCharacterScripts:GetChildren()) do
			local instance = v:Clone()
			if instance.Name == "Scripts" then
				for i,v in pairs(instance:GetChildren()) do
					if v.Name ~= "stun" then -- Keep the stun script
						v:Destroy()
					end
				end
			end
			instance.Parent = Dummy
		end
		
		
		
		local Animation = Instance.new("Animation")
		Animation.AnimationId = "rbxassetid://"..idle
		local newidle = Animator:LoadAnimation(Animation)
		newidle:Play()
		local dummy = felloff.new()
		dummy:SetCharacter(Dummy)
		local Connection
		Connection = dummy.OnPlayerFall:Connect(function()
		--	character.Parent = workspace.Contents.Live.Ragdolls
			local LastDirection = CharacterValues:ReadLastDirection(Dummy)
			RagdollModule:Ragdoll(Dummy, nil, LastDirection)
			Connection:Disconnect()
			dummy:Disconnect()
			
			task.delay(3, CheckForDummyArea, Dummy)
			
		end)

		Dummy.Head.Destroying:Once(function()
			task.wait()
			Dummy:Destroy()
		end)
	elseif rigType == Enum.HumanoidRigType.R15 then
		local RagdollModule = require(ServerScriptService.Modules.Utilities.ragdoll)
		


		for i,v in pairs(StarterPlayer.StarterCharacterScripts:GetChildren()) do
			local instance = v:Clone()
			if instance.Name == "Scripts" then
				for i,v in pairs(instance:GetChildren()) do
					if v.Name ~= "stun" then
						v:Destroy()
					end
				end
			end
			instance.Parent = Dummy
		end
		
		
		local Animation = Instance.new("Animation")
		Animation.AnimationId = "rbxassetid://"..idle
		local newidle = Animator:LoadAnimation(Animation)
		newidle:Play()

		local dummy = felloff.new()
		dummy:SetCharacter(Dummy)
		local Connection
		Connection = dummy.OnPlayerFall:Connect(function()
			Dummy.Parent = workspace.Contents.Live.Ragdolls
			local LastDirection = CharacterValues:ReadLastDirection(Dummy)
			RagdollModule:Ragdoll(Dummy, nil, LastDirection)
			Connection:Disconnect()
			dummy:Clear()
			
			task.delay(3, CheckForDummyArea, Dummy)
			
		end)

		Dummy.Head.Destroying:Once(function()
			task.wait()
			Dummy:Destroy()
		end)
	end
end


return GetDummy
