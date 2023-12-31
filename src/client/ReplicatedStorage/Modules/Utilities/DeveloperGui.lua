-- [[ SERVICES ]] --
local TweenService = game:GetService("TweenService")
local HTTPService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayersService = game:GetService("Players")

-- [[ VARIABLES ]]
local LocalPlayer = PlayersService.LocalPlayer

-- [[ MODULES ]]
local GuiDragger = require(script.Parent.GuiDragger)
local Signal = require(script.Parent.Parent.signal)

local DeveloperGui = {}
DeveloperGui.__index = DeveloperGui

function DeveloperGui.new()
	local self = setmetatable({}, DeveloperGui)
	
	self.MainFrame = script:WaitForChild("DeveloperGui"):Clone()
	self.HoverColor = Color3.fromRGB(58, 97, 225)
	self.CheckboxColor = Color3.fromRGB(83, 115, 255)
	self.DropdownClickedFunction = nil -- Replace with your own function 
	self.MenuOpen = false
	self.UserIsInMenu = false
	self.UserIsInDetailsMenu = false
	self.DetailsAdded = Signal.new()
	self.DetailsRemoved = Signal.new()
	
	local TweenIsPlaying = false
	
	local OrginalSize = self.MainFrame.BackgroundFrame.Size
	
	local function CloseMenu()
		if TweenIsPlaying then return end
		self.MainFrame.BackgroundFrame.Visible = true
		self.MainFrame.BackgroundFrame.Frame.Visible = false
		self.DetailsRemoved:Fire()
		TweenService:Create(self.MainFrame.DropDown, TweenInfo.new(.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Rotation = 0}):Play()
		local Tween = TweenService:Create(self.MainFrame.BackgroundFrame, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(self.MainFrame.BackgroundFrame.Size.X.Scale, self.MainFrame.BackgroundFrame.Size.X.Offset, 0, 0)})
		Tween:Play()
		TweenIsPlaying = true
		Tween.Completed:Wait()
		self.MenuOpen = false
		self.MainFrame.BackgroundFrame.Visible = false
		TweenIsPlaying = false
	end
	
	local function OpenMenu()
		if TweenIsPlaying then return end
		self.MainFrame.BackgroundFrame.Visible = true
		self.MainFrame.BackgroundFrame.Frame.Visible = true
		TweenService:Create(self.MainFrame.DropDown, TweenInfo.new(.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Rotation = -90}):Play()
		local Tween = TweenService:Create(self.MainFrame.BackgroundFrame, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = OrginalSize})
		Tween:Play()
		TweenIsPlaying = true
		Tween.Completed:Wait()
		self.MenuOpen = true
		TweenIsPlaying = false
	end
	
	self.MainFrame.BackgroundFrame.Size = UDim2.new(self.MainFrame.BackgroundFrame.Size.X.Scale, self.MainFrame.BackgroundFrame.Size.X.Offset, 0, 0)
	self.MainFrame.BackgroundFrame.Visible = false
	
	self.MainFrame.DropDown.MouseButton1Click:Connect(function()
		task.spawn(function()
			if typeof(self.DropdownClickedFunction) == "function" then self.DropdownClickedFunction() end
		end)
		if self.MenuOpen then CloseMenu() else OpenMenu() end
	end)
	
	self.MainFrame.Area.MouseEnter:Connect(function()
		self.UserIsInMenu = true
	end)
	
	self.MainFrame.Area.MouseLeave:Connect(function()
		self.UserIsInMenu = false
	end)
	
	self.MainFrame.Details.MouseEnter:Connect(function()
		self.UserIsInDetailsMenu = true
	end)
	
	self.MainFrame.Details.MouseLeave:Connect(function()
		self.UserIsInDetailsMenu = false
	end)
	
	self.DetailsAdded:Connect(function()
		
		self.MainFrame.Details.Visible = true
		
	end)
	
	self.DetailsRemoved:Connect(function()
		
		self.MainFrame.Details.Visible = false
		
	end)
	
	self:Parent(LocalPlayer.PlayerGui:WaitForChild("SplashGui"))
	
	self.Dragger = GuiDragger.new(self.MainFrame)

	self.Dragger:Enable()
	
	return self
