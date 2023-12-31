-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService =  game:GetService("TweenService")

-- // Modules
local PlayerControls = require(ReplicatedStorage.Modules.Utilities.Player)
local g = require(ReplicatedStorage.Modules.Utilities.global)
local flags = require(ReplicatedStorage.Modules.Utilities.flags)
local vector = require(ReplicatedStorage.Modules.Utilities.vectorhelper)
local IsPlayerInAir = require(ReplicatedStorage.Modules.Utilities.IsPlayerOnAir)
local MatchStatus = require(ReplicatedStorage.Modules.Utilities.GetMatchStatus)

-- // Neutrals
local InstancesBeingTweened = {}
local DefaultFOV = flags.GetFlag("DefaultFOV")

-- // Functions

local function Tween(instance:Instance, Time :number?, EasingStyle:Enum.EasingStyle, EasingDirection:Enum.EasingDirection, Properity : {}, Queue : boolean)
	if Queue then
		while table.find(InstancesBeingTweened, instance) do task.wait() print("waiting around")  end -- If the instance is already being tweened
	end
	table.insert(InstancesBeingTweened, instance)
	local Tween = TweenService:Create(instance, TweenInfo.new(Time, EasingStyle, EasingDirection), Properity)
	task.delay(Time, function()
		table.remove(InstancesBeingTweened, table.find(InstancesBeingTweened, instance))
	end)
	Tween:Play()

	return Tween
end

local function SetFOV(boolean : boolean)
	if boolean then
		g:Tween(workspace.Camera, .7, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, {FieldOfView = DefaultFOV})
	else
		g:Tween(workspace.Camera, .7, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, {FieldOfView = DefaultFOV + 20})
	end
end

-- //

return function(CharacterBeingTracked : Model, Humanoid : Humanoid)
	
	local IsMoving = false
	local CurrentJob = false
	
	--return nil
	if flags.IsDebugServer() then
		local controlstatus = PlayerControls:IsMovementLocked()
		if controlstatus == true then controlstatus = "true" else controlstatus = "false" end
	--	flags:Log("Control status: " ..controlstatus, script)
	end
	
	if IsPlayerInAir:IsBasePartInAir(CharacterBeingTracked.Torso) then
		
		if IsMoving then
			
			Humanoid:MoveTo(Humanoid.Parent.HumanoidRootPart.Position)
			
			local Velocity = Humanoid.Parent.HumanoidRootPart:FindFirstChildWhichIsA("LinearVelocity")
			
			if Velocity then Velocity:Destroy() end
			
			for _, Descendant in ipairs(Humanoid.Parent:GetDescendants()) do
				if not (Descendant:IsA("BasePart")) then continue end
				Descendant.AssemblyLinearVelocity = Vector3.new()
				Descendant.AssemblyAngularVelocity = Vector3.new()
			end
			
			IsMoving = false
			PlayerControls:UnlockMovement()
			flags:Log("Stopping movement.", script)
			Humanoid.WalkSpeed = flags.GetFlag("bladeWalkSpeed")
			SetFOV(false)
			
			task.wait(1)
			CurrentJob = false
		end
		
		return
	end
	
	
	local HumanoidRootPart = CharacterBeingTracked:FindFirstChild("HumanoidRootPart")
	if not MatchStatus:IsRoundActive() then return end
	if not CharacterBeingTracked then return end
	if not HumanoidRootPart then return end
	if not vector:Compare(HumanoidRootPart, Humanoid.Parent.HumanoidRootPart, flags.GetFlag("WalkToMaxDistance")) then
	
		Humanoid:MoveTo(CharacterBeingTracked.HumanoidRootPart.Position)
		if CurrentJob then return end
		
		CurrentJob = true
		IsMoving = true
		PlayerControls:LockMovement()
		
		SetFOV(false)
		task.spawn(function()
		--	if IsMoving then return end
			while IsMoving do
				task.wait()
				if vector:Compare(HumanoidRootPart, Humanoid.Parent.HumanoidRootPart, flags.GetFlag("WalkToMaxDistance")) then
					if not HumanoidRootPart then
						IsMoving = false
					end
					
					Humanoid.WalkSpeed = flags.GetFlag("bladeWalkSpeed")
					IsMoving = false
					PlayerControls:UnlockMovement()
					SetFOV(true)
					CurrentJob = false
	
					Humanoid:MoveTo(Humanoid.Parent.HumanoidRootPart.Position)
					if not CharacterBeingTracked.Parent then 
						Humanoid:MoveTo(Humanoid.Parent.HumanoidRootPart.Position)
						
					end
				end
			end
		end)
		Humanoid.WalkSpeed = flags.GetFlag("bladeRunningSpeed")
	end
end
