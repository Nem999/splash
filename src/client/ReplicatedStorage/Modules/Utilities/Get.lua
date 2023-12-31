--[[
	Description: A way of getting data that isn't guaranteed to be returned 
]]

-- [[ SERVICES ]]
local PlayersService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [[ MODULES ]]
local Flags = require(ReplicatedStorage.Modules.Utilities.flags)

-- [[ VARIABLES ]]
local Get = {}

-- [[ FUNCTIONS ]]

function TieToRetry(tries, MaxTries, fn, ...)
	local Tries = tries or 0
	local b, a = fn(...)
	
	if b and a then
		return a, b
	else
		if tries == MaxTries then
			return nil
		end
		Tries += 1
		task.wait(Flags.GetFlag("GetRetryTimeout"))
		TieToRetry(tries, MaxTries, fn,...)
	end
	
end

function Get.Description(id)
	return TieToRetry(nil, Flags.GetFlag("MaxGetDescriptionRetries"), pcall, PlayersService.GetHumanoidDescriptionFromUserId, PlayersService, id)
end

-- //
return Get	