end

function DeveloperGui:Parent(instance : Instance)
	if typeof(instance) ~= "Instance" then error("Argument 1 must be an instance") end
	self.MainFrame.Parent = instance
end

function DeveloperGui:SetTitle(Title : string)
	self.MainFrame.Title.Text = Title
end

function DeveloperGui:MakeNewDetail(Name : string, Callback, Enabled : boolean):Detail
	local Detail = {}
	Enabled = Enabled or false
	Detail.Name = Name
	Detail.Callback = Callback
	Detail.Enabled = Enabled
	return Detail
end

function DeveloperGui:CreateDropdownOption(Title : string, Callback, ...)
	if typeof(Title) ~= "string" then error("Title must be a string") end
	if Callback ~= nil then
		if typeof(Callback) ~= "function" then error("Callback must be a function") end
	end
	 
	local Details = {...}
	
	local DetailAmount = #Details
	
	local NewDropdown : TextButton = self.MainFrame.BackgroundFrame.Frame.Example:Clone()
	NewDropdown.Text = Title
	if Callback then 
		NewDropdown.MouseButton1Click:Connect(function() 
			local New = {}
			for _, Content in pairs(Details) do
				if typeof(Content) == "table" then
					New[Content.Name] = Content.Enabled
				end
			end
			
			Callback(Title, New)
		end) 
	end
	NewDropdown.Visible = true
	NewDropdown.Name = Title
	NewDropdown.Parent = self.MainFrame.BackgroundFrame.Frame
	
	local FrameId = HTTPService:GenerateGUID(false) -- generate random string
	local CurrentTween
	
	
	
	NewDropdown.MouseEnter:Connect(function()
		NewDropdown.BackgroundColor3 = self.HoverColor
		if CurrentTween then if CurrentTween.PlaybackState == Enum.PlaybackState.Playing then CurrentTween:Cancel() end end
		CurrentTween = TweenService:Create(NewDropdown, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 0})
		CurrentTween:Play()
		NewDropdown.BackgroundColor3 = self.HoverColor
		
		
		if DetailAmount > 0 then
			RunService.Heartbeat:Wait()
			self.DetailsAdded:Fire()
			
			for _, Frame in pairs(self.MainFrame.Details:GetChildren()) do
				if Frame:IsA("Frame") and Frame.Name ~= "Example" then
					Frame:Destroy()
				end
			end
			
			for _, Detail in pairs(Details) do
				local Frame = self.MainFrame.Details.Example:Clone()
				Frame.Name = FrameId
				Frame.Title.Text = Detail.Name
				if Detail.Enabled then Frame.Box.BackgroundColor3 = self.HoverColor Frame.Box.ImageTransparency = 0 end
				
				Frame.Box.MouseButton1Click:Connect(function()
					
					if Detail.Enabled then
						Detail.Enabled = false
						Frame.Box.ImageTransparency = 1
						Frame.Box.BackgroundColor3 = self.MainFrame.Details.Example.Box.BackgroundColor3
					else
						Detail.Enabled = true
						Frame.Box.ImageTransparency = 0
						Frame.Box.BackgroundColor3 = self.CheckboxColor
					--	Frame.Box.BackgroundTransparency = 0
					end
					
					if Detail.Callback then 
						if typeof(Detail.Callback) == "function" then
							Detail.Callback(Detail.Enabled)
						end
					end
					
				end)
				Frame.Visible = true
				Frame.Parent = self.MainFrame.Details
			end
			
		else
			self.DetailsRemoved:Fire()
		end
		
	end)
	
	NewDropdown.MouseLeave:Connect(function()
		if CurrentTween then if CurrentTween.PlaybackState == Enum.PlaybackState.Playing then CurrentTween:Cancel() end end
		CurrentTween = TweenService:Create(NewDropdown, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 1})
		CurrentTween:Play()
		 NewDropdown.BackgroundColor3 = self.MainFrame.BackgroundFrame.Frame.Example.BackgroundColor3
	end)
	
end

function DeveloperGui:GetGui():Frame
	return self.MainFrame
end

return DeveloperGui.new()