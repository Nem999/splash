-- [[ SERVICES ]] 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")

RunService.Heartbeat:Wait() -- Prevent recursive call

-- [[ MODULES ]]
local Flags = require(ReplicatedStorage.Modules.Utilities.flags)
local LoadingModule = require(ReplicatedFirst.FirstModules.LoadingModule)
local CameraAnimator = require(ReplicatedStorage.Modules.Utilities.animate)
local Pole = require(ReplicatedStorage.Modules.Utilities.Pole)
local Controls = require(ReplicatedStorage.Modules.Utilities.Player) 
local Vector = require(ReplicatedStorage.Modules.Utilities.vectorhelper)
local SoundController = require(ReplicatedStorage.Modules.Utilities.sounds)
local gui = require(ReplicatedStorage.Modules.Utilities.Gui)
local MatchStatus = require(ReplicatedStorage.Modules.Utilities.GetMatchStatus)
local PlayerHasFellOff = require(ReplicatedStorage.Modules.Utilities.IsPlayerOnAir)
local Font = require(ReplicatedStorage.Modules.Utilities.font)
local Frames = require(ReplicatedStorage.Modules.Utilities.frames)
local MainModule = require(PlayersService.LocalPlayer.PlayerScripts:WaitForChild("MainModule"))
local Backpack = MainModule:GetBackpack()

-- [[ NEUTRALS ]]
local Text = Font:GetFont("Kartun")
local LocalPlayer = PlayersService.LocalPlayer
local PlayerIsNoLongerOnPole = ReplicatedStorage.Signals.FightingRemotes.FellOff
local Connection
local PlatformConnection
local Gyro
local WalkTo
local CanMoveOn = false
local gamehasbegun = false
local FirstAnimationIsStillPlaying = false

-- [[ REMOTES ]]
local RoundEnd = ReplicatedStorage.Signals.RemoteEvents.Rounds.EndRound
local BeginRound = ReplicatedStorage.Signals.RemoteEvents.Rounds.BeginGame
local ProceedThroughRound = ReplicatedStorage.Signals.RemoteEvents.Rounds.Proceed
local ReadyUp = ReplicatedStorage.Signals.RemoteEvents.Ready

-- [[ FUNCTIONS ]]


function CheckFloor()
	PlatformConnection = PlayerHasFellOff.new()
	PlatformConnection:SetPlayer(LocalPlayer)


	Connection = PlatformConnection.OnPlayerFall:Connect(function()
		Backpack:Disable()
		PlayerIsNoLongerOnPole:FireServer()
	end)
end

function StopCheckingFloor()
	if Connection then Connection:Disconnect() end
	if PlatformConnection then PlatformConnection:Disconnect() end
end

function BeginCountdown()
	-- Countdown has started!

	task.wait(1)
	
	Frames:Play("Ready", UDim2.fromScale(.5, .5))

	task.wait(1)


	task.wait(1)


	task.wait(1)
	
	Controls:UnlockControls()

end

function EndRound()
	gui.FlagGui:Spawn(3)
end

function BeginGame()
	gamehasbegun = true
	WalkTo = FindNearestWalkPoint()
	if Gyro then Gyro:Destroy() end

	Gyro = Instance.new("AlignOrientation")

	Gyro.Responsiveness = 400
	Gyro.CFrame = CFrame.lookAt(LocalPlayer.Character.HumanoidRootPart.Position, Vector3.new(WalkTo.Position.X, LocalPlayer.Character.HumanoidRootPart.Position.Y, WalkTo.Position.Z))
	Gyro.Enabled = true
	Gyro.Mode = Enum.OrientationAlignmentMode.OneAttachment
	Gyro.Attachment0 = LocalPlayer.Character.HumanoidRootPart.RootAttachment
	Gyro.MaxTorque = 700
	Gyro.Parent = LocalPlayer.Character.HumanoidRootPart

	local CamAnim1 = Pole:PlayAnimation("PoleLook")
	FirstAnimationIsStillPlaying = true
	CamAnim1.Track.Ended:Wait()
	FirstAnimationIsStillPlaying = false

	Proceed()

end

function FindNearestWalkPoint()
	local Points = {}
	for _, Part in pairs(workspace.Contents.Map.Pole:GetDescendants()) do
		if Part:IsA("BasePart") then
			if Part.Name == "WalkPoint" then
				table.insert(Points, Part)
			end
		end
	end

	local NearestPoint

	for _, WalkPoint in pairs(Points) do
		if not NearestPoint then NearestPoint = WalkPoint else
			if Vector.GetDistance(WalkPoint, LocalPlayer.Character.HumanoidRootPart) < Vector.GetDistance(NearestPoint, LocalPlayer.Character.HumanoidRootPart) then
				NearestPoint = WalkPoint
			end
		end
	end

	return NearestPoint

end


function Proceed()
	if not gamehasbegun then BeginGame() end
	if FirstAnimationIsStillPlaying then repeat RunService.Heartbeat:Wait() until not FirstAnimationIsStillPlaying end
	local CameraAnimation = CameraAnimator:PlayAnimation("Zoom1")

	if not WalkTo then
		WalkTo = FindNearestWalkPoint()
	end
	
	if MatchStatus:GetRound() <= 2 then
		task.spawn(function()
			task.wait(1)
			Frames:Play("Round"..MatchStatus:GetRound(), UDim2.fromScale(.5, .5))
		end)
	end
	
	LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid"):MoveTo(WalkTo.Position)
	CameraAnimation.Completed:Wait()
	CameraAnimator.ResetCamera()
	if Gyro then Gyro:Destroy() end

	LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid"):EquipTool(LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool"))
	BeginCountdown()
end


-- // Everything else

if Flags.GetFlag("UseTestingPlate") then -- If we're using the testing plate we can just disable this script
	Controls:UnlockControls()
	return nil
else
	Controls:LockControls()
end

if ReplicatedStorage.Values.RoundActive.Value == true then
	Controls:UnlockControls()
else
	Controls:LockControls()
end


--// Handle events
RoundEnd.OnClientEvent:Connect(EndRound)
BeginRound.OnClientEvent:Connect(BeginGame)
ProceedThroughRound.OnClientEvent:Connect(Proceed)

-- // Code
CheckFloor()

return nil