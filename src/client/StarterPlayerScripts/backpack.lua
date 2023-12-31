game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false) -- Disable default backpack
--// Services
local uis = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local GuiSerivce = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local PlayersService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Modules
local DragableUI = require(ReplicatedStorage.Modules.Utilities.Gui.GuiDragger)
local Flags = require(ReplicatedStorage.Modules.Utilities.flags)

--// Player Variables
local player = PlayersService.LocalPlayer
local bp = player:FindFirstChild("Backpack")
local char = player.Character
local hum:Humanoid

--// Values
local w = false
local p = false
local b = false
local EQUIP_COOLDOWN = .1 -- Change it to whatever you'd like; it has to be a number 
local InventoryIsOpen = false
local equipped = 0.8 -- Background transparency for the equipped slot uses
local unequipped = 0.9 -- Background transparency for unequipped slots
local iconBorder = {x = 15, y = 5} 
local canEquip = true
local selected = 1
local XBOX_EQUIP_KEYCODE = Enum.KeyCode.DPadDown
local PC_EQUIP_KEYCODE = Enum.KeyCode.Backquote
local avgTweenTime = 1

--// Variables
local BackpackGui = script:WaitForChild("BackpackGui")
local frame = BackpackGui:WaitForChild("Slot")
local template = frame.BG
local iconSize = template.Size
local Action = "EquipLeft"
local Action2 = "EquipRight"
local Action3 = "OpenINV"
local toShow
local InInventory = false
local dragging
local CurrentSlot
local BPON
local HotbarSlotsBeingAnimated 

--/ States / Statuses

local State = true

-------------------------------------------------------------------------

if char then
	hum = char:WaitForChild("Humanoid")
end


frame.Visible = true

local inputKeys = { 
	["One"] = {txt = "1"},
	["Two"] = {txt = "2"},
	["Three"] = {txt = "3"},
	["Four"] = {txt = "4"},
	["Five"] = {txt = "5"},
	["Six"] = {txt = "6"},
	["Seven"] = {txt = "7"},
	["Eight"] = {txt = "8"},
	["Nine"] = {txt = "9"},
}

local inputKeysX = { 
	["1"] = {txt = "One"},
	["2"] = {txt = "Two"},
	["3"] = {txt = "Three"},
	["4"] = {txt = "Four"},
	["5"] = {txt = "Five"},
	["6"] = {txt = "Six"},
	["7"] = {txt = "Seven"},
	["8"] = {txt = "Eight"},
	["9"] = {txt = "Nine"},
}

local inputOrder = { 
	inputKeys["One"],inputKeys["Two"],inputKeys["Three"],inputKeys["Four"],inputKeys["Five"],inputKeys["Six"],inputKeys["Seven"],inputKeys["Eight"],inputKeys["Nine"]
}

local BackpackTable = {}
local HotbarTable = {}
local FrameTable = {}
local BPFrameTable = {}
local DragabbleTable = {}
local MetaTable = {}
local self = {}
MetaTable.__index = self
setmetatable(self, MetaTable)

function AnimateLetters(Text, time, TextLabel:TextLabel)
	local Previous 
	local Text = string.split(Text, "")
	for i,v in ipairs(Text) do
		if not Previous then Previous = "" end
		TextLabel.Text = Previous..v
		Previous = TextLabel.Text

		task.wait(Random.new():NextNumber(time, time / 2))
	end
end


function self:ForceRemoveSlot(Slot:Tool) -- You need to call Build() right after because it will automatically adjust all slots
	if not Slot then return end
	for i,v in pairs(inputOrder) do
		if v.tool == Slot then
			v.tool = nil
		end
		for i = 1, #HotbarTable do
			if HotbarTable[i] == Slot then
				table.remove(HotbarTable, i)
			end
		end
	end
end

