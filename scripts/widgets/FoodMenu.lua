local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local TextButton = require "widgets/textbutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local TileBG = require "widgets/tilebg"
local pickyEater_InvSlot = require "widgets/pickyEater_invSlot"
local pickyEater_ItemTile = require "widgets/pickyEater_itemTile"
local pickyEater = require "components/PickyEater"
local screenwidth, screenheight = TheSim:GetScreenSize()

local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/templates"


local foodMenu = Class(Widget, function(self, owner)
	self.owner = owner
	Widget._ctor(self, "foodMenu")

	self.root = self:AddChild(Widget("ROOT"))
	self.root:SetVAnchor(ANCHOR_MIDDLE)
	self.root:SetHAnchor(ANCHOR_MIDDLE)
	self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.root:SetPosition(0,0,0)

	self.root_top = self:AddChild(Widget("ROOT"))
	self.root_top:SetVAnchor(ANCHOR_TOP)
	self.root_top:SetHAnchor(ANCHOR_MIDDLE)
	self.root_top:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.root_top:SetPosition(0,-80,0)
	self.root_top:SetMaxPropUpscale(MAX_HUD_SCALE)
	
	self.root_bottom = self:AddChild(Widget("ROOT"))
	self.root_bottom:SetVAnchor(ANCHOR_BOTTOM)
	self.root_bottom:SetHAnchor(ANCHOR_MIDDLE)
	self.root_bottom:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.root_bottom:SetPosition(0,-80,0)
	self.root_bottom:SetMaxPropUpscale(MAX_HUD_SCALE)
	
	self.menu = ThePlayer.components.PickyEater.menu
	self.progress = ThePlayer.components.PickyEater.progress
	
	self.boardShow = true
	self.menuShow = false
	self.controllerFocus = false    	
	
	self.inst:DoTaskInTime(1, function() 
		self.mode = ThePlayer.components.PickyEater.mode
		self.menuType = ThePlayer.components.PickyEater.menuType
		self.easy = ThePlayer.components.PickyEater.easy
		self.longterm = ThePlayer.components.PickyEater.longterm
		self.rare = ThePlayer.components.PickyEater.rare
		self.caves =  ThePlayer.components.PickyEater.caves	
		self.inst:DoTaskInTime(0.1, function() self:optionsDisplay() end)
		self.inst:DoTaskInTime(0.2, function() self:boardDisplay() end)			
		self.inst:DoTaskInTime(0.25, function() self:Rebuild() end)
		self.inst:DoTaskInTime(0.3, function() self:StartUpdating() end)		
	end)
end)

function foodMenu:OnUpdate(dt)
	if ThePlayer.components.PickyEater.update == true then
		ThePlayer.components.PickyEater.update = false
		if ThePlayer.components.PickyEater.reset == true then
			ThePlayer.components.PickyEater.reset = false
			self.inst:DoTaskInTime(0.2, function() self:boardDisplay() end)			
			self.inst:DoTaskInTime(0.25, function() self:Rebuild() end)
		else
			self:Rebuild()
		end
	end
end

function foodMenu:OnWinMessage(name,And,menuType,mode,easy,longterm,caves,rare,normal)
	self.win_bg = self.root_top:AddChild( Image("images/frontend.xml", "scribble_black.tex") )
	self.win_bg:SetScale(.8,.8,.8)
	self.win_bg:SetSize(540, 285)
	self.win_bg:SetPosition(0, -15, 0)
	self.win_bg:Hide()
		
	local wintext = (name .. " has completed their menu of " .. menuType .. "on " .. mode .. "with " .. easy .. longterm .. caves .. And .. rare .. normal .. " foods. Congratulations " .. name .. "!")
		
	self.win_bg:Show()	
				
	self.winText = self.win_bg:AddChild(Text(TALKINGFONT, 35))
	self.winText:SetPosition(0, 0, 0)
	self.winText:SetString(wintext)
	self.winText:EnableWordWrap(true)
	self.winText:SetRegionSize(500, 265)
	self.winText:SetColour(1,1,1,1)	

	self.inst:DoTaskInTime(8, function() self.win_bg:Kill() end)	
end

