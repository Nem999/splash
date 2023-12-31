-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- // Modules
local Flags = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utilities"):WaitForChild("flags"))
local Signal = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utilities"):WaitForChild("signal"))
local Spring = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utilities"):WaitForChild("spring"))
local ani2 = require(script:WaitForChild("ViewModelAnimationTypes"))

-- // Neutrals
local GetPlayerAppearanceInfo = ReplicatedStorage:WaitForChild("Signals"):WaitForChild("RemoteFunctions"):WaitForChild("GetPlayerAppearanceInfo")
local LocalPlayer = PlayersService.LocalPlayer
local CurrentViewModel = nil
local CurrentBlade = nil
local Appearence = nil
local Enabled
local BladeVisibilityStatus = true
local EmptyString = ""
local CurrentlyPlayingAnimations = {}
local Character = LocalPlayer.Character
local m6d
local BackupDescription = {
	["BodyColorHead"] = 226,
	["BodyColorLeftArm"] = 226,
	["BodyColorRightArm"] = 226,
	["BodyColorTorso"] = 28,
	["BodyColorLeftLeg"] = 23,
	["BodyColorRightLeg"] = 23,
	["ShirtId"] = nil,
	["PantsId"] = nil,
	["TorsoMeshId"] = nil,
	["LeftArmMeshId"] = nil,
	["RightArmMeshId"] = nil,
	["LeftLegMeshId"] = nil,
	["RightLegMeshId"] = nil
}

-- // Springs
local Bobbing = Spring.new()
local Swaying = Spring.new()

-- // ViewModel variables
local ViewModel = {}
ViewModel.__index = ViewModel

-- // Functions

function LoadAnimations()
	for _, Animation in pairs(ani2:GetAnimations()) do
		local Track : AnimationTrack = CurrentViewModel.Humanoid.Animator:LoadAnimation(Animation.Animation)
		Track.Priority = Animation.Priority
		Animation.Track = Track
		Track.Name = Animation.Name
	end
end

function ViewModel.init()

	if not LocalPlayer then -- Fix local player
		PlayersService:GetPropertyChangedSignal("LocalPlayer"):Wait()
		LocalPlayer = PlayersService.LocalPlayer
	end

	local self = setmetatable({}, ViewModel)

	if not Flags.GetFlag("ViewModelEnabled") then return self end
	
	if not CurrentViewModel then
		self:ContructViewModel()
	end

	return ViewModel

end

function ChangeCharacter(character)
	local c = Character
	Character = character
	if c then
		ViewModel:ContructViewModel()
	end
end

