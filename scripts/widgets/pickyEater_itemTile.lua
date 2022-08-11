local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

require "HelpStr"

local ItemTile = Class(Widget, function(self, invitem)
	Widget._ctor(self, "ItemTile")
	self.item = invitem

	local DEFAULT_ATLAS = "images/inventoryimages.xml"
	local name = tostring(invitem)
	local atlas = DEFAULT_ATLAS--softresolvefilepath("images/inventoryimages/"..name..".xml") or softresolvefilepath("images/"..name..".xml") or DEFAULT_ATLAS	
	if name == "potato" or name == "potato_cooked" or
		name == "tomato" or name == "tomato_cooked" or
		name == "onion" or name == "onion_cooked" or
		name == "garlic" or name == "garlic_cooked" or
		name == "pepper" or name == "pepper_cooked" or
		name == "asparagus" or name == "asparagus_cooked" or
		name == "fishmeat_small" or name == "fishmeat_small_cooked" or
		name == "potatotornado" or name == "mashedpotatoes" or name == "asparagussoup" or name == "ceviche" or name == "salsa" or name == "pepperpopper" then
		atlas = "images/inventoryimages1.xml"
	end
	if name == "vegstinger" or name == "surfnturf" then
		atlas = "images/inventoryimages2.xml"
	end
	if name == "potato" or name == "potato_cooked" or
		name == "tomato" or name == "tomato_cooked" or
		name == "onion" or name == "onion_cooked" or
		name == "garlic" or name == "garlic_cooked" then
		name = "quagmire_" .. name
	end
	local image = name .. ".tex"
		

	self.image = self:AddChild(Image(atlas, image))
end)

function ItemTile:UpdateTooltip()
	local str = self:GetDescriptionString()
	self:SetTooltip(str)
	if ThePlayer.HUD.controls.foodMenu and helpstrings[self.item] then
		ThePlayer.HUD.controls.foodMenu.hintText:SetString(helpstrings[self.item])
	end
end

function ItemTile:GetDescriptionString()

	local str = ""

	if self.item ~= nil and self.item ~= "" then
		local itemtip = string.upper(TrimString( self.item ))
		if STRINGS.NAMES[itemtip] ~= nil and STRINGS.NAMES[itemtip] ~= "" then
				str = STRINGS.NAMES[itemtip]
		end
	end

	if str == "" then
		str = self.item
	end

	return str
end

function ItemTile:OnGainFocus()
	self:UpdateTooltip()
end

return ItemTile