function foodMenu:OnGainFocus()
	if self.boardShow == true then
		if not self.optionsMenu:OnGainFocus() then
			self.boardArrowR:Show()
			self.crockHelpButton:Show()
			self.optionsMenuButton:Show()
		end
	end
end

function foodMenu:OnLoseFocus()
	if self.boardShow == true then
		self.boardArrowR:Hide()
		self.crockHelpButton:Hide()
		self.optionsMenuButton:Hide()
	end
	if self.boardShow ~= true and self.menuShow == false then
		self.crockHelpButton:Hide()
		self.optionsMenuButton:Hide()
	end
end

function foodMenu:Rebuild()
	if self.board.slots ~= nil then
		self.board.slots:Kill()
	end

	self.board.slots = self.board:AddChild(Widget("SLOTS"))

	if self.board.inv then
		for k,v in pairs(self.board.inv) do
			v:Kill()
		end
	end

	self.board.inv = {}

	local HUD_ATLAS = "images/hud.xml"

	local maxSlots = ThePlayer.components.PickyEater.limit

	local W = 66
	local H = 66
	local maxwidth = 1700
	local positions = 0
	local NUM_COLUMS = 10

	for k = 1, maxSlots do
		local inv_slot = "inv_slot.tex"

		if ThePlayer.components.PickyEater.progress[k] == 1 then
			inv_slot = "resource_needed.tex"
		end

		local height = math.floor(positions / NUM_COLUMS) * H
		local slot = pickyEater_InvSlot(k, HUD_ATLAS, inv_slot, self, ThePlayer.components.PickyEater.menu)
	 	self.board.inv[k] = self.board.slots:AddChild(slot)
		self.board.inv[k]:SetTile(pickyEater_ItemTile(ThePlayer.components.PickyEater.menu[k]))

		local remainder = positions % NUM_COLUMS
		local row = math.floor(positions / NUM_COLUMS) * H

		local x = W * remainder
		slot:SetPosition(x,-row,0)
		positions = positions + 1
	end
end

function foodMenu:optionsDisplay()	
	self.optionsMenu = self.root:AddChild( Image("images/ui.xml", "in-window_button_tile_idle.tex") )
	self.optionsMenu:SetScale(.9,.9,.9)
	if widg_loc == 1 then
		self.optionsMenu:SetPosition(0, -105, 0)			
	else
		self.optionsMenu:SetPosition(0, 100, 0)		
	end
	self.optionsMenu:SetSize(700, 440)
	self.optionsMenu:SetTint(0.9,.9,.9,0.8)
	self.optionsMenu:Hide()

	self.whiteline1 = self.optionsMenu:AddChild( Image("images/ui.xml", "line_horizontal_5.tex") )
	self.whiteline1:SetScale(1,1,1)
	self.whiteline1:SetPosition(15, 135, 0)
	self.whiteline1:SetSize(440, 2.5)
	self.whiteline1:SetTint(1,1,1,1)

	self.whiteline2 = self.optionsMenu:AddChild( Image("images/ui.xml", "line_horizontal_5.tex") )
	self.whiteline2:SetScale(1,1,1)
	self.whiteline2:SetPosition(-3, -131, 0)
	self.whiteline2:SetSize(640, 3.2)
	self.whiteline2:SetTint(1,1,1,0.9)

	self.bingoControlPan = self.optionsMenu:AddChild(TextButton())
	self.bingoControlPan:SetFont(TITLEFONT)
	self.bingoControlPan:SetText("Picky Eater Control Menu")
	self.bingoControlPan:SetPosition(5, 164, 0)
	self.bingoControlPan:SetTextSize(58)
	self.bingoControlPan:SetColour(0.25,0.25,0.25,1)
	self.bingoControlPan:SetClickable(false)
	
	self.resetBoardButton = self.optionsMenu:AddChild(ImageButton(UI_ATLAS, "button_large.tex", "button_large_over.tex", "button_large_disabled.tex", "button_large_onclick.tex"))		
	self.resetBoardButton:SetScale(0.9,.6,.75)
	self.resetBoardButton:SetPosition(0,-164,0)
	self.resetBoardButton:SetFont(BUTTONFONT)
	self.resetBoardButton:SetText("Reset")
	self.resetBoardButton:SetTextSize(45)
	if client_reset or TheNet:GetIsServerAdmin() then
		self.resetBoardButton:SetOnClick( function()
			self.resetBoardButton:SetClickable(false)
			SendModRPCToServer( MOD_RPC.PickyEater.reset,self.mode,self.menuType,self.easy,self.longterm,self.rare,self.caves )
			--self.inst:DoTaskInTime(1.7, function() self:boardDisplay() end)
			--self.inst:DoTaskInTime(1.8, function() self:Rebuild() self:UpdateText() end)
			self.inst:DoTaskInTime(1.5, function() self.resetBoardButton:SetClickable(true) end)
		end)
	else
		self.resetBoardButton:SetTooltip("No manual reset allowed! Sorry, bud.")
	end

	self:checkBoxes()
	self:text()