function ViewModel:ContructViewModel()

	if not Flags.GetFlag("ViewModelEnabled") then return end

	if CurrentViewModel then
		-- Going to attempt to get humanoiddescription

		local Success, Description = pcall(PlayersService.GetHumanoidDescriptionFromUserId, PlayersService, LocalPlayer.UserId)

		if Success then

			Description.HatAccessory = EmptyString
			Description.HairAccessory = EmptyString
			Description.BackAccessory = EmptyString
			Description.FaceAccessory = EmptyString
			Description.FrontAccessory = EmptyString
			Description.NeckAccessory = EmptyString
			Description.HatAccessory = EmptyString
			Description.ShouldersAccessory = EmptyString
			Description.WaistAccessory = EmptyString
			
			
			CurrentViewModel.Humanoid:ApplyDescriptionReset(Description)	
		end

		if not Success then
			Flags:Log("HumanoidDescription could not be applied onto ViewModel", script)
			warn("HumanoidDescription could not be applied onto ViewModel.")
			
			CurrentViewModel["Body Colors"].LeftArmColor = BrickColor.new(Appearence.BodyColorLeftArm)
			CurrentViewModel["Body Colors"].RightArmColor = BrickColor.new(Appearence.BodyColorRightArm)
			
		end
		
		if BladeVisibilityStatus then
			self:EnableBladeVisibility()
		else
			self:DisableBladeVisibility()
		end

		self:Enable()

	else
		CurrentViewModel = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("ViewModel"):Clone()

		self:Enable()

		------------------------ APPEARENCE

		local Success, Fail = pcall(function() -- GetCharacterAppearanceInfoAsync isn't always guaranteed to work especially if roblox.com is having issues.
			Appearence = GetPlayerAppearanceInfo:InvokeServer()
		end)

		if not Success and Fail then
			Flags:Log("Appearence could not be applied onto ViewModel because: "..Fail, script)
			warn("Appearence could not be applied onto ViewModel because: "..Fail)
		end

		if Success then
			-- Arms
			CurrentViewModel["Body Colors"].LeftArmColor = BrickColor.new(Appearence.BodyColorLeftArm)
			CurrentViewModel["Body Colors"].RightArmColor = BrickColor.new(Appearence.BodyColorRightArm)

			-- CharacterMeshes

			if Appearence.LeftArmMeshId then
				local CharacterMesh = Instance.new("CharacterMesh")
				CharacterMesh.BodyPart = Enum.BodyPart.LeftArm
				CharacterMesh.MeshId = Appearence.LeftArmMeshId 

				CharacterMesh.Parent = CurrentViewModel
			end

			if Appearence.RightArmMeshId  then
				local CharacterMesh = Instance.new("CharacterMesh")
				CharacterMesh.BodyPart = Enum.BodyPart.RightArm
				CharacterMesh.MeshId = Appearence.RightArmMeshId 

				CharacterMesh.Parent = CurrentViewModel
			end

			-- Shirt

			if Appearence.ShirtId then
				CurrentViewModel.Shirt.ShirtTemplate = Appearence.ShirtId
			end

		end

		------------------------ POSITIONING

		CurrentViewModel.Parent = workspace.CurrentCamera
		

		local function Bob(addition)
			return math.sin(tick() * addition * 0.8) * 0.2
		end

		local Turn = 0

		local Lerp = function(a, b, t)
			return a + (b - a) * t
		end;

		LoadAnimations()

		if #CurrentlyPlayingAnimations ~= 0 then
			for _, Track in pairs(CurrentlyPlayingAnimations) do
				local track = self:PlayAnimation(Track.Name)

			end
		end 

		

		local TotalDT = 0

		task.spawn(function()
			if not Character then LocalPlayer.CharacterAdded:Wait() RunService.Heartbeat:Wait() end
			
			RunService:BindToRenderStep("UpdateViewModel", Enum.RenderPriority.Camera.Value + 25, function(DeltaTime)
				if not Enabled then return end
				if not Character then self:Disable() return end
				if not Character:IsDescendantOf(workspace) then return self:Disable() end

				local Delta = UserInputService:GetMouseDelta()
				
				--print((15 * DeltaTime))
				Turn = Lerp(Turn, math.clamp(Delta.X, -4, 3), (15 * DeltaTime))
				
				-- Shoving
				Swaying:shove(Vector3.new(Delta.X /400, -Delta.Y/400, 0))
				Bobbing:shove(Vector3.new(Bob(5), Bob(10), Bob(5)) / 10 * (Character.PrimaryPart.Velocity.Magnitude) / 5)

				-- Updating springs
				local newdelt = math.clamp(DeltaTime, 0.014, 0.019)
				local UpdatedSway = Swaying:update(DeltaTime)
				local UpdatedBob = Bobbing:update(newdelt)
				
				-- Applying springs
				CurrentViewModel:PivotTo(
					workspace.CurrentCamera.CFrame *
						( CFrame.new(UpdatedSway.X, UpdatedSway.Y, 0) *
							CFrame.new(UpdatedBob.X, UpdatedBob.Y, math.rad(Turn * 3)))
				) 	

			end)
		end)

	end
end

function ViewModel:Disable()
	if not CurrentViewModel then warn("Not disabling ViewModel because there is no current ViewModel.") end
	Enabled = false
	self:DisableBladeVisibility()
	self:StopAllAnimations()
	CurrentViewModel.Parent = ReplicatedStorage
end

function ViewModel:Enable()
	if not CurrentViewModel then warn("Not enabling ViewModel because there is no current ViewModel.") end
	Enabled = true
	CurrentViewModel.Parent = workspace.CurrentCamera
end

