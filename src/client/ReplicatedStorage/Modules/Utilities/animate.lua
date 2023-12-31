
local animate = {}

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera



function SetupCamera(CFrameData : CFrame)
	local Camera = workspace.CurrentCamera
	Camera.CameraType = Enum.CameraType.Scriptable	
	Camera.CFrame = CFrameData
end

function animate.ResetCamera()
	local Camera = workspace.CurrentCamera
	Camera.CameraType = Enum.CameraType.Custom
	Camera.FieldOfView = 70
end

local Zoom1CameraOffset = Vector3.new(0, 1.1, 2)
local Zoom1CameraOffset1 = Vector3.new(0, 4, 45)

local MapCenter  : Part
for i,v in pairs(workspace.Contents.Map:GetDescendants()) do
	if v.Name == "Center" then
		MapCenter = v
		break
	end
end



local Animations = {
	["Zoom0"] = {
		["Name"] = "Zoom0",
		["Function"] = function()
			
			SetupCamera(CFrame.new(-59.234, 246.333, -18.584) * CFrame.fromOrientation(math.rad(-67.009), math.rad(-99.23), math.rad(0)))
			
			local Tween = TweenService:Create(Camera, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CFrame = CFrame.new(-41.816, 77.789, 41.771) * CFrame.fromOrientation(math.rad(-34.699), math.rad(-42.385), math.rad(0))})
			Tween:Play()
			Tween.Completed:Wait()
			local Tween1 = TweenService:Create(Camera, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CFrame = CFrame.new(-35.179, 69.047, 34.956) * CFrame.fromOrientation(math.rad(-37.1), math.rad(-44.707), math.rad(0))})
			TweenService:Create(Camera, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {FieldOfView = 60}):Play()
			Tween1:Play()
			return Tween1
		end,
	},
	
	["Zoom1"] = {
		["Name"] = "Zoom1",
		["Function"] = function()
			
			
			
			SetupCamera(CFrame.lookAt((MapCenter.CFrame + Zoom1CameraOffset).Position, MapCenter.Position))
			local Tween = TweenService:Create(Camera, TweenInfo.new(4, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {CFrame = CFrame.lookAt((MapCenter.CFrame + Zoom1CameraOffset1).Position, MapCenter.Position)})
			--local Tween1 = TweenService:Create(Camera, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {CFrame = CFrame.lookAt((MapCenter.CFrame + (Zoom1CameraOffset1) + Vector3.new(0, 2, 10)).Position, MapCenter.Position)})
			Tween:Play()
			--.Completed:Wait()
			--Tween1:Play()
			return Tween
		end,
	},
	
	["CameraStart"] = {
		["Name"] = "CameraStart",
		["Function"] = function()
			
			SetupCamera(workspace.Contents.Map.Pole.Cutscene["1"].CFrame)
			-- task.wait(2)
			local Move = TweenService:Create(Camera, TweenInfo.new(2.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {CFrame = Camera.CFrame + Vector3.new(25, 0, 0)})
			Move:Play()
			
			task.spawn(function()
				while Move.PlaybackState == Enum.PlaybackState.Playing do
					Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(7), math.rad(0), math.rad(10))
					RunService.RenderStepped:Wait()
				end
			end)
			
			Move.Completed:Wait()
			
			SetupCamera(workspace.Contents.Map.Pole.Cutscene["2"].CFrame)
			
			local MoveTwice = TweenService:Create(Camera, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {CFrame = Camera.CFrame + Vector3.new(0, 0, -12)})
			MoveTwice:Play()
			
			task.spawn(function()
				while MoveTwice.PlaybackState == Enum.PlaybackState.Playing do
					Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(7), math.rad(4), math.rad(2))
					RunService.RenderStepped:Wait()
				end
			end)
			
			return MoveTwice
		end,
	}
	
}


function animate:PlayAnimation(animation:string)
	if not Animations[animation] then
		warn('"'..animation..'" is not an animation.')
		return
	end
	
	local Anim:Tween = Animations[animation].Function()
	
	return Anim
	
end


--[[function animate:PlayCameraAnimation(Animation)

	local CurrentCameraCFrame = workspace.CurrentCamera.CFrame
	local FrameTime = 0
	local Connection

	Camera.CameraType = Enum.CameraType.Scriptable


	Connection = RunService.Heartbeat:Connect(function(DT)
		FrameTime += (DT * 60) 
		-- This will convert the seconds passed (DT) to the frame of the camera we need.
		-- Then it adds it to the total amount of time passed since the animation started
		
		
		FrameTime = tonumber(FrameTime)
		local NeededFrame = Animation.CFrame:FindFirstChild(math.round(FrameTime))
		print(FrameTime)
		--print(math.round(FrameTime))
		
		if NeededFrame then
			if tonumber(NeededFrame.Name) == 1 then
				Camera.CFrame = NeededFrame.Values["0"].Value
			end
			
			local CurrentFrame = NeededFrame.Name
			local Easing = NeededFrame:FindFirstChild("Eases")
			
			if Easing then
				local AllFrames = {}
				for i,v in pairs(Animation.CFrame:GetChildren()) do
					table.insert(AllFrames, tonumber(v.Name))
				end
				
				local function RoundToNearestTableValue(Table, Number)
					table.sort(Table, function(Left, Right) return math.abs(Number - Left) < math.abs(Number - Right) end)
					return Table
				end
				
				--print(tonumber(CurrentFrame))
				
				local result = RoundToNearestTableValue(AllFrames, tonumber(CurrentFrame))
				
				local num 
				
				for i,v in ipairs(result) do
					if v > tonumber(CurrentFrame) then
						num = v
						break
					end
				end
				
				--print(result)
				
				--print(num)
				
				TweenService:Create(Camera, TweenInfo.new(num / 60, Enum.EasingStyle[Easing["0"].Type.Value], Enum.EasingDirection[Easing["0"].Params.Direction.Value]), {CFrame = Animation.CFrame[num].Values["0"].Value}):Play()
			else
				TweenService:Create(Camera, TweenInfo.new(num / 60, Enum.EasingStyle[Easing["0"].Type.Value], Enum.EasingDirection[Easing["0"].Params.Direction.Value]), {CFrame = Animation.CFrame[num].Values["0"].Value}):Play()
				Camera.CFrame = NeededFrame.Value
			end
		else
			--print('a')
			--Connection:Disconnect()
			--Camera.CameraType = Enum.CameraType.Custom
			--Camera.CFrame = CurrentCameraCFrame	
		end
	end)
end]]

return animate