end

function foodMenu:boardDisplay()
	if self.boardParent and self.boardParent ~= nil then
		if self.boardShow == false then
			self.boardShow = true
			self.board:Show()
			self.boardBG:Show()
			self.boardTitle:Show()
			self.boardArrow2:SetTooltip('hide board')
			self.boardArrowR:SetTooltip('hide board')
			if widg_loc == 2 then
				self.boardArrow2:Hide()
				self.boardArrowR:Show()
			end
		end
		self.boardParent:Kill()
		self:Rebuild()
	end
	
	if widg_loc == 1 then
		self.boardParent = self.root_top:AddChild( Image("images/ui.xml", "blank.tex") )
	end
	if widg_loc == 2 then
		self.boardParent = self.root_bottom:AddChild( Image("images/ui.xml", "blank.tex") )
	end
	self.boardParent:SetSize(1, 1,0)
	self.boardParent:SetScale(1,1,1)
	if widg_loc == 1 then
		self.boardParent:SetPosition(0, -48, 0)				
	else
		if ThePlayer.components.PickyEater.limit <= 10 then
			self.boardParent:SetPosition(0, 100, 0)			
		elseif ThePlayer.components.PickyEater.limit <= 20 then
			self.boardParent:SetPosition(0, 140, 0)			
		elseif ThePlayer.components.PickyEater.limit <= 30 then
			self.boardParent:SetPosition(0, 175, 0)			
		else
			self.boardParent:SetPosition(0, 140, 0)			
		end		
	
	--[[
		if ThePlayer.components.PickyEater.limit <= 10 then
			self.boardParent:SetPosition(0, -613, 0)			
		elseif ThePlayer.components.PickyEater.limit <= 20 then
			self.boardParent:SetPosition(0, -575, 0)			
		elseif ThePlayer.components.PickyEater.limit <= 30 then
			self.boardParent:SetPosition(0, -537, 0)			
		else
			self.boardParent:SetPosition(0, -500, 0)			
		end	
		
	--]]
	end
	self.boardBG = self.boardParent:AddChild( Image("images/ui.xml", "black.tex") )
	self.boardBG:SetScale(1,1,1)
	self.boardBG:SetTint(1,1,1,0.6)

	if ThePlayer.components.PickyEater.limit <= 10 then
		self.boardBG:SetSize(390, 80)
		self.boardBG:SetPosition(-1,78,0) 
	elseif ThePlayer.components.PickyEater.limit <= 20 then
		self.boardBG:SetSize(390, 120)
		self.boardBG:SetPosition(-1,60,0) 
	elseif ThePlayer.components.PickyEater.limit <= 30 then
		self.boardBG:SetSize(390, 155)
		self.boardBG:SetPosition(-1,40,0)
	else
		self.boardBG:SetSize(390, 193)
		self.boardBG:SetPosition(-1,21,0)
	end

	self.board = self.boardParent:AddChild( Image("images/ui.xml", "blank.tex") )
	self.board:SetScale(.57,.57,.57)
	self.board:SetPosition(-170,62,0)
