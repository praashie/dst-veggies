local ItemSlot = require "widgets/pickyEater_itemSlot"

local InvSlot = Class(ItemSlot, function(self, num, atlas, bgim, owner, container)
	ItemSlot._ctor(self, atlas, bgim, owner)
	self.owner = owner
	self.container = container
	self.num = num
end)

return InvSlot