function self:AddToolToBackpack(Tool:Tool)
	if not Tool then return end
	local tools = bp:GetChildren()
	if char:FindFirstChildWhichIsA("Tool") then table.insert(tools, char:FindFirstChildWhichIsA("Tool")) end
	table.insert(BackpackTable, {tool = Tool, txt = #tools})
end

function self:RemoveToolFromBackpack(Tool:Tool)
	if not Tool then return end
	for i, item in ipairs(BackpackTable) do
		if BackpackTable[i]["tool"] == Tool then
			for num, index in pairs(BackpackTable) do
				if tonumber(BackpackTable[num].txt) > tonumber(BackpackTable[i].txt) then
					BackpackTable[num].txt = tonumber(BackpackTable[num].txt) - 1
				end
			end
			table.remove(BackpackTable, i)
		end
	end
end

function self:AddHotbarSlot(Tool:Tool)
	if not Tool then return end
	for i = 1, #inputOrder do
		local tool = inputOrder[i]["tool"]
		if not tool then 
			inputOrder[i]["tool"] = Tool
			table.insert(HotbarTable, Tool)
			break
		end

	end
end

function self:Swap(Tool1:Tool, Tool2:Tool)
	if not Tool1 and Tool2 then return end
	local Hotbar1
	local Hotbar2
	for i,v in pairs(HotbarTable) do
		if v == Tool1 then
			Hotbar1 = v
		end
		if v == Tool2 then
			Hotbar2 = v
		end
	end
	if Hotbar1 and Hotbar2 then -- Swap if both tools are in hotbar
		local loc = table.find(HotbarTable, Hotbar1)
		local loc2 = table.find(HotbarTable, Hotbar2)
		HotbarTable[loc] = Hotbar2
		HotbarTable[loc2] = Hotbar1
		inputOrder[loc2].tool = Hotbar1
		inputOrder[loc].tool = Hotbar2
	elseif Hotbar1 and not Hotbar2 then -- Swap from hotbar
		local loc
		for i, item in ipairs(BackpackTable) do
			if item.tool == Tool2 then
				Hotbar2 = item.tool
				loc = item
			end
		end
		local loc2 = table.find(HotbarTable, Hotbar1)
		if not loc or not loc2 then return end
		loc.tool = Hotbar1
		HotbarTable[loc2] = Hotbar2
		inputOrder[loc2].tool = Hotbar2
	elseif not Hotbar1 and Hotbar2 then -- Swap from backpack
		local loc
		for i, item in ipairs(BackpackTable) do
			if item.tool == Tool1 then
				Hotbar1 = item.tool
				loc = item
			end
		end
		local loc2 = table.find(HotbarTable, Hotbar2)
		if not loc or not loc2 then return end
		loc.tool = Hotbar2
		HotbarTable[loc2] = Hotbar1
		inputOrder[loc2].tool = Hotbar1
	elseif not Hotbar1 and not Hotbar2 then -- Swap if both tools are in the backpack
		local Slot1
		local Slot2
		for i, item in ipairs(BackpackTable) do
			if BackpackTable[i]["tool"] == Tool1 then
				Slot1 = BackpackTable[i]
			end
		end
		for i, item in ipairs(BackpackTable) do
			if BackpackTable[i]["tool"] == Tool2 then
				Slot2 = BackpackTable[i]
			end
		end
		if Slot1 and Slot2 then
			local Tool = Slot1.tool
			local Tool1 = Slot2.tool
			Slot2.tool = Tool
			Slot1.tool = Tool1
		end
	end

end

function Search() -- Searches for the requested tool in the inventory
	local Text = string.lower(BackpackGui.Search.TextBox.Text)
	for i,Frame in pairs(BPFrameTable) do
		Frame.Visible = false
		if string.match(string.lower(Frame.Tool.Value.Name), "^"..Text) then
			Frame.Visible = true
		end
	end
	if Text == "" then
		for i,Frame in pairs(BPFrameTable) do
			Frame.Visible = true
		end
	end
end

function handleAddition(adding) -- Adds a tool to the tool table if I detect a new tool has been added
	if adding:IsA("Tool") then
		local new = true
		for key, value in pairs(inputKeys) do
			local tool = value["tool"]
			if tool then
				if tool == adding then
					new = false
				end
			end
		end
		for i,value in pairs(BackpackTable) do
			local tool = value["tool"]
			if tool then 
				if tool == adding then
					new = false
				end
			end
		end

		if new then
			local tools = HotbarTable
			if #tools >= 9 then self:AddToolToBackpack(adding) Build() bpadjust() else self:AddHotbarSlot(adding) Build() adjust() end
		else
			local inhotboar
			for i,v in pairs(inputOrder) do
				if v["tool"] == adding then
					inhotboar = true
					break
				end
			end
			if inhotboar then
				--adjust()
			else
				bpadjust()
			end
		end
	end
end

function handleEquip(tool) -- Equips tools
	if State == false then return end
	if tool then
		if tool.Parent ~= char then
			hum:EquipTool(tool)
		else
			hum:UnequipTools()
		end
	end
end

local CurrentlyDragging = false

function create(SelectedTool) -- Creates all tool slots and their icon names / images. It also determines what position its supposed to be in.
	local BPSlot = BackpackGui:FindFirstChild("Slot")
	if not BPSlot then return end -- Game is shutting down
	for i,v in pairs(BPSlot:GetChildren()) do
		if v.Name:match("|") then
			v:Destroy()
		end
	end
	for i,v in pairs(BackpackGui.Backpack.Frame:GetChildren()) do
		if v.Name:match("|") then
			v:Destroy()
		end
	end
	table.clear(FrameTable)
	table.clear(BPFrameTable)
	table.clear(DragabbleTable)
	toShow = #HotbarTable
	if toShow > 9 then toShow = 9 end
	local totalX = (toShow*iconSize.X.Offset)+((toShow+1)*iconBorder.x)
	local totalY = iconSize.Y.Offset + (2*iconBorder.y)
	frame.Size = UDim2.new(0, totalX, 0, totalY)
	frame.Position = UDim2.new(0.5, -(totalX/2), 1, -(totalY+(iconBorder.y*2)))
	frame.Visible = true 
	for i = 1, #inputOrder do
		local value = inputOrder[i]		
		local clone = template:Clone()
		local tool = value["tool"]
		local ToolTipIsBeingDisplayed = false
		clone.Parent = frame
		clone.Template.Label.Text = value["txt"]
		clone.Name = "| " ..value["txt"]
		clone.Visible = true
		clone.Position = UDim2.new(0, (i-1)*(iconSize.X.Offset)+(iconBorder.x*i), 0, iconBorder.y)
		clone.Template.ImageTransparency = unequipped
		task.spawn(function()
			if SelectedTool then
				RunService.Heartbeat:Wait()
				if SelectedTool == tool then GuiSerivce.SelectedObject = clone.ControllerFrame end
			end
		end)
		table.insert(FrameTable, clone)
		if InventoryIsOpen then clone.ControllerFrame.Selectable = true end
		if tool ~= nil then
			clone.Tool.Value = tool
			clone.Template.TextLabel.Text = tool.Name
			clone.ToolTips.ToolTip.ToolTipText.Text = tool.ToolTip
		else
			clone.Visible = false
		end
		if tool then
			clone.Template.Tool.Image = tool.TextureId
			if tool.TextureId ~= "" then
				clone.Template.TextLabel.Text = ""
			end
		end

		clone.ControllerFrame.SelectionGained:Connect(function()
			local ui 
			if InventoryIsOpen then 
				if tool and tool.ToolTip ~= "" then
					ToolTipIsBeingDisplayed = true
					clone.ToolTips.ToolTip.Visible = true
					if HotbarSlotsBeingAnimated then coroutine.close(HotbarSlotsBeingAnimated) end
					HotbarSlotsBeingAnimated = coroutine.create(function()
						AnimateLetters(tool.ToolTip, .04, clone.ToolTips.ToolTip.ToolTipText)
						HotbarSlotsBeingAnimated = nil
					end)
					coroutine.resume(HotbarSlotsBeingAnimated)
				end
			end
			ui = uis.InputBegan:Connect(function(input, processed)
				if input.KeyCode == Enum.KeyCode.ButtonA then
					if dragging ~= nil and dragging.Parent ~= nil then if dragging == tool then handleEquip(dragging) end self:Swap(tool, dragging) Build(dragging) dragging = nil else
						dragging = tool
						clone.UIStroke.Thickness = 2.5
					end
				elseif input.KeyCode == Enum.KeyCode.ButtonX then
					self:AddToolToBackpack(tool)
					self:ForceRemoveSlot(tool)
					Build(dragging)
				end
			end)
			local con 
			con = clone.ControllerFrame.SelectionLost:Connect(function()
				ui:Disconnect()
				con:Disconnect()
				if ToolTipIsBeingDisplayed == true then 
					ToolTipIsBeingDisplayed = false
					clone.ToolTips.ToolTip.Visible = false
				end
			end)
		end)
		clone.MouseEnter:Connect(function()
			if tool.ToolTip ~= "" and dragging == nil then  -- Going for an opening effect
				clone.ToolTips.ToolTip.Visible = true
				ToolTipIsBeingDisplayed = true
				if HotbarSlotsBeingAnimated then coroutine.close(HotbarSlotsBeingAnimated) end
				HotbarSlotsBeingAnimated = coroutine.create(function()
					AnimateLetters(tool.ToolTip, .04, clone.ToolTips.ToolTip.ToolTipText)
					HotbarSlotsBeingAnimated = nil
				end)
				coroutine.resume(HotbarSlotsBeingAnimated)
			end
			if not CurrentlyDragging then return end
			if dragging == tool then return end
			CurrentSlot = tool
		end)
		clone.MouseLeave:Connect(function()
			if ToolTipIsBeingDisplayed then 
				clone.ToolTips.ToolTip.Visible = false 
				ToolTipIsBeingDisplayed = false
			end
			if not CurrentlyDragging then return end
			if dragging == tool then return end
			CurrentSlot = nil

		end)
		
		if Flags.GetFlag("UseBackpackHotbarToolsDraggableFeature") then
			local Dragable = DragableUI.new(clone)
			Dragable:Enable()

			table.insert(DragabbleTable, Dragable)

			Dragable.DragStarted = function()
				if uis.TouchEnabled then
					if InventoryIsOpen == false then Dragable:Disable() return end
				end
				if dragging then return end
				for i,v in pairs(DragabbleTable) do
					if v ~= Dragable then
						v:Disable()
					end
				end
				dragging = value["tool"]
				CurrentlyDragging = true
				clone.Template.Position = UDim2.new()
				clone.UIStroke.Thickness = 2.5
			end
			Dragable.DragEnded = function()
				if dragging ~= tool then return end
				if clone:FindFirstChild("UIStroke") then
					clone.UIStroke.Thickness = 0
					clone.Template.Position = UDim2.new()
				end

				for i,v in pairs(DragabbleTable) do
					if v ~= Dragable then
						v:Enable()
					end
				end

				dragging = nil
				CurrentlyDragging = false
				if InInventory == false and CurrentSlot == nil then Build() elseif InInventory and not CurrentSlot then
					self:ForceRemoveSlot(tool)
					self:AddToolToBackpack(tool)
				end
				if CurrentSlot then	
					self:Swap(tool, CurrentSlot)
				end 
				CurrentSlot = nil
				Build()
			end
		end
		
		clone.Template.Tool.MouseButton1Click:Connect(function() 
			for key, value in pairs(inputKeys) do
				if "| "..value["txt"] == clone.Name then
					if State == false then return end
					handleEquip(value["tool"]) 
					canEquip = false
					task.wait(EQUIP_COOLDOWN)
					canEquip = true
				end 
			end
		end)
	end
	for i = 1, #BackpackTable do
		local value = BackpackTable[i]
		local tool = value["tool"]
		local clone = template:Clone()
		clone.Parent = BackpackGui.Backpack.Frame
		clone.Template.Label.Visible = false
		clone.Name = "| " ..i + 9
		clone.Visible = true
		clone.Template.ImageTransparency = unequipped
		clone.LayoutOrder = i
		table.insert(FrameTable, clone)
		table.insert(BPFrameTable, clone)

		task.spawn(function()
			if SelectedTool then
				RunService.Heartbeat:Wait()
				if SelectedTool == tool then GuiSerivce.SelectedObject = clone.ControllerFrame end
			end
		end)

		clone.Template.Tool.MouseButton1Click:Connect(function() 
			for key, value in pairs(BackpackTable) do
				if value["tool"] == tool then
					if State == false then return end
					handleEquip(value["tool"])
					canEquip = false
					task.wait(EQUIP_COOLDOWN)
					canEquip = true
				end 
			end
		end)

		if InventoryIsOpen then clone.ControllerFrame.Selectable = true end	
		if tool ~= nil then
			clone.Tool.Value = tool
			clone.Template.TextLabel.Text = tool.Name
		else
			clone.Visible = false

		end
		if tool then
			clone.Template.Tool.Image = tool.TextureId
			if tool.TextureId ~= "" then
				clone.Template.TextLabel.Text = ""
			end
		end

		clone.ControllerFrame.SelectionGained:Connect(function() -- Controller support
			local ui 
			ui = uis.InputBegan:Connect(function(input, processed)
				if input.KeyCode == Enum.KeyCode.ButtonA then
					if dragging ~= nil and dragging.Parent ~= nil then if dragging == tool then handleEquip(dragging) end self:Swap(tool, dragging) Build(dragging) dragging = nil else
						dragging = tool
						clone.Template.Position = UDim2.new()
						clone.UIStroke.Thickness = 2.5
					end
				elseif input.KeyCode == Enum.KeyCode.ButtonX then
					if #HotbarTable > 8 then return end
					self:RemoveToolFromBackpack(tool)
					self:AddHotbarSlot(tool)
					Build(dragging)
				end
			end)
			local con
			con = clone.ControllerFrame.SelectionLost:Connect(function()
				ui:Disconnect()
				con:Disconnect()
			end)
		end)


		clone.MouseEnter:Connect(function()
			if not CurrentlyDragging then return end
			if dragging == tool then return end
			CurrentSlot = tool
		end)
		clone.MouseLeave:Connect(function()
			if not CurrentlyDragging then return end
			if dragging == tool then return end
			CurrentSlot = nil
		end)
		local Dragable = DragableUI.new(clone)
		Dragable:Enable()
		local newfr
		Dragable.DragStarted = function()
			if dragging then return end
			for i,v in pairs(DragabbleTable) do
				if v ~= Dragable then
					v:Disable()
				end
			end
			if uis.TouchEnabled then
				BackpackGui.Backpack.Frame.ScrollingEnabled = false
			end
			dragging = tool
			CurrentlyDragging = true
			newfr = clone:Clone()
			local pos = uis:GetMouseLocation()
			newfr.Parent = clone.Parent
			clone.Parent = BackpackGui
			clone.Position = UDim2.new(0, pos.X - 25 , 0, pos.Y - 60)
			newfr.LayoutOrder -= 1
			newfr.Transparency = 1
			newfr.UIStroke.Thickness = 0
			newfr.Template.BackgroundTransparency = 1
			newfr.Template.Tool.ImageTransparency = 1
			newfr.Template.Label.Visible = false
			newfr.Template.TextLabel.Visible = false
			clone.UIStroke.Thickness = 2.5
			clone.Template.Position = UDim2.new()
		end
		Dragable.DragEnded = function()
			if dragging ~= tool then return end
			BackpackGui.Backpack.Frame.ScrollingEnabled = true
			dragging = nil
			CurrentlyDragging = false
			clone.UIStroke.Thickness = 0
			clone.Template.Position = UDim2.new()
			clone:Destroy()
			if InInventory == true and CurrentSlot == nil then Build() elseif InInventory == false and not CurrentSlot then
				if #HotbarTable == 9 then Build() return end
				self:RemoveToolFromBackpack(tool)
				self:AddHotbarSlot(tool)
			end 
			if CurrentSlot then
				self:Swap(tool, CurrentSlot)
			end 
			CurrentSlot = nil
			Build()
		end

	end	
	adjust()
	bpadjust()
	if InInventory then
		for i,v in pairs(FrameTable) do
			v.ControllerFrame.Selectable = true
		end
	end
end

function Build(WithSelected) -- Will be called if we need to build the Gui
	
	if uis.TouchEnabled and Flags.GetFlag("BackpackInventoryEnabled") then -- Set the inventory button visible if the player is on a mobile device otherwise make it invisible
		BackpackGui:WaitForChild("InvetoryButton").Visible = true	
	else
		BackpackGui:WaitForChild("InvetoryButton").Visible = false	
	end
	
	local tools = HotbarTable
	for i,v in pairs(BackpackTable) do
		if table.find(tools, v) then
			table.remove(tools, v)
		end
	end
	for i = 1, #tools do 
		if tools[i]:IsA("Tool") then 
			for i = 1, #inputOrder do
				local value = inputOrder[i]
				if not value["tool"] then 
					value["tool"] = tools[i]
					break 
				end
			end
		end
	end
	for i,v in pairs(inputOrder) do -- This loops through the players backpack and detects if a tool is missing from our tool table and takes all the tools that were above it and subtracts 1; It basically moves tools to the left if a tool was deleted or missing.
		local tool = v['tool']
		if tool then
			local num = v.txt
			if tool then
				for i = 1, #inputOrder do
					local value = inputOrder[i]
					if i == tonumber(num) then
						continue
					else
						if value["tool"] == tool then
							value["tool"] = nil
							for number,v in pairs(inputOrder) do
								if number > i then
									local slide = v['tool']
									if slide then
										v['tool'] = nil
										inputOrder[number - 1]['tool'] = slide
									end
								end
							end
						end
					end
				end
			end
		end

	end
	create(WithSelected)
end

local DeadColor = Color3.fromRGB(30, 38, 128)
local AliveColor = Color3.fromRGB(71, 89, 255)
local ImageTransparency = BackpackGui.Slot.BG.Template.Tool.ImageTransparency

function adjust() -- Adjust tool icons and their UI strokes
	for key, value in pairs(inputKeys) do
		local tool =  value["tool"]
		local icon = frame:FindFirstChild("| " ..value["txt"])
		if tool then
			if icon then
				icon.Template.Tool.Image = tool.TextureId
			end
			if tool.Parent == char then 
				if icon then
					if BPON then BPON = nil bpadjust() end
					selected = tonumber(value['txt'])
					TweenService:Create(icon.Template, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = equipped }):Play()
					TweenService:Create(icon.Template.Tool, TweenInfo.new(.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0}):Play()
					--icon.Template.BackgroundTransparency = equipped
					TweenService:Create(icon.Template, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {ImageTransparency = equipped }):Play()
					TweenService:Create(icon.Template.UIStroke, TweenInfo.new(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Color = AliveColor }):Play()
					TweenService:Create(icon.Template.UIStroke, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Transparency = 0 }):Play()
					-- Move the Frame in an upwards motion
					TweenService:Create(icon.Template,  TweenInfo.new(.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Position =  UDim2.new(icon.Template.Position.X.Scale, icon.Template.Position.X.Offset, BackpackGui.Slot.BG.Template.Position.Y.Scale - 0.1, icon.Template.Position.Y.Offset)}):Play()
					--icon.Template.ImageTransparency = equipped
					-- icon.Template.UIStroke.Thickness = 1.8
				end
			else
				if icon then
					TweenService:Create(icon.Template.Tool, TweenInfo.new(.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = ImageTransparency}):Play()
					TweenService:Create(icon.Template, TweenInfo.new(avgTweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = unequipped }):Play()
					TweenService:Create(icon.Template, TweenInfo.new(avgTweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {ImageTransparency = unequipped }):Play()
					TweenService:Create(icon.Template.UIStroke, TweenInfo.new(.7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Color = DeadColor }):Play()
					TweenService:Create(icon.Template.UIStroke, TweenInfo.new(.7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Transparency = 0.3 }):Play()
					TweenService:Create(icon.Template,  TweenInfo.new(.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Position =  UDim2.new(icon.Template.Position.X.Scale, icon.Template.Position.X.Offset, BackpackGui.Slot.BG.Template.Position.Y.Scale, icon.Template.Position.Y.Offset)}):Play()
					--icon.Template.BackgroundTransparency = unequipped
					--icon.Template.ImageTransparency = unequipped
					--icon.Template.UIStroke.Thickness = 0
				end
			end
		else
			if icon then
				icon.Template.Tool.Image = ""
				TweenService:Create(icon.Template.Tool, TweenInfo.new(.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = ImageTransparency}):Play()
				TweenService:Create(icon.Template, TweenInfo.new(avgTweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = unequipped }):Play()
				--icon.Template.BackgroundTransparency = unequipped
				TweenService:Create(icon.Template, TweenInfo.new(avgTweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {ImageTransparency = unequipped }):Play()
				TweenService:Create(icon.Template.UIStroke, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Color = DeadColor }):Play()
				TweenService:Create(icon.Template.UIStroke, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Transparency = 0.3 }):Play()
				--icon.Template.ImageTransparency = unequipped
				--icon.Template.UIStroke.Thickness = 0
			end
		end
	end