---[[
	self.boardArrowR = self.boardParent:AddChild(ImageButton(UI_ATLAS, "red_star.tex", "red_star.tex", "red_star.tex"))
	self.boardArrowR:SetScale(1.5,1.5,1.5)
	self.boardArrowR:SetPosition(150,100,0)	
	self.boardArrowR:SetTooltip("hide board (" .. Toggle_Key .. ")")
	self.boardArrowR:SetTooltipPos(0, 8, 0)
	self.boardArrowR:Hide()
	self.boardArrowR:SetOnClick( function() 
		if self.boardShow == true then
			self.boardShow = false
			self.board:Hide()
			self.boardBG:Hide()
			self.boardTitle:Hide()
			self.boardArrowR:SetTooltip('show board')
			if widg_loc == 2 then
				self.boardArrow2:Show()
				self.boardArrowR:Hide()
			end
		else
			self.boardShow = true
			self.board:Show()
			self.boardBG:Show()
			self.boardTitle:Show()
			self.boardArrowR:SetTooltip("hide board (" .. Toggle_Key .. ")")
		end
	end)

	self.boardArrow2 = self.boardParent:AddChild(ImageButton(UI_ATLAS, "red_star.tex", "red_star.tex", "red_star.tex"))
	self.boardArrow2:SetScale(1.5,1.5,1.5)
	if TheWorld.ismastersim and not TheNet:IsDedicated() then
		if ThePlayer.components.PickyEater.limit <= 10 then
			self.boardArrow2:SetPosition(550,15,0)			
		elseif ThePlayer.components.PickyEater.limit <= 20 then
			self.boardArrow2:SetPosition(550,-15,0)				
		elseif ThePlayer.components.PickyEater.limit <= 30 then
			self.boardArrow2:SetPosition(550,-45,0)				
		else
			self.boardArrow2:SetPosition(550,0,0)				
		end	 
	else
		if ThePlayer.components.PickyEater.limit <= 10 then
			self.boardArrow2:SetPosition(550,20,0)			
		elseif ThePlayer.components.PickyEater.limit <= 20 then
			self.boardArrow2:SetPosition(550,-15,0)			
		elseif ThePlayer.components.PickyEater.limit <= 30 then
			self.boardArrow2:SetPosition(550,-50,0)			
		else
			self.boardArrow2:SetPosition(550,-5,0)			
		end	 
	end
	self.boardArrow2:SetTooltip("show board")
	self.boardArrow2:SetTooltipPos(0, 8, 0)
	self.boardArrow2:Hide()
	self.boardArrow2:SetOnClick( function() 
		self.boardShow = true
		self.board:Show()
		self.boardBG:Show()
		self.boardTitle:Show()
		self.boardArrowR:SetTooltip("hide board (" .. Toggle_Key .. ")")
		self.boardArrow2:Hide()
		self.boardArrowR:Show()
	end)
	
	self.optionsMenuButton = self.boardParent:AddChild(ImageButton("images/button_icons.xml", "mods.tex", "mods.tex", "mods.tex"))
	self.optionsMenuButton:SetScale(.13,.13,.13)
	self.optionsMenuButton:SetPosition(-170,96,0)	
	self.optionsMenuButton:SetTooltip('show settings menu')
	self.optionsMenuButton:SetTooltipPos(0, 8, 0)
	self.optionsMenuButton:Hide()
	self.optionsMenuButton:SetOnClick( function() 
		if self.menuShow == false then
			self.menuShow = true
			self.optionsMenu:Show()
			self.optionsMenuButton:SetTooltip('hide settings menu')
		else
			self.menuShow = false
			self.optionsMenu:Hide()
			self.optionsMenuButton:SetTooltip('show settings menu')
		end
	end)
	
	self.crockHelpButton = self.boardParent:AddChild(ImageButton("images/ui.xml", "yellow_exclamation.tex", "yellow_exclamation.tex", "yellow_exclamation.tex"))
	self.crockHelpButton:SetScale(1,1,1)
	self.crockHelpButton:SetPosition(-132,98,0)	
	self.crockHelpButton:SetTooltip('show crockpot help')
	self.crockHelpButton:SetTooltipPos(0, 8, 0)
	self.crockHelpButton:Hide()
	self.crockHelpButton:SetOnClick( function() 
		if self.menuShow == false then
			self.menuShow = true
			self.hintBG:Show()
			self.crockHelpButton:SetTooltip('hide crockpot help')
		else
			self.menuShow = false
			self.hintBG:Hide()
			self.crockHelpButton:SetTooltip('show crockpot help')
		end
	end)
--]]
	self.boardTitle = self.boardParent:AddChild(TextButton())
	self.boardTitle:SetFont(TITLEFONT)
	self.boardTitle:SetText("P  I  C  K  Y        E  A  T  E  R")
	self.boardTitle:SetTextSize(30)
	self.boardTitle:SetColour(0.9,0.8,0.6,1)
	self.boardTitle:SetPosition(0, 93, 0)
	self.boardTitle:SetClickable(false) 
	
	self.hintBG = self.boardParent:AddChild( Image("images/ui.xml", "black.tex") )
	self.hintBG:SetScale(1,1,1)
	self.hintBG:SetTint(1,1,1,0.6)
	self.hintBG:SetSize(170, 190)
	if widg_loc == 2 and ThePlayer.components.PickyEater.limit <= 20 then
		self.hintBG:SetPosition(-300,100,0)	
	else
		self.hintBG:SetPosition(-300,28,0) 
	end
	
	self.hintText = self.hintBG:AddChild(Text(TALKINGFONT, 22))
	self.hintText:SetPosition(0, 0, 0)
	self.hintText:EnableWordWrap(true)
	self.hintText:SetRegionSize(150, 150)
	self.hintText:SetColour(1,1,1,1)	
	
	self.hintBG:Hide()
