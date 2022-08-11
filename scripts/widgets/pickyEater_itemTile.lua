local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"


require "HelpStr"

local ItemTile = Class(Widget, function(self, invitem)
	Widget._ctor(self, "ItemTile")
	self.item = invitem

	local image_name = tostring(invitem)

	if image_name == "tomato" or image_name == "onion" or image_name == "tomato_cooked" or image_name == "onion_cooked" then
		image_name = "quagmire_" .. image_name
	end

	local image = image_name .. ".tex"
	local atlas = GetInventoryItemAtlas(image, false)

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
