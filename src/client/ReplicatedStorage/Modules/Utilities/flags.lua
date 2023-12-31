--[[
	Description: Simular to how roblox implements FastFlags to change features quickly these flags are made to quickly change the way how the game behaves.
]]

-- // Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")

-- // Neutrals
local Divider = "----------------------------------------"
local env = {}

env.Logs = {}

function env.IsDebugServer ():boolean
	return env.GetFlag("IsServerInDebugMode")
end
	
function env:SetServerMode (bool : boolean)
	env:SetFlag("IsServerInDebugMode", bool)
end

function env:SetFlag (flag, value)
	if self.Flags[flag] == nil then
		warn('"'..flag..'" is not a valid Flag.')
	else
		self.Flags[flag] = value
	end
	
end

function env.GetFlag (flag : string) -- Most used function lol

	if env.Flags[flag] == nil then
		warn('"'..flag..'" is not a valid Flag.')
		return nil
	end
	
	return env.Flags[flag]
end

function env.GetAllFlags ():{}
	return env.Flags
end

function env.DoesFlagExist (flag):boolean
	if env.Flags[flag] ~= nil then
		return true
	else
		return false
	end
end

function env:Log(Message, script : BaseScript)
	
	if typeof(Message) == "boolean" then
		if Message == true then
			Message = "true"
		else
			Message = "false"
		end
	end
	
	local ReportedLog = "\n ["..workspace.DistributedGameTime.."] Script: "..debug.info(2, "s").."\n ["..script.Name.."]: " ..Message
	table.insert(self.Logs, ReportedLog)
end

function env:PrintLogs(Warn : boolean, tableformat)
	if Warn then
		if not tableformat then
			for _, Log in pairs(self.Logs) do
				warn(Log)
				print(Divider)
			end
		else
			warn(self.Logs)
		end
	else
		if not tableformat then
			for _, Log in pairs(self.Logs) do
				print(Log)
				warn(Divider)
			end
		else
			if RunService:IsServer() then
				local tablefunctions = require(script.Parent.table)
				local new = tablefunctions.stringify(self.Logs)
				print(new)
			else
				print(self.Logs)
			end
		end
	end
end

function DebugGuiExeFunc()
	local PlayersService = game:GetService("Players")

	--local frames = require(script.Parent.frames)

	-- frames:Play("Round1", UDim2.fromScale(.5, .5))
end

env.Flags = {
	["VerifyPlayers"] = true, -- If true then the server will verify players join data when they join if false then it will not and the game will immediately start as the server starts.
	["ShowHitboxes"] = false, -- Show hitboxes on each swing
	["RemoveLoadingScreen"] = false, -- Remove the loading screen useful for studio testing
	["IncludeTraceback"] = true, -- Shows script fail line on loading screen
	["PlayerWaitingTime"] = 20, -- How long the server will wait for all players before closing the server.
	["IsServerInDebugMode"] = true, -- Toggles if the server is in debug mode
	["IgnoreJoinDataChecks"] = true, -- If true it will use a valid template for join data when joining. 
	["PrintJoinDataTables"] = false, -- Prints the join data table on join.
	["UseTestingPlate"] = false, -- Spawns a testing plate and spawns everyone there.,
	["FlagsAnimation"] = 1, -- When the flags menu spawns at the end it will use the one listed here
	["bladeWalkSpeed"] = 13, -- Walkspeed when player gets their weapon
	["bladeRunningSpeed"] = 20, -- Walkspeed when the player needs to catch up to the opponent 
	["PlayerStunTime"] = 1, -- How long a player gets stunned for when getting blocked.
	["ExpectedPlayers"] = 4, -- TODO How many players a join data template expects. 
	["DeveloperGui"] = true, -- If enabled a developer gui will appear
	["DebugGuiExeFunc"] = DebugGuiExeFunc, -- Function that gets executed when pressing the "Execute" Button
	["FrameLimit"] = 60, -- The max speed frames can flip.
	["OnRagdollImpluseMultiply"] = 20, -- How much the force gets applied on the character when being ragdolled.
	["PartCameraC0Offset"] = Vector3.new(), -- Offset for the camera on the player's head
	["ViewModelEnabled"] = false, -- Determines if the viewmodel is enabled
	["LockFirstPerson"] = false, -- Determine if first person is locked.
	["ViewModelbladeScale"] = 1.25, -- Determines how big or small the animated view model blade is.
	["UsebladeCameraZoomFeature"] = true, -- Toggles camera zoom while using the weapon.
	["UsebladeCharacterTransparencyFeature"] = false, -- If true the character will be transparent when locking onto a player.
	["WalkToPlayerEnabled"] = true, -- If true then the player will walk to the nearest player
	["WalkToMaxDistance"] = 20, -- The distance that players have to be from each other to automatically walk
	["FeatureSpawnSpecialVFXEnabled"] = true, -- SpecialVFX feature will be enabled or disabled.
	["BackpackInventoryEnabled"] = false, -- Toggles if the backpack inventory is enabled or not.
	["UseBackpackHotbarToolsDraggableFeature"] = false, -- Toggles if the hotbar tools can be dragged or not.
	["UseBladeBodyGyro"] = false, -- Makes the player automatically face the nearest player.
	["DefaultFOV"] = 60,
	["UseCharacterBladeToNetworkFrom"] = true, -- if true then the character's tool will be raycasted from if false then the viewmodel's tool will be raycasted from
	["MaxRagdolls"] = 3,
	["RagdollLoopTimeOutSeconds"] = 10, 
	["CharacterTiltUpdateOnOtherClients"] = true,
	["DamageHighlightColor"] = Color3.fromRGB(255, 0, 4),
	["MaxGetDescriptionRetries"] = 5,
	["GetRetryTimeout"] = .5,
	
}

-- TODO DO NOT PROGRESS IN OTHER THINGS UNTIL MAIN ROUND SYSTEM IS FIXED!!!!!!

return env