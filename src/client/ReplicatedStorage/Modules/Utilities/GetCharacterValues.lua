-- [[ SERVICES ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [[ VARIABLES ]]
local module = {}

-- [[ MODULES ]]
local Flags = require(ReplicatedStorage.Modules.Utilities.flags)

-- [[ FUNCTIONS ]]

function check(character : Model)
	assert(character, "Check failed: Character is nil")

	if not character:FindFirstChild("CharacterValues") then
		Flags:Log("Check failed: CharacterValues folder doesn't exist on provided character model.", script)
		 return false
	elseif not character.CharacterValues:FindFirstChild("Blocking")  then
		Flags:Log("Check failed: Blocking int does not exist on character model.", script)
		return false
	elseif not character.CharacterValues:FindFirstChild("LastDirection") then
		Flags:Log("Check failed: LastDirection does not exist on character model.", script)
		return false
	elseif not character.CharacterValues:FindFirstChild("Stunned") then
		Flags:Log("Check failed: Stunned bool does not exist on character model.", script)
		return false
	elseif not character.CharacterValues:FindFirstChild("Alive") then
		Flags:Log("Check failed: Alive bool does not exist on character model.", script)
		return false
	end
	
	return true
end


function module.IsBlocking(character : Model)
	if not check(character) then return end
	
	if character.CharacterValues.Blocking.Value <= 0 then
		return false
	elseif character.CharacterValues.Blocking.Value > 3 then
		return false
	else
		return true
	end	
	
end

function module.GetPlayerBlockingDirection(character : Model)
	
	--[[
		1 = Up,
		2 = Left,
		3 = Right,
		0 = Not blocking
	]]
	
	if not check(character) then return end
	
	if character.CharacterValues.Blocking.Value <= 0 then
		return 0
	elseif character.CharacterValues.Blocking.Value > 3 then
		return 0
	else
		return character.CharacterValues.Blocking.Value
	end
	
	
end

function module:SetBlockingDirection(character : Model, Direction : IntValue)
	
	if not check(character) then return end
	
	if typeof(Direction) ~= "number" then return end
	
	if Direction <= 0 then
		character.CharacterValues.Blocking.Value = 0
	elseif Direction > 3 then
		character.CharacterValues.Blocking.Value = 0
	else
		character.CharacterValues.Blocking.Value = Direction
	end
	
end

function module:IsValidDirection(Direction)
	local valid = true
	
	local Directions = {
		"Up", "Right", "Down", "Left"
	}
	
	if typeof(Direction) == "string" then
		if table.find(Directions, Direction) then
			return valid
		else
			return false
		end
	end
	
	if typeof(Direction) ~= "number" then valid = false end

	if Direction <= 0 then
		valid = false
	elseif Direction > 3 then
		valid = false
	end
	
	return valid
end

function module:ReadLastDirection(character):Vector3
	if not check(character) then return end
	
	return character.CharacterValues.LastDirection.Value
	
end

function module:IsPlayerAlive(character):boolean
	if not check(character) then return end
	
	return character.CharacterValues.Alive.Value
end

function module:SetPlayerState(character : Model, state : boolean)
	if not check(character) then return end
	
	character.CharacterValues.Alive.Value = state
end

function module:SetLastDirection(character : Model, Direction : Vector3)
	if not check(character) then return end
	
	if typeof(Direction) ~=  "Vector3" then return end
	
	character.CharacterValues.LastDirection.Value = Direction
	
end

return module
