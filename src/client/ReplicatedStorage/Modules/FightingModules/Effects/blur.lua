-- // Services
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- // Modules
local g = require(ReplicatedStorage.Modules.Utilities.global)

-- // Neutrals
local Exposure = Lighting.ExposureCompensation
local Remote = ReplicatedStorage:WaitForChild("Signals"):WaitForChild("RemoteEvents"):WaitForChild("EffectsRemotes"):WaitForChild("SpawnBlurEffect")
local blur = {}

-- // Functions

local function ColorCorrect()
	local ColorCorrection = Instance.new("ColorCorrectionEffect")
	ColorCorrection.Parent = Lighting
	ColorCorrection.TintColor = Color3.fromRGB(223, 33, 33)
	ColorCorrection.Brightness = 0.2
	ColorCorrection.Saturation = .9
	ColorCorrection.Contrast = 1
	--g:Tween(ColorCorrection, .08, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, {TintColor = Color3.fromRGB(121, 38, 39)})
	--g:Tween(ColorCorrection, .08, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, {Brightness = .5})
	--:Tween(ColorCorrection, .08, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, {Contrast = .7})
	-- last = g:Tween(ColorCorrection, .08, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, {Saturation = .6})
	-- last.Completed:Wait()
	local con = g:Tween(ColorCorrection, .7, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, {TintColor = Color3.fromRGB(255, 255, 255)})
	g:Tween(ColorCorrection, .5, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, {Brightness = 0})
	g:Tween(ColorCorrection, .5, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, {Saturation = 0})
	g:Tween(ColorCorrection, .5, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, {Contrast = 0})
	con.Completed:Wait()
	ColorCorrection:Destroy()
end

local function BlurScreen()
	local Blur = Instance.new("BlurEffect")
	Blur.Parent = Lighting
	Blur.Size = 26
	-- local a = g:Tween(Blur, .1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, {Size = 56})
	--a.Completed:Wait()
	local b = g:Tween(Blur, .3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, {Size = 0})
	b.Completed:Wait()
	Blur:Destroy()
end

local function ChangeDefusion()
	Lighting.ExposureCompensation = 1
	g:Tween(Lighting, .2, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, {ExposureCompensation = Exposure})
end

function blur:PlayDamageEffect(LocalPlayer : Player)
	if RunService:IsClient() then
		task.spawn(ColorCorrect)
		task.spawn(BlurScreen)
		task.spawn(ChangeDefusion)
	else
		Remote:FireClient(LocalPlayer)
	end
end

function blur.Subscribe()
	if RunService:IsClient() then
		blur.OnSignal = Remote.OnClientEvent
		blur.OnSignal:Connect(function()
			blur:PlayDamageEffect()
		end)
	end
end

-- //

return blur
