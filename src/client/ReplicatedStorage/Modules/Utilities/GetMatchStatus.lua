--[[ //
-- A quick and easy way to get match data to limit referencing values
-- To make things easy to adapt to change.
]]
-- [[ SERVICES ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerScriptService = game:GetService("ServerScriptService")
local TeamsService = game:GetService("Teams")
local PlayersService = game:GetService("Players")

-- [[ MODULES ]]
local LoadingModule = require(ReplicatedFirst.FirstModules.LoadingModule)
local Tips = require(script.Parent.tips) 
local PlayerControls = require(script.Parent.Player)
local Platform = require(script.Parent.Pole)
local Get = require(script.Parent.Get)
local d = require(script.Parent.makedummy)

-- [[ VARIABLES ]]
local EndRemote = ReplicatedStorage:WaitForChild("Signals"):WaitForChild("RemoteEvents"):WaitForChild("Rounds"):WaitForChild("EndGame")
local GetDescription = Get.Description

-- [[ MATCH DATATYPE ]]
local match = {
	["Mode"] = nil,
	["PreviousRounds"] = {},
	["Teams"] = {
	}
}

local MatchTypes  
={
	["1v1"] = {
		["Players"] = 2,
		["TotalRounds"] = 3,
		["RematchAllowed"] = true,
		["SuddenDeathAllowed"] = true,
		["Teams"] = {
				["Red"] 
				={
					["Spawn"] = nil,
					["Name"] = "Red",
					["Color"] = Color3.fromRGB(255, 0, 4),
			},
				["Blue"]
				={
					["Spawn"] = nil,
					["Name"] = "Blue",
					["Color"] = Color3.fromRGB(20, 36, 255),
					
				}
		}
	},
	
	["Duos"] = {
			["Players"] = 4,
			["TotalRounds"] = 3,
			["RematchAllowed"] = true,
			["SuddenDeathAllowed"] = true,
			["Teams"] = {
				["Red"] 
				={
					["Spawn"] = nil,
					["Name"] = "Red",
					["Color"] = Color3.fromRGB(255, 0, 4),
				},
				["Blue"]
				={
					["Spawn"] = nil,
					["Name"] = "Blue",
					["Color"] = Color3.fromRGB(20, 36, 255),

				}
			}
	}
}

-- [[ FUNCTIONS ]]
function GetPlayers(Team : string)
	local Players = {}
	
	for _, Player in pairs(TeamsService[Team]:GetChildren()) do
		
		if Player:IsA("ObjectValue") then
			if Player.Value then
				if Player.Value:IsA("Player") then
					table.insert(Players, Player.Value)
				end
			end
		end
		
	end
	
	return Players
end

function match:LockAllControls()
	for _,  Player in pairs(match:GetAllPlayers()) do
		PlayerControls:LockControls(Player)
	end
end

function match:UnlockAllControls()
	for _,  Player in pairs(match:GetAllPlayers()) do
		PlayerControls:UnlockControls(Player)
	end
end


function match:IsValidGamemode(Mode : string)
	if not MatchTypes[Mode] then
		return false
	else
		return true
	end
end

function match:IsValidTeam(Team : string)
	local Teams = self:GetTeams()
	if not Teams[Team] then
		return false
	else
		return true
	end
end

function match:IsGamemodeSet()
	return ReplicatedStorage.Values.GamemodeSet.Value
end

function match:WasSuddenDeathInitiated()
	return ReplicatedStorage.Values.SDActivated.Value
end

function match:SetMode(Mode : string)
	if not MatchTypes[Mode] then
		error('"'..Mode..'" is not a valid match type.')
	end
	
	if RunService:IsClient() then error("SetMode() can only be called from the server. Do not attempt to change it on the client.") end
	self[Mode] = MatchTypes[Mode]
	ReplicatedStorage:WaitForChild("Values"):WaitForChild("Gamemode").Value = Mode
	ReplicatedStorage.Values.GamemodeSet.Value = true
	
	for _, Team in pairs(MatchTypes[Mode].Teams) do
		local Folder = Instance.new("Folder")
		Folder.Name = Team.Name
		Folder.Parent = TeamsService
		
		function Team:GetPlayers()
			return GetPlayers(Team.Name)
		end
	end
end

function match:GetCurrentGamemode()
	return ReplicatedStorage:WaitForChild("Values"):WaitForChild("Gamemode").Value
end

function match:SetTeam(player : Player, Team : string)
	if not self:IsGamemodeSet() then error("A gamemode needs to be set before setting a player on a team.") end
	if RunService:IsClient() then error("SetTeam can only be called from the server.") end
	if Team then
		if not self[self:GetCurrentGamemode()].Teams[Team] then error('"'..Team..'" is not a valid team.') end
		
		local Object = Instance.new("ObjectValue")
		Object.Name = ""
		Object.Value = player
		Object.Parent = TeamsService[Team]
		
	else
		error("You need to provide a team.")
	end
end

function match:GetTeams()
	if not self:IsGamemodeSet() then error("A gamemode needs to be set before getting teams.") end
	
	local Teams = MatchTypes[self:GetCurrentGamemode()].Teams
	
	
	return Teams
end

function match:GetTeamFromPlayer(player : Player)
	if typeof(player) ~= "Instance" then return nil end
	if not player:IsA("Player") then return nil end -- Type checking lol
	if not self:IsGamemodeSet() then return nil end
	
	local Team
	
	for _, team in pairs(TeamsService:GetChildren()) do
		if team:IsA("Folder") then
			for _, Player in pairs(team:GetChildren()) do
				if Player:IsA("ObjectValue") then
					if Player.Value == player then
						return MatchTypes[match:GetCurrentGamemode()].Teams[team.Name]
					end
				end
			end
		end
	end
	
	return MatchTypes[match:GetCurrentGamemode()].Teams[player.Team.Name]
end

function match:AreOnSameTeam(... : Player)
	local args = {...}
	
	for i,v in pairs(args) do
		if typeof(v) ~= "Instance" then
			error("One of the arguments are not an instance.")
		end
		if not v:IsA("Player") then
			error("One of the arguments are not a player.")
		end
	end
	
	local FirstTeam = self:GetTeamFromPlayer(args[1])
	local IsOnSameTeam = true
	
	for i,v in pairs(args) do
		if self:GetTeamFromPlayer(v).Name ~= FirstTeam.Name then
			IsOnSameTeam = false
		end
	end
	
	return IsOnSameTeam
end

function match:AreTwoPlayersOnSameTeam(p1 : Player, p2 : Player)
	if not p1:IsA("Player") then error("First argument isn't a player.") end
	if not p2:IsA("Player") then error("Second argument isn't a player.") end
	local Player1Team = self:GetTeamFromPlayer(p1)
	local Player2Team = self:GetTeamFromPlayer(p2)
	if Player1Team.Name == Player2Team.Name then
		return true
	else
		return false
	end
end

function match:GetLeastPopulatedTeam()
	if not self:IsGamemodeSet() then error("A gamemode needs to be set before getting a team.") end
	local Teams = match:GetTeams()
	
	local TeamWithLeastPlayers : Team
	
	for _, Team in pairs(Teams) do
		
		if TeamWithLeastPlayers then
			
			if #TeamWithLeastPlayers:GetPlayers() > #Team:GetPlayers() then
				TeamWithLeastPlayers = Team
			end
		else
			TeamWithLeastPlayers = Team
		end
	end
   	
	return TeamWithLeastPlayers
	
end

function match:SetTeamSpawn(Team : string, Spawn : SpawnLocation)
	if not self:IsGamemodeSet() then error("A gamemode needs to be set before setting a team spawn.") end
	if RunService:IsClient() then error("SetTeamSpawn can only be called from the server.") end
	if Team then
		if not self[self:GetCurrentGamemode()].Teams[Team] then error('"'..Team..'" is not a valid team.') end
		if not Spawn then
			error("You need to provide a spawn location.")
		end
		
		if typeof(Spawn) ~= "Instance" then
			error("The provided spawn is not a spawn location.")
		end
		
		if not Spawn:IsA("SpawnLocation") then
			error("The provided spawn is not a spawn location.")
		end
		local Teams = self:GetTeams()
		
		Teams[Team].Spawn = Spawn
		
	else
		error("You need to provide a team.")
	end
end

function match:ResetTeams()
	if self:IsGamemodeSet() then
		if RunService:IsClient() then error("ResetTeams can only be called from the server.") end
		local Teams = TeamsService:GetTeams()
		
		for _,Team in pairs(Teams) do
			for _, PlayerValue in pairs(Team:GetChildren()) do
				PlayerValue:Destroy()
			end
		end
		
	else
		error("Set a gamemode first before resetting teams.")
	end
end

function match:GetTeamColor(name : string)
	if self:IsGamemodeSet() then
		local Teams = self:GetTeams()
		if Teams[name] then
			return Teams[name].Color
		else
			warn('"'..name..'" is not a valid team.')
		end
	else
		error("Set a gamemode first before getting a team color.")
	end
end

function match:GetTeamFromName(name : string)
	if self:IsGamemodeSet() then
		local Teams = self:GetTeams()
		if Teams[name] then
			local AllTeams = TeamsService:GetTeams()
			local TeamServiceName 
			
			for _, b in pairs(AllTeams) do
				if b.Name == name then
					TeamServiceName = b
				end
			end
			
			return Teams[name]
			
		else
		warn('"'..name..'" is not a valid team.')
		end
	end
end

function match:SetRound(round : number)
	if RunService:IsClient() then
		error("SetRound() can only be called on the server.")
	else
		if not tonumber(round) then error('"'..round..'" is not a number.') end
		ReplicatedStorage.Values.Round.Value =  round
	end
end

function match:GetPlayersFromTeam(team : string)
	if self:IsGamemodeSet() then
		local Teams = self:GetTeams()
		if Teams[team] then
			return TeamsService[team]:GetPlayers()
		else
			warn('"'..team..'" is not a valid team.')
		end
	else
		error("Set a gamemode first before getting the players from a team.")
	end
end

function match:GetRound()
	return ReplicatedStorage.Values.Round.Value
end

function match:GetPreviousRounds()
	return match.PreviousRounds
end

function match:IsRoundActive()
	return ReplicatedStorage.Values.RoundActive.Value
end

function match:ConcludeRound(team)
	if self:IsGamemodeSet() then
		if RunService:IsServer() then
			LoadingModule:SpawnLoadingScreen()
			LoadingModule:SetLoadingText(Tips:GetTip())
			
			if not self:IsValidTeam(team) then
				error('"'..team..'" is not a valid team.')
			end
			
			table.insert(match.PreviousRounds, team)
			
			match:SetRound(match:GetRound() + 1)
			
			local RoundFunctions = require(ServerScriptService.Modules.Utilities.ServerRoundInstaller.RoundFunctions)
			
			if not match:ValidateResults() then
				RoundFunctions:StartNewRound()
			end
			
			
		else
			error("Do not attempt to conclude the round from the client. This may break things.")
		end
	else
		error("Set a gamemode first before concluding the round.")
	end
end

function match:GetAllPlayers() -- Do not use PlayersService:GetPlayers() because we plan to add spectators soon and we do not want to return spectators
	local Teams = self:GetTeams()
	
	local Players = {}
	
	for _, Team in pairs(Teams) do
		
		for _, Player in pairs(Team:GetPlayers()) do
			table.insert(Players, Player)
		end
		
	end
	
	return Players
	
end

function match:End(Winner)
	if RunService:IsClient() then
		task.wait(2)
		if Winner == "Draw" then
			Platform:PlayAnimation("MatchEndedAnim")
			LoadingModule:RemoveLoadingScreen()
			print("Game was a draw")
		else
			local WinningTeam = match:GetTeamFromName(Winner)
			local WinningPlayers = WinningTeam:GetPlayers()
			
			Platform:PlayAnimation("MatchEndedAnim")

			print(WinningPlayers)
			LoadingModule:RemoveLoadingScreen()
		end
	else
		EndRemote:FireAllClients(Winner)
		
		local WinningTeam = match:GetTeamFromName(Winner)
		local WinningPlayers = WinningTeam:GetPlayers()
		local winningspots = workspace.Contents.Map.Pole.VictoryParts
		local using = {}
		
		if #WinningPlayers == 2 then
			table.insert(using, winningspots["2"])
			table.insert(using, winningspots["4"])
		else
			for _, spot in pairs(winningspots:GetChildren()) do
				table.insert(using, spot)
			end
		end
		
		for num, player : Player in pairs(WinningPlayers) do
			
			local D = d.MakeDummy(Enum.HumanoidRigType.R6)
			D.PrimaryPart.CFrame = using[num].CFrame + Vector3.new(0, 2, 0)
			local Hum = D:FindFirstChildWhichIsA("Humanoid")
			local Description
			Description = GetDescription(player.UserId)
			D.Parent = workspace.Contents.Live.Ragdolls
			if Description then Hum:ApplyDescription(Description) end
			local track = Hum.Animator:LoadAnimation(ReplicatedStorage.Animations.player_Idle)
			track.Looped = true
			track:Play()
		end
	end
end

function match:ValidateResults()
	if RunService:IsClient() then error("Do not validate results from the client.") end
	if not match:GetCurrentGamemode() then error("Set a gamemode first before validating results.") end
	
	local teams = match:GetTeams()
		
	for _, team  in pairs(teams) do
		local TotalWins = 0
		
		for _, win in pairs(match.PreviousRounds) do
			if win == team.Name then
				TotalWins += 1
			end
		end
		
		
		if (TotalWins / MatchTypes[match:GetCurrentGamemode()].TotalRounds) > 0.5 then -- If a team has more wins than half of the total amount of rounds then they win
			match:End(team.Name)
			return true
		end
	end
	
	if MatchTypes[match:GetCurrentGamemode()].TotalRounds < match:GetRound() then
		if not match:WasSuddenDeathInitiated() then
			local RoundFunctions = require(ServerScriptService.Modules.Utilities.ServerRoundInstaller.RoundFunctions)
			
			RoundFunctions:InitiateSuddenDeath()
		else
			match:End("Draw")
		end
	end
end 

function match.Subscribe()
	if RunService:IsClient() then
		if not ReplicatedStorage.Values.IsServerReady.Value then ReplicatedStorage.Values.IsServerReady.Changed:Wait() end
		
		for _, Team in pairs(match:GetTeams()) do
			function Team:GetPlayers()
				return GetPlayers(Team.Name)
			end
		end
		
		EndRemote.OnClientEvent:Connect(function(winner)
			match:End(winner)
		end)
	end
end
 
-- //

return match