local Widget = require("widgets/widget")

local ItemSlot = Class(Widget, function(self, atlas, bgim, owner)
    Widget._ctor(self, "ItemSlot")
    self.owner = owner
    self.bgimage = self:AddChild(Image(atlas, bgim))
	

	self.tile = nil    
end)
	--[[
	self.bgimage:SetTint(red,green,blue,alpha)
	self.bgimage:SetTint(0.145,0.4549,0.6627,2) -- "Jelly Bean" (blue)
	self.bgimage:SetTint(0.9098,0.494,0.0156,2) tahiti gold
	self.bgimage:SetTint(0.9529,0.6,0.07,1) -- buttercup (yellow)
	self.bgimage:SetTint(0.96,0.67,0.207,1) -- lightning yellow
	self.bgimage:SetTint(.8,.3,.3,0.7) = reddish orange pinkish
	self.bgimage:SetTint(.8,.5,.9,0.7) bright purple
	self.bgimage:SetTint(0.902,0.494,0.133,.75) "zest" -- (orange)
	self.bgimage:SetTint(.1,.88,.6,0.7) blueish green
	self.bgimage:SetTint(0.464,0.345,0.908,1) - light purple
	self.bgimage:SetTint(0,.78,.549,0.7) = turqoiseblue
	self.bgimage:SetTint(.8,.58,.04,0.7) = darkgoldenrod 3
	self.bgimage:SetTint(.219,.556,.556,0.7) = teal	
	--]]

function ItemSlot:Highlight()
	if not self.big then
		self:ScaleTo(1, 1.1, .125)
		self.big = true	
	end
end

function ItemSlot:DeHighlight()
    if self.big then    
        self:ScaleTo(1.1, 1, .25)
        self.big = false
    end
end

function ItemSlot:OnGainFocus()
	self:Highlight()

end

function ItemSlot:OnLoseFocus()
	self:DeHighlight()
end

function ItemSlot:SetTile(tile)
    if self.tile and tile ~= self.tile then
        self.tile = self.tile:Kill()
    end

    if tile then
        self.tile = self:AddChild(tile)
    end
end

return  ItemSlot
