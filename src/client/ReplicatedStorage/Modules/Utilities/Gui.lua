-- [[ SERVICES ]]
local TweenService = game:GetService("TweenService")
local PlayersService = game:GetService("Players")
local RunService = game:GetService("H")

-- [[ MODULES ]]
local Flags = require(script.Parent.flags)

-- [[ VARAIBLES ]]
local Gui = {}
local wait = task.wait
local LocalPlayer = PlayersService.LocalPlayer

-- // Gui Types

local InstancesBeingTweened = {}
function Tween(instance:Instance, Time :number?, EasingStyle:Enum.EasingStyle, EasingDirection:Enum.EasingDirection, Properity : {}, Queue : boolean)
	if Queue then
		while table.find(InstancesBeingTweened, instance) do task.wait() end -- If the instance is already being tweened
	end
	table.insert(InstancesBeingTweened, instance)
	local Tween = TweenService:Create(instance, TweenInfo.new(Time, EasingStyle, EasingDirection), Properity)
	task.delay(Time, function()
		table.remove(InstancesBeingTweened, table.find(InstancesBeingTweened, instance))
	end)
	Tween:Play()

	return Tween
end

Gui.FlagGui = {}

-- //

function Gui.MakeGui(GuiType : string)
	if typeof(GuiType) ~= "string" then error("Argument 1 is not a string.") end
	if not script:FindFirstChild(GuiType) then error('"'..GuiType..'" is not a valid Gui type.') end

	return require(script[GuiType])
end

function Gui.Draggable(object : Frame)
	return require(script.GuiDragger).new(object)
end

function Gui.FlagGui:Spawn(NumberOfFlags:number) 
	if Flags.GetFlag("FlagsAnimation") == 1 then -- We're going for a little opening effect
		local TotalFrames = 3
		local MedianTime = 1.3
		local RoundGui = LocalPlayer.PlayerGui.SplashGui
		RoundGui.FlagGui.Visible = false
		local Container = RoundGui.FlagGui.Container
		local PreferredSize = Container.Size
		local OrginalColor = Container.BackgroundColor3
		Container.Size = UDim2.fromScale(0, PreferredSize.Y.Scale)  -- It's going to open outwards on the width
		Container.BackgroundTransparency = .5
		Container.UIStroke.Transparency = .5
		Container.BackgroundColor3 = Color3.fromRGB(143, 143, 143)
		Container.Visible = true
		RoundGui.FlagGui.Visible = true
		local basenum = 0
		for i = 1, TotalFrames do 
			if i > NumberOfFlags then
				Container["Flag"..i].Visible = false
			else
				Container["Flag"..i].Visible = true
			end
			basenum += 1
			Container["Flag"..i].Background.Position = UDim2.fromScale(-(basenum), 0)
		end
		local BaseThickness = Container.Flag1.Background.UIStroke.Thickness
		for i = 1, TotalFrames do
			Container["Flag"..i].Background.UIStroke.Thickness = 0
		end
		
		Container.UICorner.CornerRadius =  UDim.new(0,0)
		local Tilt = 60
		for i = 1, TotalFrames do
			Container["Flag"..i].Background.Rotation = Tilt * i 
			Tween(Container["Flag"..i].Background.UIStroke, MedianTime + .3, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, { Thickness = BaseThickness})
			Tween(Container["Flag"..i].Background, MedianTime + .3, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, { Rotation = 0})
			Tween(Container["Flag"..i].Background, MedianTime + .5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, { Position = UDim2.fromScale(0,0)})
		end
		Tween(Container.UICorner, MedianTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, { CornerRadius = UDim.new(1, 0)})
		local ColorTween = Tween(Container, MedianTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, { BackgroundColor3 = OrginalColor})
		local SizeTween = Tween(Container, MedianTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, { Size = PreferredSize})
		SizeTween.Completed:Wait()
		wait(2)
		Tween(Container.UICorner, MedianTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, { CornerRadius = UDim.new(0, 0)})
		Tween(Container.UIStroke, MedianTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, { Transparency = 1})
		for i = 1, TotalFrames do
			Tween(Container["Flag"..i].Background.UIStroke, MedianTime + .3, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, { Thickness = 0})
			Tween(Container["Flag"..i].Background, MedianTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, { Rotation = Tilt * i})
		end
		local EndingTween = Tween(Container, MedianTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, { Size = UDim2.fromScale(0, PreferredSize.Y.Scale)})
		Tween(Container, MedianTime - .3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, { BackgroundColor3 = Color3.fromRGB(143, 143, 143)})
		Tween(Container, MedianTime , Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, { BackgroundTransparency = 1})
		EndingTween.Completed:Wait()
		RoundGui.FlagGui.Visible = false
	end
end






return Gui
