-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PlayersService = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HTTPService = game:GetService("HttpService")

-- // Modules
local buffer = require(script.Parent.Parent.Parent.Utilities.buffer)
local CharacterValues = require(script.Parent.Parent.Parent.Utilities.getcharactervalues)
local Flags = require(script.Parent.Parent.Parent.Utilities.flags)

-- // Neutrals
local VFXCache = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("VFX")
local VFXSignal = ReplicatedStorage:WaitForChild("Signals"):WaitForChild("RemoteEvents"):WaitForChild("VFXRemotes"):WaitForChild("vfx")
local SpecialVFXSignal = ReplicatedStorage:WaitForChild("Signals"):WaitForChild("RemoteEvents"):WaitForChild("VFXRemotes"):WaitForChild("specialvfx")
local DBList = {}
local Directions = {
	["Up"] = Enum.NormalId.Top,
	["Right"] = Enum.NormalId.Front,
	["Left"] = Enum.NormalId.Back,
	["Down"] =  Enum.NormalId.Top
}

local vfx = {}

vfx.Visualizers = {
	["BladeHit"] = {
		Name = "BladeHit",
		VFX = VFXCache.HitEffectV3
		
	},
	["BladeBlock"] = {
		Name = "BladeBlock",
		VFX = VFXCache.Block
	},
}

vfx.SpecialVisualizers = {
	["BladeSwing"] = {
		Name = "BladeSwing",
		Emit = function(PartToTrack, Direction, Duration)
			local Effect = ReplicatedStorage.Assets.VFX.bladeSpecialTrail:Clone()
			local tick = os.clock
			
			local Start = tick() + Duration
			
			buffer:AddInstance(Effect, Duration + 2, PartToTrack)
			
			for _, Emitter : ParticleEmitter in pairs(Effect:GetChildren()) do
				if Emitter:IsA("ParticleEmitter") then
					Emitter.Enabled = true
					Emitter.EmissionDirection = Directions[Direction]
				end
			end
			
			while true do
				local End = tick()
				
				Effect.CFrame = PartToTrack.CFrame
				
				RunService.RenderStepped:Wait()
				if End >= Start then 
					for _, Emitter : ParticleEmitter in pairs(Effect:GetChildren()) do
						if Emitter:IsA("ParticleEmitter") then
							Emitter.Enabled = false
						end
					end
					break
				end
			end
		end,
	},
	["BladeTrail"] = {
		Name = "BladeTrail",
		Emit = function(PartToTrack, Direction, Duration)
			local now = os.clock()
			
			while true do
				RunService.RenderStepped:Wait()
				
				local Tracking : MeshPart =  PartToTrack:Clone()
				
				Tracking:ClearAllChildren()
				
				Tracking.Anchored = true
				
				TweenService:Create(Tracking, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Transparency = 1}):Play()
				
				buffer:AddInstance(Tracking, .4)
				
				local RightNow = os.clock()
				
				if RightNow - now > Duration then
					break
				end
				
			end
		end,
	}
}

vfx.OnSignal = nil
vfx.OnSpecialSignal =  nil

function Emit(Effect : Instance)
	buffer:AddInstance(Effect, 20)
	for a,b : ParticleEmitter in pairs(Effect:GetDescendants()) do
		if b:IsA("ParticleEmitter") then
			local EmitCount = b:GetAttribute("EmitCount")
			local EmitDelay = b:GetAttribute("EmitDelay")
			task.delay(EmitDelay, function()
				b:Emit(EmitCount)
			end)
		end
	end
end;

function vfx:SpawnSpecialVisualizer(Visualizer : string, Part : BasePart, Direction : string, Duration : number, Recursive):BasePart
	if not Flags.GetFlag("FeatureSpawnSpecialVFXEnabled") then return end
	if RunService:IsClient() then
		
		local emit = vfx.SpecialVisualizers[Visualizer].Emit or Visualizer.Emit
		 task.spawn(emit, Part, Direction, Duration)
		if not Recursive then
			SpecialVFXSignal:FireServer(Visualizer, Part, Direction, Duration)
		end
	end
end

function vfx:SpawnVisualizer(Visualizer : vfx.Visualizer, Position : Vector3)
	if RunService:IsServer() then
		VFXSignal:FireAllClients(Visualizer.Name, Position)
	else
		local VFXClone : Part = Visualizer.VFX:Clone()
		local NewAttachment = Instance.new("Attachment")
		NewAttachment.CFrame = CFrame.new(Position.X, Position.Y, Position.Z)
		for _, Particle in pairs(VFXClone:GetChildren()) do
			if Particle:IsA("ParticleEmitter") then
				Particle.Parent = NewAttachment
			end
		end
		VFXClone:Destroy()
		Emit(NewAttachment)
	end
end

function vfx.Subscribe()
	if RunService:IsClient() then
		vfx.OnSignal = VFXSignal.OnClientEvent
		vfx.OnSpecialSignal = SpecialVFXSignal.OnClientEvent
		
		VFXSignal.OnClientEvent:Connect(function(VFX, Position)
			vfx:SpawnVisualizer(vfx.Visualizers[VFX], Position)
		end)
		
		SpecialVFXSignal.OnClientEvent:Connect(function(Visualizer, BasePart, Direction, Duration)
			vfx:SpawnSpecialVisualizer(Visualizer, BasePart, Direction, Duration)
		end)
		
	end
	
	if RunService:IsServer() then
		vfx.OnSignal = SpecialVFXSignal.OnServerEvent
		SpecialVFXSignal.OnServerEvent:Connect(function(LocalPlayer, VFX, BasePart, Direction, Duration)
			if not Flags.GetFlag("FeatureSpawnSpecialVFXEnabled") then return end
			
			if table.find(DBList, LocalPlayer) then return end
			
			table.insert(DBList, LocalPlayer)
			task.delay(.5, function()
				table.remove(DBList, table.find(DBList, LocalPlayer))
			end)
			
			assert(VFX)
			assert(BasePart)
			assert(Direction)
			assert(Duration)

			if typeof(BasePart) ~= "Instance" then return end
			if not CharacterValues:IsValidDirection(Direction) then return end
			if typeof(Duration) ~= "number" then return end
			if Duration > 10 then return end
			if typeof(VFX) ~= "string" then return end
			if not vfx.SpecialVisualizers[VFX] then return end
			
			for _, Player in pairs(PlayersService:GetPlayers()) do
				if Player == LocalPlayer then continue end
				
				SpecialVFXSignal:FireClient(Player, VFX, BasePart, Direction, Duration, true)
			end
			
		end)
	end
end



return vfx
