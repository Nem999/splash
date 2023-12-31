-- // Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")

-- // Modules
local Flags = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utilities"):WaitForChild("flags"))
local Signal = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utilities"):WaitForChild("signal"))

-- // Neutrals 
local Tilting = {}
local LocalPlayer = PlayersService.LocalPlayer
local OnCharacterChange = Signal.new()
local Remote = ReplicatedStorage:WaitForChild("Signals"):WaitForChild("RemoteEvents"):WaitForChild("EffectsRemotes"):WaitForChild("updcharacter")
local Character

-- // Functions

function ChangeCharacter(character)
	Character = character -- wow
	OnCharacterChange:Fire(character)
end


function Tilting.init()

	-- Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()



	local Humanoid : Humanoid
	local RootPart
	local RootJoint : Motor6D
	local RootC0 

	OnCharacterChange:Connect(function(char)
		RootC0 = CFrame.new() * CFrame.fromOrientation(math.rad(-90), math.rad(-180), math.rad(0))
		Humanoid = char:WaitForChild("Humanoid")
		RootPart = char:WaitForChild("HumanoidRootPart")
		RootJoint = RootPart:WaitForChild("RootJoint")
	end)

	Remote.OnClientEvent:Connect(function(Target, CFram)
		if Target then
			Target.C0 = CFram
		end
	end)


	--if not Character then LocalPlayer:GetPropertyChangedSignal("Character"):Wait() end
	-- if not Humanoid then Character:WaitForChild("Humanoid") end


	local MaxTiltAngle = 10

	local Tilt = CFrame.new()
	local LastReset = false


	RunService:BindToRenderStep("TiltCharacter", 1, function(Delta)

		if not RootPart then return end
		if not Humanoid then return end
		if not RootJoint then return end
		if not RootC0 then return end

		local MoveDirection = RootPart.CFrame:VectorToObjectSpace(Humanoid.MoveDirection)
		
		Tilt = Tilt:Lerp(CFrame.Angles(math.rad(-MoveDirection.Z) * MaxTiltAngle, math.rad(-MoveDirection.X) * MaxTiltAngle, 0), (0.002 / Delta) ^ (1 / (Delta * 60)))
		RootJoint.C0 = RootC0 * Tilt

		if Flags.GetFlag("CharacterTiltUpdateOnOtherClients") then
			Remote:FireServer(RootC0 * Tilt)
		end


	end)

	return Tilting

end	

-- // 

if not LocalPlayer then -- Fix local player
	PlayersService:GetPropertyChangedSignal("LocalPlayer"):Wait()
	LocalPlayer = PlayersService.LocalPlayer
end

LocalPlayer.CharacterAdded:Connect(ChangeCharacter)


return Tilting.init()