end

function foodMenu:UpdateText()
	local mode = ""
	if self.mode == 1 then
		mode = "cycle"
	elseif self.mode == 2 then
		mode = "yearly"
	else
		mode = "seasonal"
	end
	self.ModeActiveVar:SetText(mode)
end

function foodMenu:text()
	local mode = ""
	if self.mode == 1 then
		mode = "cycle"
	elseif self.mode == 2 then
		mode = "yearly"
	else
		mode = "seasonal"
	end

	self.ModeActive = self.optionsMenu:AddChild(TextButton())
	self.ModeActive:SetFont(NEWFONT_SMALL)
	self.ModeActive:SetText("Active mode:")
	self.ModeActive:SetPosition(52, 15, 0)
	self.ModeActive:SetTextSize(28)
	self.ModeActive:SetColour(0,0,0,1)
	self.ModeActive:SetClickable(false)
	
	self.ModeActiveVar = self.optionsMenu:AddChild(TextButton())
	self.ModeActiveVar:SetFont(NEWFONT_SMALL)
	self.ModeActiveVar:SetText(mode)
	self.ModeActiveVar:SetPosition(150, 15, 0)
	self.ModeActiveVar:SetTextSize(28)
	self.ModeActiveVar:SetColour(0,0,0,1)
	self.ModeActiveVar:SetClickable(false)
	
	self.ModeText = self.optionsMenu:AddChild(TextButton())
	self.ModeText:SetFont(NEWFONT_OUTLINE)
	self.ModeText:SetText("Mode:")
	self.ModeText:SetPosition(30, 100, 0)
	self.ModeText:SetTextSize(33)
	self.ModeText:SetColour(0.25,0.25,0.25,1)
	self.ModeText:SetClickable(false)
	
	self.IncludeText = self.optionsMenu:AddChild(TextButton())
	self.IncludeText:SetFont(NEWFONT_OUTLINE)
	self.IncludeText:SetText("Include:")
	self.IncludeText:SetPosition(40, -27, 0)
	self.IncludeText:SetTextSize(33)
	self.IncludeText:SetColour(0.25,0.25,0.25,1)
	self.IncludeText:SetClickable(false)

	self.yearModeText = self.optionsMenu:AddChild(TextButton())
	self.yearModeText:SetFont(NEWFONT_SMALL)
	self.yearModeText:SetText("Yearly")
	self.yearModeText:SetPosition(63, 60, 0)
	self.yearModeText:SetTextSize(28)
	self.yearModeText:SetColour(0,0,0,1)
	self.yearModeText:SetClickable(false)
	
	self.seasonModeText = self.optionsMenu:AddChild(TextButton())
	self.seasonModeText:SetFont(NEWFONT_SMALL)
	self.seasonModeText:SetText("Seasonal")
	self.seasonModeText:SetPosition(173, 60, 0)
	self.seasonModeText:SetTextSize(28)
	self.seasonModeText:SetColour(0,0,0,1)
	self.seasonModeText:SetClickable(false)
	
	self.cycleModeText = self.optionsMenu:AddChild(TextButton())
	self.cycleModeText:SetFont(NEWFONT_SMALL)
	self.cycleModeText:SetText("Cycle")
	self.cycleModeText:SetPosition(280, 60, 0)
	self.cycleModeText:SetTextSize(28)
	self.cycleModeText:SetColour(0,0,0,1)
	self.cycleModeText:SetClickable(false)
	
	self.crockpotText = self.optionsMenu:AddChild(TextButton())
	self.crockpotText:SetFont(NEWFONT_SMALL)
	self.crockpotText:SetText("All crockpot foods")
	self.crockpotText:SetPosition(-180, 100, 0)
	self.crockpotText:SetTextSize(28)
	self.crockpotText:SetColour(0,0,0,1)
	self.crockpotText:SetClickable(false)
	
	self.crockpot10Text = self.optionsMenu:AddChild(TextButton())
	self.crockpot10Text:SetFont(NEWFONT_SMALL)
	self.crockpot10Text:SetText("10 random crockpot foods")
	self.crockpot10Text:SetPosition(-150, 60, 0)
	self.crockpot10Text:SetTextSize(28)
	self.crockpot10Text:SetColour(0,0,0,1)
	self.crockpot10Text:SetClickable(false)
	
	self.crockpot20Text = self.optionsMenu:AddChild(TextButton())
	self.crockpot20Text:SetFont(NEWFONT_SMALL)
	self.crockpot20Text:SetText("20 random crockpot foods")
	self.crockpot20Text:SetPosition(-150, 20, 0)
	self.crockpot20Text:SetTextSize(28)
	self.crockpot20Text:SetColour(0,0,0,1)
	self.crockpot20Text:SetClickable(false)
	
	self.rand10Text = self.optionsMenu:AddChild(TextButton())
	self.rand10Text:SetFont(NEWFONT_SMALL)
	self.rand10Text:SetText("10 random foods")
	self.rand10Text:SetPosition(-190, -20, 0)
	self.rand10Text:SetTextSize(28)
	self.rand10Text:SetColour(0,0,0,1)
	self.rand10Text:SetClickable(false)
	
	self.rand20Text = self.optionsMenu:AddChild(TextButton())
	self.rand20Text:SetFont(NEWFONT_SMALL)
	self.rand20Text:SetText("20 random foods")
	self.rand20Text:SetPosition(-190, -60, 0)
	self.rand20Text:SetTextSize(28)
	self.rand20Text:SetColour(0,0,0,1)
	self.rand20Text:SetClickable(false)
	
	self.rand30Text = self.optionsMenu:AddChild(TextButton())
	self.rand30Text:SetFont(NEWFONT_SMALL)
	self.rand30Text:SetText("30 random foods")
	self.rand30Text:SetPosition(-190, -100, 0)
	self.rand30Text:SetTextSize(28)
	self.rand30Text:SetColour(0,0,0,1)
	self.rand30Text:SetClickable(false)
	
	self.easyText = self.optionsMenu:AddChild(TextButton())
	self.easyText:SetFont(NEWFONT_SMALL)
	self.easyText:SetText("hard-to-get")
	self.easyText:SetPosition(220, -65, 0)
	self.easyText:SetTextSize(28)
	self.easyText:SetColour(0,0,0,1)
	self.easyText:SetClickable(false)
	
	self.longtermText = self.optionsMenu:AddChild(TextButton())
	self.longtermText:SetFont(NEWFONT_SMALL)
	self.longtermText:SetText("longterm")
	self.longtermText:SetPosition(75, -65, 0)
	self.longtermText:SetTextSize(28)
	self.longtermText:SetColour(0,0,0,1)
	self.longtermText:SetClickable(false)
	
	self.rareText = self.optionsMenu:AddChild(TextButton())
	self.rareText:SetFont(NEWFONT_SMALL)
	self.rareText:SetText("rare")
	self.rareText:SetPosition(55, -105, 0)
	self.rareText:SetTextSize(28)
	self.rareText:SetColour(0,0,0,1)
	self.rareText:SetClickable(false)
	
	self.cavesText = self.optionsMenu:AddChild(TextButton())
	self.cavesText:SetFont(NEWFONT_SMALL)
	self.cavesText:SetText("caves")
	self.cavesText:SetPosition(195, -105, 0)
	self.cavesText:SetTextSize(28)
	self.cavesText:SetColour(0,0,0,1)
	self.cavesText:SetClickable(false)
