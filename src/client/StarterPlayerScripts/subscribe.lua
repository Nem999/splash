-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")

-- // Neutrals
local Util = ReplicatedStorage.Modules.Utilities
local Modules = ReplicatedStorage.Modules
local LocalPlayer = PlayersService.LocalPlayer

--[[
	Description: Listens to connections coming from modules
]]

local vfx = require(Modules.FightingModules.Effects.vfx)

vfx.Subscribe()

local Player = require(Util.Player)

Player.Subscribe()

local blur = require(Modules.FightingModules.Effects.blurscreen)

blur.Subscribe()

local GetMatchStatus = require(Util.GetMatchStatus)

GetMatchStatus.Subscribe()

return 1