end

function bpadjust() -- Be careful when calling Backpack adjust because if we have hundreds of tools it can lag so only call when we know for a fact our tool is in the inventory
	for key, value in pairs(BackpackTable) do
		local tool = value["tool"]
		local icon
		for i,v in pairs(BackpackGui.Backpack.Frame:GetChildren()) do
			if v:IsA("Frame") then
				if v.Tool.Value == tool then
					icon = v
					break
				end
			end
		end

		if tool then
			if icon then
				icon.Template.Tool.Image = tool.TextureId
			end
			if tool.Parent == char then 
				if icon then
					BPON = icon
					TweenService:Create(icon.Template, TweenInfo.new(.3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {BackgroundTransparency = equipped }):Play()
					TweenService:Create(icon.Template, TweenInfo.new(.3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {ImageTransparency = equipped }):Play()
					TweenService:Create(icon.Template.UIStroke, TweenInfo.new(.7, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Color = AliveColor }):Play()
					-- icon.Template.BackgroundTransparency = equipped
					--icon.Template.ImageTransparency = equipped
					-- icon.Template.UIStroke.Thickness = 1.8
				end
			else
				if icon then
					TweenService:Create(icon.Template, TweenInfo.new(avgTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {BackgroundTransparency = unequipped }):Play()
					TweenService:Create(icon.Template, TweenInfo.new(avgTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {ImageTransparency = unequipped }):Play()
					TweenService:Create(icon.Template.UIStroke, TweenInfo.new(.7, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Color = DeadColor }):Play()
					--icon.Template.BackgroundTransparency = unequipped
					--icon.Template.ImageTransparency = unequipped
					--icon.Template.UIStroke.Thickness = 0
				end
			end
		else
			if icon then
				icon.Template.Tool.Image = ""
				TweenService:Create(icon.Template, TweenInfo.new(avgTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {BackgroundTransparency = unequipped }):Play()
				TweenService:Create(icon.Template, TweenInfo.new(avgTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {ImageTransparency = unequipped }):Play()
				TweenService:Create(icon.Template.UIStroke, TweenInfo.new(.7, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Color = DeadColor }):Play()
				--icon.Template.BackgroundTransparency = unequipped
				--icon.Template.ImageTransparency = unequipped
				--icon.Template.UIStroke.Thickness = 0
			end
		end
	end
end

function onKeyPress(inputObject)  -- Do stuff when we press a key on our keyboard
	if canEquip == false then
		return
	end
	if State == false then return end
	local key = inputObject.KeyCode.Name
	local value = inputKeys[key]
	if value and uis:GetFocusedTextBox() == nil then 
		handleEquip(value["tool"])
		selected = tonumber(value.txt)
	end 
	canEquip = false
	task.wait(EQUIP_COOLDOWN) -- Small equip cooldown
	canEquip = true 
end

function cycleLeft(actionName, inputState, inputObject) -- Cycles equipped item to the left used for Xbox controllers
	if inputState == Enum.UserInputState.Begin then
		local total = tostring(#HotbarTable + 1)
		if canEquip == false then
			return
		end	
		if State == false then return end
		if selected == 0 then
			selected = total
		end
		local key = tostring(selected - 1)
		if tonumber(key) <= 0 then
			hum:UnequipTools()
			if p == false then
				selected = total 
			else
			end
			return
		end
		p = false
		local keyt = inputKeysX[key].txt
		local value = inputKeys[keyt]
		if value and uis:GetFocusedTextBox() == nil then 
			handleEquip(value["tool"])
			selected = value.txt
		end 
		canEquip = false
		task.wait(EQUIP_COOLDOWN)
		canEquip = true
	end
end

function cycleRight(actionName, inputState, inputObject) -- Cycles equipped item to the right used for Xbox controllers
	if inputState == Enum.UserInputState.Begin then
		if canEquip == false then return
		end
		if State == false then return end
		local total = tostring(#HotbarTable + 1)
		if selected == tostring(total) then
			selected = 0
		end
		local key = tostring(selected + 1)
		if selected == 1 or selected == 0 then
			key = tostring(1)
		end
		local totalnum = #HotbarTable + 1
		if tonumber(key) >= totalnum then
			hum:UnequipTools()
			if w == false then
				selected = 0
			end
			return
		end
		w = false
		local keyt = inputKeysX[key].txt
		local value = inputKeys[keyt]
		if value and uis:GetFocusedTextBox() == nil then 
			handleEquip(value["tool"])
			selected = value.txt
		end 
		canEquip = false
		task.wait(EQUIP_COOLDOWN)
		canEquip = true
	end
end


function handleRemoval(removing) -- Removes a tool from our tool table if there is a tool that is getting deleted
	if removing:IsA("Tool") then
		if removing.Parent ~= char and removing.Parent ~= bp then
			for i = 1, #HotbarTable do
				if HotbarTable[i] == removing then
					table.remove(HotbarTable, i)
				end
			end	
			self:RemoveToolFromBackpack(removing)		
			for i = 1, #inputOrder do
				if inputOrder[i]["tool"] == removing then
					inputOrder[i]["tool"] = nil
					break
				end
			end
			Build()
		end
		adjust()
	end
end



ContextActionService:BindAction(Action, cycleLeft, false, Enum.KeyCode.ButtonL1)
ContextActionService:BindAction(Action2, cycleRight, false, Enum.KeyCode.ButtonR1)

--- Inventory Section

local InventoryButton = BackpackGui:WaitForChild("InvetoryButton")
local SmallDB = false
local orgsize = BackpackGui:WaitForChild("Backpack").Size

function OpenInventory(actionName, inputState, inputObject) -- Open and close the inventory
	if actionName == Action3 and inputState == Enum.UserInputState.Begin then
		if State == false then return end
		if not Flags.GetFlag("BackpackInventoryEnabled") then return end
		if SmallDB then return end
		if not InventoryIsOpen then
			SmallDB = true
			local OrginalSize = BackpackGui.Backpack.Size.Y.Scale
			task.delay(1, function()
				SmallDB = false
			end)
			BackpackGui.Backpack.Visible = true
			BackpackGui.Search.Visible = true
			BackpackGui.Backpack.Size = UDim2.new(0.305, 0, 0, 0)
			BackpackGui.Search.BackgroundTransparency = 1
			BackpackGui.Search.TextBox.BackgroundTransparency = 1
			BackpackGui.Search.SearchIcon.ImageTransparency = 1
			TweenService:Create(BackpackGui.Backpack, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { Size = orgsize}):Play()
			TweenService:Create(BackpackGui.Search, TweenInfo.new(.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = .4}):Play()
			TweenService:Create(BackpackGui.Search.TextBox, TweenInfo.new(.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = .8}):Play()
			TweenService:Create(BackpackGui.Search.SearchIcon, TweenInfo.new(.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {ImageTransparency = 0}):Play()
			InventoryIsOpen = true
			for i,v in pairs(FrameTable) do
				v.ControllerFrame.Selectable = true
				if uis.TouchEnabled then Build() end
			end
		else
			SmallDB = true
			local OrginalSize = BackpackGui.Backpack.Size.Y.Scale
			task.delay(1, function()
				SmallDB = false
			end)
			BackpackGui.Backpack.Size = orgsize

			local Fade = TweenService:Create(BackpackGui.Backpack, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { Size = UDim2.new(0.305, 0, 0, 0)})
			local Fade1 = TweenService:Create(BackpackGui.Search, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 1})
			TweenService:Create(BackpackGui.Search.TextBox, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
			TweenService:Create(BackpackGui.Search.SearchIcon, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {ImageTransparency = 1}):Play()
			Fade:Play()
			Fade1:Play()
			Fade.Completed:Wait()
			InInventory = false
			BackpackGui.Backpack.Visible = false
			InventoryIsOpen = false
			Fade1.Completed:Wait()
			BackpackGui.Search.Visible = false
			for i,v in pairs(FrameTable) do
				v.ControllerFrame.Selectable = false
			end
		end
	end
end

BackpackGui.Backpack.MouseEnter:Connect(function() -- Lets us know when a player's mouse has entered the inventory
	InInventory = true
end)

BackpackGui.Backpack.MouseLeave:Connect(function() -- Lets us know when a player's mouse has left the inventory
	InInventory = false
end)


ContextActionService:BindAction(Action3, OpenInventory, false, PC_EQUIP_KEYCODE, XBOX_EQUIP_KEYCODE)


InventoryButton.MouseButton1Click:Connect(function() -- Player has pressed the inventory button
	OpenInventory(Action3, Enum.UserInputState.Begin)
end)


function self:Disable()
	State = false
	if dragging then Build() end
	for i,v in pairs(DragabbleTable) do
		v:Disable()
	end
	BackpackGui.Visible = false
	if hum then hum:UnequipTools() end
end

function self:Enable()
	State = true
	BackpackGui.Visible = true
	Build()
end

function self:SetBackpack(NewBP)
	
	table.clear(HotbarTable)
	for _, Tool in pairs(inputOrder) do
		Tool.tool = nil
	end
	for _, Tool in pairs(BackpackTable) do
		Tool.tool = nil
	end
	
	bp = NewBP
	bp.ChildAdded:Connect(handleAddition)
	bp.ChildRemoved:Connect(handleRemoval)
	bp.ChildAdded:Connect(adjust)
	for i,v in pairs(bp:GetChildren()) do -- Add any tools that are already in the player's backpack
		if v:IsA("Tool") then
			handleAddition(v)
		end
	end
end

player.ChildAdded:Connect(function(child) 
	if child.Name == "Backpack" then
		if bp then
			bp:Destroy()
			self:SetBackpack(child)
		else
			self:SetBackpack(child)
		end
	end
end)

player.CharacterAdded:Connect(function(c)
	char = c
	hum = c:WaitForChild("Humanoid")
	char.ChildAdded:Connect(handleAddition)
	char.ChildRemoved:Connect(handleRemoval)

end)

if char then
	char.ChildAdded:Connect(handleAddition)
	char.ChildRemoved:Connect(handleRemoval)
	hum = char:WaitForChild("Humanoid")
end

uis.InputBegan:Connect(onKeyPress)
if bp then
	bp.ChildAdded:Connect(handleAddition)
	bp.ChildRemoved:Connect(handleRemoval)
	bp.ChildAdded:Connect(adjust)
end
BackpackGui.Search.TextBox:GetPropertyChangedSignal("Text"):Connect(Search)
InventoryButton.Position = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset + 72, frame.Position.Y.Scale, frame.Position.Y.Offset - 5)
BackpackGui.Backpack.Position =  UDim2.new(InventoryButton.Position.Width.Scale - .154, 0, InventoryButton.Position.Height.Scale, InventoryButton.Position.Height.Offset - 45)
BackpackGui.Search.Position =  UDim2.new(BackpackGui.Backpack.Position.Width.Scale + .218 , BackpackGui.Backpack.Position.Width.Offset, BackpackGui.Backpack.Position.Height.Scale - .25, BackpackGui.Backpack.Position.Height.Offset)
if bp then
	for i,v in pairs(bp:GetChildren()) do -- Add any tools that are already in the player's backpack
		if v:IsA("Tool") then
			handleAddition(v)
		end
	end
end

Build() -- Build the Gui

BackpackGui.Parent = player.PlayerGui:WaitForChild("SplashGui")

return self