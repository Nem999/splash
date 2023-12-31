-- // Services
local RunService = game:GetService("RunService")


-- // Modules
local Signal = require(script.Parent.signal)

-- // Neutrals

local Eval = {}
Eval.__index = Eval



function Eval.new()
	local self = {}
	
	local Filter = {}
	self.OnPlayerFall = Signal.new()
	
	local LastCharacter

	local function Raycast(character : Model) -- Using raycast this time
		if RunService:IsClient() then
			if LastCharacter == character then return end
		end

		local function Insert()
			table.clear(Filter)
			for i,v in pairs(workspace.Contents.Live.CharacterModels:GetChildren()) do
				if v:IsA("Model") then
					table.insert(Filter, v)
				end
			end

			for i,v in pairs(workspace.Contents.Live.Ragdolls:GetChildren()) do
				if v:IsA("Model") then
					table.insert(Filter, v)
				end
			end

		end

		if not character then error("Character is nil") end
		local HumanoidRootPart : Part = character:FindFirstChild("HumanoidRootPart")
		if not HumanoidRootPart then return end
		if not character:IsDescendantOf(workspace) then return end
		Insert()
		
		local b = RaycastParams.new()
		b.FilterDescendantsInstances = Filter
		b.IgnoreWater = true
		b.FilterType = Enum.RaycastFilterType.Exclude

		local DownwardsDirection = 	Vector3.new(0,-10,0)
		local WorldDirection = HumanoidRootPart.CFrame:VectorToWorldSpace(DownwardsDirection)
		local Raycast = workspace:Raycast(HumanoidRootPart.Position, WorldDirection, b)
		
		if not Raycast then
			LastCharacter = character
			self.OnPlayerFall:Fire(character)
		end

	end	

	local Stepped
	local Character
	local OnCharacterAdded
	
	function self:SetPlayer(LocalPlayer : Player) 
		if not LocalPlayer.Character then
			LocalPlayer.CharacterAdded:Wait()
		end
		Character = LocalPlayer.Character
		OnCharacterAdded = LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
			Character = NewCharacter
			Stepped:Disconnect()

			Stepped = RunService.Heartbeat:Connect(function()
				Raycast(Character)
			end)

		end)

		Stepped = RunService.Heartbeat:Connect(function()
			Raycast(Character)
		end)
	end
	
	function self:SetCharacter(character) -- Should only be used for dummies
		Character = character
		
		Stepped = RunService.Heartbeat:Connect(function()
			if not Character then Stepped:Disconnect() return end
			if not Character:IsDescendantOf(workspace) then Stepped:Disconnect() return end
			Raycast(Character)
		end)
	end
	
	function self:Clear()
		if Stepped.Connected then Stepped:Disconnect() end
		if Character then Character = nil end
		self.OnPlayerFall = nil
		Stepped = nil
		self = nil
		if OnCharacterAdded then OnCharacterAdded:Disconnect() end
	end
	
	function self:Disconnect()
		if Stepped.Connected then Stepped:Disconnect() end
		if Character then Character = nil end
		self.OnPlayerFall = nil
		Stepped = nil
		self = nil
		if OnCharacterAdded then OnCharacterAdded:Disconnect() end
	end
	
	setmetatable(self, Eval)
	
	return self
end

function Eval:IsBasePartInAir(BasePart : BasePart)
		local Filter = {}
		for i,v in pairs(workspace.Contents.Live.CharacterModels:GetChildren()) do
			if v:IsA("Model") then
				table.insert(Filter, v)
			end
		end

		for i,v in pairs(workspace.Contents.Live.Ragdolls:GetChildren()) do
			if v:IsA("Model") then
				table.insert(Filter, v)
			end
		end

	if not BasePart then error("BasePart is nil") end
	
	local b = RaycastParams.new()
	b.FilterDescendantsInstances = Filter
	b.IgnoreWater = true
	b.FilterType = Enum.RaycastFilterType.Exclude

	local DownwardsDirection = 	Vector3.new(0,-5,0)
	local WorldDirection = BasePart.CFrame:VectorToWorldSpace(DownwardsDirection)
	local Raycast = workspace:Raycast(BasePart.Position, WorldDirection, b)
	
	if Raycast then
		return false
	else
		return true
	end
end


return Eval
