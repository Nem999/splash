--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

--// Modules
local Signal = require(ReplicatedStorage.Modules.Utilities.signal)
local SendBlockSignal = require(script.BlockingScript)
local Frames = require(ReplicatedStorage.Modules.Utilities.frames)
local Flags = require(ReplicatedStorage.Modules.Utilities.flags)
local MainModule = require(LocalPlayer.PlayerScripts.MainModule)

-- // Neutrals
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
LocalPlayer.CharacterAdded:Connect(function(character)
	Character = character
end)
local UIS_CONNECTION
local UIS_CONNECTION2

-- //
local RightClickHeld = false
local RightGripCFrame
local Absolute = math.abs

local self = {}

function self.new()
	Frames.Heartbeat:Wait()
	task.wait()
	local RootPart = Character:WaitForChild("HumanoidRootPart")

	self.Tracker = Signal.new()
	self.BlockingDirection = Signal.new()
	self.Animations = {}
	self.m6d = nil
	self.BlockingDir = nil
	self.IsCurrentlyBlocking = false
	self.IsSwinging = false
	self.RightClickHeld = false
	self.ViewModel = MainModule:GetViewModel()

	self.InputDirections = {
		["Right"] = 3,
		["Left"] = 2,
		["Up"] = 1,
		["Down"] = 1
	}
	self.InputDirections.__index = 0
	setmetatable(self.InputDirections, {})

	local function Unblock()
		SendBlockSignal:UpdateBlock(0)
		self:DisableGuis()
		task.wait(.05)
		self:StopAction3Animations()
	end

	local function Block(actionName, inputState, inputObject)
		if actionName == "bladeBlock" and inputState == Enum.UserInputState.Begin then
			self:UpdateBlockingDirection(self.BlockingDir)
			local rad = math.rad
			local Sensitivity = 20
			self:EnableGuis()

		elseif actionName == "bladeBlock" and inputState == Enum.UserInputState.End then 
			Unblock()
		end
	end

	function self:BindAllActions()
		--------------------------------------------------------- TODO ----------------------------------------------------------------------

		UIS_CONNECTION = UserInputService.InputBegan:Connect(function(input, processed)
			--if processed then return end
			if input.KeyCode == Enum.KeyCode.F and not self.IsSwinging then
				self.IsCurrentlyBlocking = true
				Block("bladeBlock", input.UserInputState)
			end
		end)

		UIS_CONNECTION2 = UserInputService.InputEnded:Connect(function(input, processed)
			--if processed then return end
			if input.KeyCode == Enum.KeyCode.F then
				self.IsCurrentlyBlocking = false
				Block("bladeBlock", input.UserInputState)
			end
		end)



	--[[	

	]]
	end

	function self:UpdateBlockingDirection(dir)
		local StopTime = .3
		local StartTime = .3
		if self.IsCurrentlyBlocking then
			SendBlockSignal:UpdateBlock(self.InputDirections[dir])
			if dir == "Up" then
				self:StopAction3Animations()
				self:PlayAnimation("BlockingUp")
			elseif dir == "Down" then
				self:StopAction3Animations()
				self:PlayAnimation("BlockingUp")
			elseif dir == "Right" then
				self:StopAction3Animations()
				self:PlayAnimation("BlockingRight")
			elseif dir == "Left" then
				self:StopAction3Animations()
				self:PlayAnimation("BlockingLeft")
			end
		end
	end

	function self:UnbindAllActions()
		if UIS_CONNECTION then UIS_CONNECTION:Disconnect() end
		if UIS_CONNECTION2 then UIS_CONNECTION2:Disconnect() end
		RightClickHeld = false
		self.IsCurrentlyBlocking = false

		RunService:UnbindFromRenderStep("FindNearestPlayer")
		Unblock("Stop")
	end

	function self:StopAction3Animations()
		for i,v in pairs(self.Animations) do
			if v.Anim.Priority == Enum.AnimationPriority.Action3 then v.Anim:Stop() end
		end
	end

	function self:CreateMotor6D()
		local a:Weld = Character:FindFirstChild("Right Arm"):WaitForChild("RightGrip") -- Wait for the RightGrip Weld to get added to our character
		self.m6d = Instance.new("Motor6D") -- Create new Motor6D
		self.m6d.Name = "RightGrip"
		self.m6d.Part0 = a.Part0
		self.m6d.Part1 = a.Part1
		self.m6d.C0 = a.C0
		RightGripCFrame = a.C0
		self.m6d.C1 = a.C1
		self.m6d.Parent = Character:FindFirstChild("Right Arm")
		a:Destroy()
	end

	function self:DeleteMotor6D()
		if self.m6d then self.m6d:Destroy() self.m6d = nil end -- If theres a Motor6D on the character delete it.
		--local Grip = RootPart:FindFirstChild("Grips")
		--if Grip then self:DeleteWelds() end
	end

	function self:EnableGuis()
		LocalPlayer.PlayerGui.RotationGui.Enabled = true
		LocalPlayer.PlayerGui.RotationGui.BlockingGui.Visible = true
	end

	function self:DisableGuis()
		LocalPlayer.PlayerGui.RotationGui.Enabled = false
		LocalPlayer.PlayerGui.RotationGui.BlockingGui.Visible = false
	end

	function self:PlayAnimation(name):AnimationTrack
		if self.Animations[name] then
			self.Animations[name].Anim:Play(self.Animations[name].FadeTime, self.Animations[name].Weight, self.Animations[name].Speed)

			if name:match("Swing") then
				if Flags.GetFlag("ViewModelEnabled") then
					self.ViewModel:PlayAnimation("ViewModel_Blade_Swing"..self.BlockingDir)
				end
			end

			return self.Animations[name].Anim
		end
	end

	function self:StopAllAnimations()
		for i,v in pairs(self.Animations) do
			v.Anim:Stop()
		end
	end

	function self:StopAllIdleAnimations()
		for _, Track in pairs(self.Animations) do
			local trackname : string = Track.Name
			if trackname.lower(trackname):match("idle") then
				if trackname == "idle" then continue end

				Track.Anim:Stop()
			end
		end
	end

	local function OnHeartbeat()
		self.RightClickHeld = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)		
	end

	local function UpdateBlock(Direction)
		self:UpdateBlockingDirection(Direction)
	end

	local function Calculate()

		OnHeartbeat()

		if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
			local Mouse = UserInputService:GetMouseLocation()
			local MousePos = UDim2.new(0, Mouse.X, 0, Mouse.Y)
			local TargetGui = LocalPlayer.PlayerGui.RotationGui.BlockingGui
			local center = TargetGui.Circle.AbsolutePosition + (TargetGui.Circle.AbsoluteSize/2)
			local x = math.atan2(Mouse.Y - center.Y, Mouse.X - center.X)
			local b = (math.deg(x) + 90) / 13 
			local Up = NumberRange.new(-2.8, -0.4)
			local Right = NumberRange.new(-.39999, 0.33)
			local Down = NumberRange.new(0.33111, 2.73)
			TargetGui.Parent.BlockingGui.Rotation = math.deg(x) + 90 / 2



			if x >= Up.Min and x <= Up.Max then
				--warn("Up vector: "..x)
				if self.BlockingDir ~= "Up" then self.BlockingDir = "Up" self.BlockingDirection:Fire("Up") end
			elseif x >= Right.Min and x <= Right.Max then
				--warn("Right vector: "..x)
				if self.BlockingDir ~= "Right" then self.BlockingDir = "Right" self.BlockingDirection:Fire("Right") end
			elseif x >= Down.Min and x <= Down.Max then
				--warn("Down Vector:" ..x)
				if self.BlockingDir ~= "Up" then self.BlockingDir = "Up" self.BlockingDirection:Fire("Up") end
			else
				--warn("Left Vector:" ..x)
				if self.BlockingDir ~= "Left" then self.BlockingDir = "Left" self.BlockingDirection:Fire("Left") end

			end
		else

			if UserInputService.MouseEnabled then
				local MouseDelta = UserInputService:GetMouseDelta()

				if MouseDelta == Vector2.new() then -- Player didn't move mouse
					if self.BlockingDir then
						self.BlockingDir = "Left"
						self.BlockingDirection:Fire("Left")
					end
				elseif Absolute(MouseDelta.Y) > Absolute(MouseDelta.X) then -- Player is moving their mouse up or down
					if MouseDelta.Y > 0 then

						if self.BlockingDir ~= "Up" then
							self.BlockingDir = "Up"
							self.BlockingDirection:Fire(self.BlockingDir)
						end

					else

						if self.BlockingDir ~= "Up" then
							self.BlockingDir = "Up"
							self.BlockingDirection:Fire(self.BlockingDir)
						end

					end

				else -- Player is moving their mouse left or right 
					if MouseDelta.X > 0 then

						if self.BlockingDir ~= "Right" then
							self.BlockingDir = "Right"
							self.BlockingDirection:Fire(self.BlockingDir)
						end

					else

						if self.BlockingDir ~= "Left" then
							self.BlockingDir = "Left"
							self.BlockingDirection:Fire(self.BlockingDir)
						end

					end
				end
				-- print(self.BlockingDir)

			end

		end
	end

	self.BlockingDirection:Connect(UpdateBlock)

	RunService.Heartbeat:Connect(Calculate)
end

local St = false

function Set(b, a, c)
	if a == Enum.UserInputState.Begin then
		if St then
			LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
			ContextActionService:BindActionAtPriority("NoRMBDrag", function()
				return Enum.ContextActionResult.Pass
			end, false, Enum.ContextActionPriority.Medium.Value, Enum.UserInputType.MouseButton2)
			St = false
		else
			LocalPlayer.CameraMode = Enum.CameraMode.Classic
			ContextActionService:BindActionAtPriority("NoRMBDrag", function()
				return Enum.ContextActionResult.Sink
			end, false, Enum.ContextActionPriority.Medium.Value, Enum.UserInputType.MouseButton2)
			St = true
		end
	end
end

if Flags.IsDebugServer() then
	ContextActionService:BindAction("ToggleQ", Set, false, Enum.KeyCode.Q)
end

return self