function ViewModel:CreateWeldedBlade()
	local blade = ReplicatedStorage.Assets.blade:Clone()

	CurrentBlade = blade

	blade:ScaleTo(Flags.GetFlag("ViewModelbladeScale"))

	for _, BasePart in pairs(blade:GetDescendants()) do
		if BasePart:IsA("BasePart") then
			BasePart.CanCollide = false
			BasePart.CanQuery = false
			BasePart.CastShadow = false
			BasePart.CanTouch = false
			BasePart.LocalTransparencyModifier = 1
		end
	end
	
	if m6d then m6d:Destroy() end
	m6d = Instance.new("Motor6D") -- Create new Motor6D
	m6d.Name = "RightGrip"
	m6d.Part0 = CurrentViewModel:FindFirstChild("Right Arm")
	m6d.Part1 = blade:FindFirstChild("Handle")
	m6d.C0 = CFrame.new(0,-1,0) * CFrame.Angles(math.rad(-90), 0, 0)
	m6d.C1 = CFrame.new()
	m6d.Parent = CurrentViewModel:FindFirstChild("Right Arm")

	if BladeVisibilityStatus then
		self:EnableBladeVisibility()
	else
		self:DisableBladeVisibility()
	end
	
	blade.Parent = CurrentViewModel

end

function ViewModel:DeleteCurrentViewModelBlade()
	if CurrentViewModel then
		local Grip = CurrentViewModel.Camera:FindFirstChild("Grip")
		if Grip then Grip:Destroy() end

		local blade = CurrentViewModel:FindFirstChild("blade")
		if blade then blade:Destroy() end
		CurrentBlade = nil
	end
end

function ViewModel:EnableBladeVisibility()
	BladeVisibilityStatus = true
	if CurrentBlade then
		for _, BasePart in pairs(CurrentBlade:GetDescendants()) do
			if BasePart:IsA("BasePart") then
				BasePart.LocalTransparencyModifier = 0
			end
		end

	end
end

function ViewModel:DisableBladeVisibility()
	BladeVisibilityStatus = false
	if CurrentBlade then
		for _, BasePart in pairs(CurrentBlade:GetDescendants()) do
			if BasePart:IsA("BasePart") then
				BasePart.LocalTransparencyModifier = 1
			end
		end

	end
end

function ViewModel:GetBladeVisibilityState()
	return BladeVisibilityStatus
end

function ViewModel:DeleteCurrentViewModel()
	if CurrentViewModel then
		CurrentViewModel:Destroy()
		CurrentViewModel = nil
	end
end

function ViewModel:PlayAnimation(Animation):{AnimationTrack}
	if not CurrentViewModel then warn("Not playing animation because there is no current ViewModel.") return end

	local Animations = ani2:GetAnimations()

	if typeof(Animation) == "Instance" then
		Animation = Animation.Name
	end

	if Animations[Animation] then
	

		if Animations[Animation].tool and not CurrentBlade then	
			self:CreateWeldedBlade()
		end

		Animations[Animation].Track:Play(Animations[Animation].FadeTime)

		Animations[Animation].Track:AdjustSpeed(Animations[Animation].Speed)

		table.insert(CurrentlyPlayingAnimations,  Animations[Animation]) -- Insert it in the animations table
		
		return Animations[Animation]

	else
		Flags:Log("Non existant animation was called to play: "..Animation, script)
		warn('"'..Animation..'" is not a valid animation. Be sure it is added to the script called: '..script.ViewModelAnimationTypes.Name)
	end

end

function ViewModel:GetViewModel()
	return CurrentViewModel
end

function ViewModel:GetBlade()
	return CurrentBlade
end

function ViewModel:GetAnimation(Track)
	return ani2:GetAnimation(Track)
end

function ViewModel:StopAnimation(Animation):{AnimationTrack}
	if not CurrentViewModel then warn("Not stopping animation because there is no current ViewModel.") return end

	local Animations = ani2:GetAnimations()

	if typeof(Animation) == "Instance" then
		Animation = Animation.Name
	end

	if Animations[Animation] then
		Animations[Animation].Track:Stop(Animations[Animation].FadeTime)

		if table.find(CurrentlyPlayingAnimations, Animations[Animation]) then
			table.remove(CurrentlyPlayingAnimations, table.find(CurrentlyPlayingAnimations, Animations[Animation])) -- Remove it from our table
		end

		return Animations[Animation]
	else
		Flags:Log("Non existant animation was called to stop: "..Animation, script)
		warn('"'..Animation..'" is not a valid animation. Be sure it is added to the script called: '..script.ViewModelAnimationTypes.Name)
	end

end

function ViewModel:StopAllAnimations() -- This will make the ViewModel look lifeless.
	local Animations = ani2:GetAnimations()

	for _, Animation in pairs(Animations) do
		self:StopAnimation(Animation.Name)
	end

end

-- //

LocalPlayer.CharacterAdded:Connect(ChangeCharacter)

return ViewModel.init()