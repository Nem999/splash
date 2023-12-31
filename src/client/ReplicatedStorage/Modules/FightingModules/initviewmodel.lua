-- // Services 
local PlayersService = game:GetService("Players")

-- // Neutrals
local LocalPlayer = PlayersService.LocalPlayer

-- // Modules
local MainModule = require(LocalPlayer.PlayerScripts:WaitForChild("MainModule"))
local ViewModel = MainModule:GetViewModel()

return function(bool)
	if bool then
		ViewModel:EnableBladeVisibility()
		ViewModel:PlayAnimation("ViewModel_blade_Idle")
	else
		ViewModel:DisableBladeVisibility()
		ViewModel:DeleteCurrentViewModelBlade()
		ViewModel:StopAnimation("ViewModel_blade_Idle")
	end
end