end

function foodMenu:checkBoxUpdate()
	if self.mode == 2 then
		self.yearMode:SetTextures("images/ui.xml", "radiobutton_on.tex","radiobutton_on.tex", "radiobutton_on.tex", nil, nil, {1,1}, { 15, 60 })
	else
		self.yearMode:SetTextures("images/ui.xml", "radiobutton_off.tex", "radiobutton_off.tex", "radiobutton_off.tex", nil, nil, {.1,.1}, {15,60})
	end
	if self.mode == 3 then
		self.seasonMode:SetTextures("images/ui.xml", "radiobutton_on.tex","radiobutton_on.tex", "radiobutton_on.tex", nil, nil, {.75,.75}, { 115, 60 })
	else
		self.seasonMode:SetTextures("images/ui.xml", "radiobutton_off.tex", "radiobutton_off.tex", "radiobutton_off.tex", nil, nil, {.75,.75}, {115,60})
	end
	if self.mode == 1 then
		self.cycleMode:SetTextures("images/ui.xml", "radiobutton_on.tex","radiobutton_on.tex", "radiobutton_on.tex", nil, nil, {.75,.75}, { 235, 60 })
	else
		self.cycleMode:SetTextures("images/ui.xml", "radiobutton_off.tex", "radiobutton_off.tex", "radiobutton_off.tex", nil, nil, {.75,.75}, {235,60})
	end

	if self.menuType == 1 then
		self.crockpot:SetTextures("images/ui.xml", "radiobutton_on.tex","radiobutton_on.tex", "radiobutton_on.tex", nil, nil, {.75,.75}, {-290, 100 })
	else
		self.crockpot:SetTextures("images/ui.xml", "radiobutton_off.tex", "radiobutton_off.tex", "radiobutton_off.tex", nil, nil, {.75,.75}, {-290,100})
	end
	if self.menuType == 2 then
		self.crockpot10:SetTextures("images/ui.xml", "radiobutton_on.tex","radiobutton_on.tex", "radiobutton_on.tex", nil, nil, {.75,.75}, {-290, 60 })
	else
		self.crockpot10:SetTextures("images/ui.xml", "radiobutton_off.tex", "radiobutton_off.tex", "radiobutton_off.tex", nil, nil, {.75,.75}, {-290,60})
	end
	if self.menuType == 3 then
		self.crockpot20:SetTextures("images/ui.xml", "radiobutton_on.tex","radiobutton_on.tex", "radiobutton_on.tex", nil, nil, {.75,.75}, { -290, 20 })
	else
		self.crockpot20:SetTextures("images/ui.xml", "radiobutton_off.tex", "radiobutton_off.tex", "radiobutton_off.tex", nil, nil, {.75,.75}, {-290,20})
	end
	if self.menuType == 4 then
		self.rand10:SetTextures("images/ui.xml", "radiobutton_on.tex","radiobutton_on.tex", "radiobutton_on.tex", nil, nil, {.75,.75}, { -290, -20 })
	else
		self.rand10:SetTextures("images/ui.xml", "radiobutton_off.tex", "radiobutton_off.tex", "radiobutton_off.tex", nil, nil, {.75,.75}, {-290,-20})
	end
	if self.menuType == 5 then
		self.rand20:SetTextures("images/ui.xml", "radiobutton_on.tex","radiobutton_on.tex", "radiobutton_on.tex", nil, nil, {.75,.75}, { -290, -60 })
	else
		self.rand20:SetTextures("images/ui.xml", "radiobutton_off.tex", "radiobutton_off.tex", "radiobutton_off.tex", nil, nil, {.75,.75}, {-290,-60})
	end
	if self.menuType == 6 then
		self.rand30:SetTextures("images/ui.xml", "radiobutton_on.tex","radiobutton_on.tex", "radiobutton_on.tex", nil, nil, {.75,.75}, { -290, -100 })
	else
		self.rand30:SetTextures("images/ui.xml", "radiobutton_off.tex", "radiobutton_off.tex", "radiobutton_off.tex", nil, nil, {.75,.75}, {-290,-100})
	end

	if self.easy % 2 == 0 then
		self.easyCheckbox:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {1,1}, {150,-70})
	else
		self.easyCheckbox:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {1,1}, {150,-70})
	end
	if self.longterm % 2 == 0 then
		self.longtermCheckbox:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {1,1}, {15,-70})
	else
		self.longtermCheckbox:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {1,1}, {15,-70})
	end
	if self.rare % 2 == 0 then
		self.rareCheckbox:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {1,1}, {15,-110})
	else
		self.rareCheckbox:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {1,1}, {15,-110})
	end
	if self.caves % 2 == 0 then
		self.cavesCheckbox:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {1,1}, {150,-110})
	else
		self.cavesCheckbox:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {1,1}, {150,-110})
	end
