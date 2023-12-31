--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterPlayer = game:GetService("StarterPlayer")
local Debris = game:GetService("Debris")

local Frames = require(ReplicatedStorage.Modules.Utilities.frames) -- Frame Data

local blade = {}
local Script = script

function blade:Run(script)	
	local self = require(Script.this)

	self.new()

	--// Player Variables
	local LocalPlayer = Players.LocalPlayer
	local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local Humanoid : Humanoid = Character:WaitForChild("Humanoid") -- Do not use the Humanoid to load animations! It's deprecated!
	self.Animator = Humanoid:WaitForChild("Animator")
	local Camera = workspace.CurrentCamera
	local RootPart = Character:WaitForChild("HumanoidRootPart")

	--// Modules needed
	local RaycastHitboxV4 = require(ReplicatedStorage.Modules.FightingModules.RaycastHitboxV4) -- Raycasts
	local Tools = require(ReplicatedStorage.Modules.Utilities.tools) -- Tool Data
	local env = require(ReplicatedStorage.Modules.Utilities.flags) -- Flags
	local SoundController = require(ReplicatedStorage.Modules.Utilities.sounds)
	local CharVals = require(ReplicatedStorage.Modules.Utilities.getcharactervalues)
	local Sounds = require(ReplicatedStorage.Modules.Utilities.sounds)
	local Player = require(ReplicatedStorage.Modules.Utilities.Player)
	local Buffer = require(ReplicatedStorage.Modules.Utilities.buffer)
	local VFX = require(ReplicatedStorage.Modules.FightingModules.Effects.vfx)
	local Walk = require(Script.WalkToPlayer)
	local TakeNetworkOwner = require(Script.TakeNetworkOwnership)
	local InitViewModel = require(Script.InitViewModel)

	--// Neutral Variables
	local CharacterValues = Character:WaitForChild("CharacterValues")
	local CharRemotes = Character:WaitForChild("Remotes")
	local Debounce = CharacterValues:WaitForChild("OnCooldown")
	local Tracking
	local PreviouslyTracking
	local ToolIsEquipped = false

	if not script.Parent then repeat RunService.Heartbeat:Wait() until script.Parent end

	local Tool:Tool = script.Parent
	
	self.IsSwinging = false
	Debounce.Value = false

	workspace.CurrentCamera.FieldOfView = env.GetFlag("DefaultFOV")

	--// Connection Variables
	local FIND_NEAREST_NPC_OR_PLAYER
	local RemoteEvent = Tool:WaitForChild("RemoteEvent")

	--// Everything else

	local this = {}

	local TestAnimation = ReplicatedStorage.Animations.test

	local track
	local Success, fail
	local function TryHaltingScriptUntilAnimationLoads()

		RunService.Heartbeat:Wait()

		Success, fail = pcall(function()
			track = self.Animator:LoadAnimation(TestAnimation)
		end)

		if not Success then
			env:Log("Animation load was not successful.")
			Character = LocalPlayer.Character
			if Character then
				Humanoid = Character:FindFirstChild("Humanoid")

				if Humanoid then
					self.Animator = Humanoid:FindFirstChild("Animator")
				end

			end
		else
			Character = LocalPlayer.Character
			Humanoid = Character:WaitForChild("Humanoid")
			self.Animator = Humanoid:WaitForChild("Animator")
		end
	end

	repeat TryHaltingScriptUntilAnimationLoads() until track
	
	if track then
		track:Destroy()
	end
	track = nil


	Humanoid.JumpPower = 0
	Humanoid.JumpHeight = 0
	Humanoid.WalkSpeed = env.GetFlag("bladeWalkSpeed")



	local function TweenPlay(instance:Instance, Time, EasingStyle:Enum.EasingStyle, EasingDirection:Enum.EasingDirection, Properity)
		TweenService:Create(instance, TweenInfo.new(Time, EasingStyle, EasingDirection), Properity):Play()
	end

	local function ToggleTransparency(boolean)
		if boolean and env.GetFlag("UsebladeCharacterTransparencyFeature") then
			for _, Part in pairs(LocalPlayer.Character:GetDescendants()) do
				if Part:IsA("Part") and Part.Parent:IsA("Accessory") then -- Only apply on accessories
					TweenService:Create(Part, TweenInfo.new(.3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {LocalTransparencyModifier = 0.9}):Play()
				elseif Part:IsA("Part") and Part.Parent:IsA("Model") and Part.Name ~= "HumanoidRootPart" then -- Only apply on parts that aren't the humanoidRootpart
					TweenService:Create(Part, TweenInfo.new(.3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {LocalTransparencyModifier = 0.9}):Play()
				end
			end
		else	
			for _, Part in pairs(LocalPlayer.Character:GetDescendants()) do
				if Part:IsA("BasePart") then
					Part.LocalTransparencyModifier = 0 -- Toggle the transparency
				end
			end
		end
	end

	local function TweenFOV(boolean)
		if boolean and env.GetFlag("UsebladeCameraZoomFeature") then
			TweenService:Create(Camera, TweenInfo.new(.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {FieldOfView = env.GetFlag("DefaultFOV") + 10}):Play()
		else
			TweenService:Create(Camera, TweenInfo.new(.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {FieldOfView = env.GetFlag("DefaultFOV")}):Play()
		end
	end

	local function ToggleCameraState(boolean)
		if boolean and env.GetFlag("UsebladeCameraZoomFeature") then
			if not env.GetFlag("LockFirstPerson") then
				LocalPlayer.CameraMinZoomDistance = 4
				LocalPlayer.CameraMaxZoomDistance = 40
				TweenService:Create(LocalPlayer, TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CameraMaxZoomDistance = 12}):Play()
			end
		else
			if not env.GetFlag("LockFirstPerson") then
				TweenService:Create(LocalPlayer, TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CameraMaxZoomDistance = StarterPlayer.CameraMaxZoomDistance}):Play()
				LocalPlayer.CameraMinZoomDistance = StarterPlayer.CameraMinZoomDistance
			end
		end
	end
	local function RemoveTrackingGui(character)
		if character then
			if not character:FindFirstChild("Head") then return end
			local Highlight = character:FindFirstChild("Highlight")
			local BillboardGui = character.Head:FindFirstChild("TrackingGUI")
			character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
			if BillboardGui then BillboardGui:Destroy() end
			if Highlight then Highlight:Destroy() end
		end
	end

	local function DisplayTrackingGui(Character, character)
		local TrackingGui = Character.Head:FindFirstChild("TrackingGUI")
		if TrackingGui then TrackingGui:Destroy() end
		local Highlight = Character:FindFirstChild("Highlight")
		if Highlight then Highlight:Destroy() end

		local Billboard_GUI = Instance.new("BillboardGui")
		Billboard_GUI.Name = "TrackingGUI"
		Billboard_GUI.ExtentsOffset = Vector3.new(0, 4, 0)
		Billboard_GUI.Size = UDim2.new(2, 0, 2, 0)
		Billboard_GUI.Adornee = Character.Head


		local ImageLabel = Instance.new("ImageLabel")
		ImageLabel.Size = UDim2.new(1, 0, 1, 0)
		ImageLabel.BackgroundTransparency = 1
		ImageLabel.Parent = Billboard_GUI


		Billboard_GUI.Parent = Character.Head


		local Highlight = Instance.new("Highlight")
		Highlight.FillTransparency = 1
		Highlight.Parent = Character


		Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		--[[task.spawn(function()
			local TotalDelta = 0
			while Billboard_GUI.Parent ~= nil do
				for i = 1, #Frames.ArrowTracker do
					ImageLabel.Image = "https://www.roblox.com/asset-thumbnail/image?assetId="..Frames.ArrowTracker[i].."&width=420&height=420&format=png" -- Get the image from Decal ID
					Frames.Stepped:Wait()
				end
			end
		end)]]

		RemoveTrackingGui(character)
	end

	local function FollowNearestPlayer()
		local BodyGyro
		if env.GetFlag("UseBladeBodyGyro") then
			
			if not RootPart:FindFirstChildWhichIsA("AlignOrientation") then
				BodyGyro = Instance.new("AlignOrientation")
				BodyGyro.Mode = Enum.OrientationAlignmentMode.OneAttachment
				BodyGyro.Attachment0 = RootPart:FindFirstChild("RootAttachment")
				BodyGyro.MaxTorque = math.huge

				BodyGyro.Responsiveness = 1000
				if RootPart then
					BodyGyro.Parent = RootPart
				end
			else
				BodyGyro = RootPart:FindFirstChildWhichIsA("AlignOrientation")
			end
		end

		RunService:BindToRenderStep("FindNearestPlayer", Enum.RenderPriority.Camera.Value - 1, function(Delta) -- Delta is how long since the last frame was rendered
			if Tool.Parent ~= Character then RunService:UnbindFromRenderStep("FindNearestPlayer") RemoveTrackingGui(Tracking) return end -- If tool has been unequipped then Disconnect the event listener.

			local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
			if not HumanoidRootPart then return end
			local NearestPlayer = nil -- Where we're going to store the nearest player

			for _, CharacterModel in pairs(workspace.Contents.Live.CharacterModels:GetChildren()) do -- Loop through all characters in workspace
				if CharacterModel == Character then continue end
				if CharacterModel:IsA("Model") then
					if NearestPlayer then
						if (NearestPlayer.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude > (CharacterModel.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude then -- Check if the distance of their Root is shorter than the current nearest player
							NearestPlayer = CharacterModel
						end
					else
						NearestPlayer = CharacterModel
					end
				end
			end



			if env.GetFlag("UseBladeBodyGyro") then
				if not NearestPlayer then 
					BodyGyro.Enabled = false
					return
				else
					BodyGyro.Enabled = true
				end
			end

			if not NearestPlayer then return end

			if not NearestPlayer:FindFirstChild("Head") then NearestPlayer = nil return end
			local gui = NearestPlayer.Head:FindFirstChild("TrackingGUI") if not gui then DisplayTrackingGui(NearestPlayer) end
			Tracking = NearestPlayer
			if Tracking ~= PreviouslyTracking and Tool.Parent == Character then self.Tracker:Fire(NearestPlayer, PreviouslyTracking) PreviouslyTracking = Tracking Tracking = NearestPlayer end -- Tracking



			if not NearestPlayer:FindFirstChild("HumanoidRootPart") then return end ---------- CAMERA AND BODY

			if env.GetFlag("UseBladeBodyGyro") then
				BodyGyro.CFrame =  CFrame.lookAt(RootPart.Position, Vector3.new(NearestPlayer.HumanoidRootPart.Position.X, RootPart.Position.Y, NearestPlayer.HumanoidRootPart.Position.Z)) --cframe + Vector3.new(0, 3, 0)
			end

			local Head : Part = Character.Head
			--Camera.CFrame = CFrame.new() + (Head.Position - (Head.CFrame.LookVector * 4))
			--TweenPlay(Camera, .05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, {CFrame = CFrame.lookAt(Camera.CFrame.Position, NearestPlayer.HumanoidRootPart.Position)})

			if not self.RightClickHeld then
				-- TweenPlay(Camera, .05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, {CFrame = CFrame.lookAt(Camera.CFrame.Position,Vector3.new(NearestPlayer.HumanoidRootPart.Position.X, Camera.CFrame.Position.Y, NearestPlayer.HumanoidRootPart.Position.Z))})
				-- 		Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, Vector3.new(NearestPlayer.HumanoidRootPart.Position.X, Camera.CFrame.Position.Y, NearestPlayer.HumanoidRootPart.Position.Z)), .7 ^ (1 / (Delta * 60)))
			end


			if env.GetFlag("WalkToPlayerEnabled") then Walk(NearestPlayer, Humanoid) end
			TakeNetworkOwner(NearestPlayer, HumanoidRootPart) -- For dummies
		end)
	end


	local function Equipped()
		ToolIsEquipped = true
		self:CreateMotor6D()
		if self["PlayAnimation"] then self:PlayAnimation("idle") end
		ToggleTransparency(true)
		ToggleCameraState(true)
		self:BindAllActions()
		if env.GetFlag("ViewModelEnabled") then
			self.ViewModel:EnableBladeVisibility()
			self.ViewModel:PlayAnimation("ViewModel_blade_Idle")
		end
		task.wait(.5)

		TweenFOV(true)
		FollowNearestPlayer()
	end

	local function Unequip()
		ToolIsEquipped = false
		self:StopAllAnimations()
		self:DeleteMotor6D()
		ToggleTransparency(false)
		ToggleCameraState(false)
		TweenFOV(false)
		self:UnbindAllActions()
		self:DisableGuis()
		if env.GetFlag("ViewModelEnabled") then
			self.ViewModel:DisableBladeVisibility()
			self.ViewModel:StopAllAnimations()
		end

		PreviouslyTracking = nil
		local v1 = RootPart:FindFirstChildWhichIsA("AlignOrientation")
		if v1 then v1:Destroy() end
		if Tracking then
			if not Tracking:FindFirstChild("Head") then 
				Tracking = nil
				return
			end
			if Tracking:FindFirstChild("HumanoidRootPart") then
				ReplicatedStorage.Signals.FightingRemotes.REQUEST_NETWORK_OWNERSHIP.REMOVE_NETWORK_OWNERSHIP:FireServer(Tracking.HumanoidRootPart)
				Tracking = nil
			end
		end
	end


	function this.BoostCharacter(t)
		--[[local Force = Instance.new("LinearVelocity")
		Debris:AddItem(Force, t)
		task.delay(t, function()
			Force = nil
		end)
		Force.Attachment0 = RootPart.RootAttachment
		Force.Parent = RootPart
		--Force.Force = RootPart.CFrame.LookVector * math.clamp((4000 * (Tracking.HumanoidRootPart.Position - RootPart.Position).Magnitude), 1000, 20000)
		Force.MaxForce = 13000
		Force.RelativeTo = Enum.ActuatorRelativeTo.World
		while Force do
			if not Tracking then return end
			if not Tracking:FindFirstChild("HumanoidRootPart") then return end
			Force.MaxForce =  math.clamp((2500 * (Tracking.HumanoidRootPart.Position - RootPart.Position).Magnitude), 2000, 11000)
			Force.VectorVelocity = RootPart.CFrame.LookVector * math.clamp((3000 * (Tracking.HumanoidRootPart.Position - RootPart.Position).Magnitude), 2000, 10000)
			RunService.Heartbeat:Wait()
		end]]

	end

	local function updblock(dir)
		self:UpdateBlockingDirection(dir)
	end


	--// Binding connections
	if not env.GetFlag("UseCharacterBladeToNetworkFrom") then
		if not self.ViewModel:GetBlade() then self.ViewModel:CreateWeldedBlade() end
		self.Hitbox = RaycastHitboxV4.new(self.ViewModel:GetBlade())
	else
		self.Hitbox = RaycastHitboxV4.new(Tool)
	end

	self.Tracker:Connect(DisplayTrackingGui)
	self.BlockingDirection:Connect(updblock)

	local b = RaycastParams.new()
	b.FilterType = Enum.RaycastFilterType.Exclude
	b.FilterDescendantsInstances = {Character}

	self.Hitbox.RaycastParams = b
	Tool.Equipped:Connect(Equipped)
	Tool.Unequipped:Connect(Unequip)
	Tool.Destroying:Connect(Unequip)
	Humanoid.Died:Connect(Unequip)
	RootPart.Destroying:Connect(Unequip)

	self.Hitbox.OnHit:Connect(function(Part : Part, hum : Humanoid, RaycastResult : RaycastResult) -- When the player swings and hits another player
		RemoteEvent:FireServer(Part, hum, RaycastResult.Position, self.InputDirections[self.BlockingDir])
	end)

	Tool.Activated:Connect(function()
			if Debounce.Value then return end -- Prevent player from swinging if they are on cooldown
			if Player:ControlsLocked() then return end -- Prevent player from swinging if their controls are locked.
			if self.IsCurrentlyBlocking then return end
			
			if env.GetFlag("ShowHitboxes") then self.Hitbox.Visualizer = true else self.Hitbox.Visualizer = false end -- Be sure to move this to user settings later

			Debounce.Value = true -- Prevent player from swinging again
			task.spawn(function() this.BoostCharacter(.3) end)
			local SwingDirection = self.BlockingDir
			self.IsSwinging = true

			local ani = self:PlayAnimation("Swing"..SwingDirection)
			local ViewModelTrack
			if env.GetFlag("ViewModelEnabled") then
				ViewModelTrack = self.ViewModel:GetAnimation("ViewModel_Blade_Swing"..SwingDirection)
			end
			
			self:StopAllIdleAnimations()
			RemoteEvent:FireServer(nil, nil, nil, self.InputDirections[SwingDirection], true) -- Play the swing sound effect
			ani:AdjustSpeed(Tools[Tool.Name].Data[SwingDirection].PrepSpeed)
			if env.GetFlag("ViewModelEnabled") then ViewModelTrack.Track:AdjustSpeed(ViewModelTrack.Speed / Tools[Tool.Name].Data[SwingDirection].PrepSpeed) end

			
			task.wait(Tools[Tool.Name].Data[SwingDirection].PrepTime / Tools[Tool.Name].Data[SwingDirection].PrepSpeed)

			if env.GetFlag("ViewModelEnabled") then ViewModelTrack.Track:AdjustSpeed(ViewModelTrack.Speed / Tools[Tool.Name].Data[SwingDirection].RaycastLengthSpeed) end
			ani:AdjustSpeed(Tools[Tool.Name].Data[SwingDirection].RaycastLengthSpeed)
			self.Hitbox:HitStart()
			VFX:SpawnSpecialVisualizer(Tools[Tool.Name].Satistics.VFXSpecial0, Tool.Handle.Union, SwingDirection, Tools[Tool.Name].Data[SwingDirection].RaycastLength / Tools[Tool.Name].Data[SwingDirection].Attack.Speed)	
			VFX:SpawnSpecialVisualizer(Tools[Tool.Name].Satistics.VFXSpecial1, Tool.Handle.Union, SwingDirection, Tools[Tool.Name].Data[SwingDirection].RaycastLength / Tools[Tool.Name].Data[SwingDirection].Attack.Speed)	
			--Tools.blade["Cosmetics"].Trail[1].Enabled = true
			task.wait(Tools[Tool.Name].Data[SwingDirection].RaycastLength / Tools[Tool.Name].Data[SwingDirection].RaycastLengthSpeed)
			
			if env.GetFlag("ViewModelEnabled") then ViewModelTrack.Track:AdjustSpeed(ViewModelTrack.Speed) end
			ani:AdjustSpeed(Tools[Tool.Name].Data[SwingDirection].Attack.Speed)
			self.Hitbox:HitStop()
			--Tools.blade["Cosmetics"].Trail[1].Enabled = false
			self.IsSwinging = false


			task.wait(Tools[Tool.Name].Data[SwingDirection].EndTime / Tools[Tool.Name].Data[SwingDirection].Attack.Speed)
			Debounce.Value = false -- Let the player swing again
	end)

	-- [[ Animation Handling ]]

	local IdleAnimationIsPlaying = false
	local LastIdlePlayed = os.clock()
	local IdleAnimationTime = 9
	local TotalIdleAnimations = -1

	for _, b in pairs(Tools[Tool.Name].Data.idle) do
		TotalIdleAnimations += 1
	end

	for i,v in pairs(Tools[Tool.Name]) do
		if typeof(v) == "table" then 
			for _,key in pairs(v) do
				if typeof(key) == "table" then
					for i,FinalCopy in pairs(key) do
						if typeof(FinalCopy) == "table" then
							if FinalCopy["Anim"] then
								local RealTable = table.clone(FinalCopy)
								RealTable.Anim = self.Animator:LoadAnimation(FinalCopy.Anim)
								RealTable.Anim.Priority = FinalCopy.Priority
								self.Animations[FinalCopy.Name] = RealTable -- Insert all animations
							end
						end
					end
				end
			end
		end
	end

	Frames.Heartbeat:Connect(function(deltaTime) -- Picking random idle animation to play here
		local Now = os.clock()

		if Humanoid.MoveDirection ~= Vector3.new() then
			self:StopAllIdleAnimations()
		end

		if not ToolIsEquipped then return end
		if IdleAnimationIsPlaying then return end
		if LastIdlePlayed + IdleAnimationTime > Now then return end

		local Roll = math.random(0, 1200)
		local Chance = math.random(0, 1200)

		if Roll == Chance then
			env:Log("Playing idle animation now.", script)
			LastIdlePlayed = os.clock()
			local Anim = self:PlayAnimation("idle"..math.random(1, TotalIdleAnimations)) -- Picks a random idle animation with a number in it
			IdleAnimationIsPlaying = true
			Anim.Ended:Wait()
			IdleAnimationIsPlaying = false
		end


	end)

	Humanoid.Running:Connect(function()
		self:StopAllIdleAnimations()
	end)

	Unequip()

end
return blade