end

function foodMenu:checkBoxes()
	self.yearMode = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {.1,.1}, {-125,-203}))
  	self.yearMode:SetOnClick(function() 
		self.mode = 2
		self:checkBoxUpdate()
	end) 
	self.seasonMode = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {.75,.75}, {-125,-203}))
  	self.seasonMode:SetOnClick(function() 
		self.mode = 3
		self:checkBoxUpdate()
	end) 
	self.cycleMode = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {.75,.75}, {-125,-203}))
  	self.cycleMode:SetOnClick(function() 
		self.mode = 1
		self:checkBoxUpdate()
	end) 	

	self.crockpot = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {.75,.75}, {-125,-203}))
  	self.crockpot:SetOnClick(function() 
		self.menuType = 1
		self:checkBoxUpdate()
	end) 	
	self.crockpot10 = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {.75,.75}, {-125,-203}))
  	self.crockpot10:SetOnClick(function() 
		self.menuType = 2
		self:checkBoxUpdate()
	end) 	
	self.crockpot20 = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {.75,.75}, {-125,-203}))
  	self.crockpot20:SetOnClick(function() 
		self.menuType = 3
		self:checkBoxUpdate()
	end) 
	self.rand10 = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {.75,.75}, {-125,-203}))
  	self.rand10:SetOnClick(function() 
		self.menuType = 4
		self:checkBoxUpdate()
	end) 
	self.rand20 = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {.75,.75}, {-125,-203}))
  	self.rand20:SetOnClick(function() 
		self.menuType = 5
		self:checkBoxUpdate()
	end) 	
	self.rand30 = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {.75,.75}, {-125,-203}))
  	self.rand30:SetOnClick(function() 
		self.menuType = 6
		self:checkBoxUpdate()
	end) 
	
	self.easyCheckbox = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {.75,.75}, {-125,-203}))
  	self.easyCheckbox:SetOnClick(function() 
		self.easy = self.easy + 1		
		self:checkBoxUpdate()
	end) 
	self.longtermCheckbox = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {.75,.75}, {-125,-203}))
  	self.longtermCheckbox:SetOnClick(function() 
		self.longterm = self.longterm + 1		
		self:checkBoxUpdate()
	end) 
	
	
	self.rareCheckbox = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {.75,.75}, {-300,-203}))
  	self.rareCheckbox:SetOnClick(function() 
		self.rare = self.rare + 1		
		self:checkBoxUpdate()
	end) 
	
	self.cavesCheckbox = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {.75,.75}, {-300,-203}))
  	self.cavesCheckbox:SetOnClick(function() 
		self.caves = self.caves + 1		
		self:checkBoxUpdate()
	end) 
	self:checkBoxUpdate()
end

return foodMenu
