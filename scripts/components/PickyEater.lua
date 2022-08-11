require "EatLists"

local function Shuffle(array,seed)
	math.randomseed(seed)
	local arrayCount = #array
	for f = arrayCount, 1, -1 do
		math.random(os.time())
        	local j = math.random(f)
        	array[f], array[j] = array[j], array[f]
    	end
   return array
end

local function Numerize(array)
	for i,food in ipairs(array) do
		local food_net_index = orderedFood[food]
		if food_net_index == nil then
			print("[PickyEater] ERROR: could not numerize food "..food)
		end
		array[i] = food_net_index
	end
	return array
end

local function Denumerize(array)
	for i,v in ipairs(array) do
		for food,num in pairs(orderedFood) do
			if num == v then
				array[i] = food
				break
			end
		end
	end
	return array
end

local function GetIndex(str,i)
	getmetatable('').__index = function(str,i) return string.sub(str,i,i) end
	return str[i]
end

local function OnMenuDirty(inst)
	local tempMenu = {}
	inst.components.PickyEater.menu = {}
	local tempMenu = inst.components.PickyEater.net_menu:value()
	Denumerize(tempMenu)
	inst.components.PickyEater.menu = tempMenu
end

local function OnProgressDirty(inst)
	inst.components.PickyEater.progress = inst.components.PickyEater.net_progress:value()
	inst.components.PickyEater.update = true
end

local function OnWidgetDirty(inst)
	local tempString = inst.components.PickyEater.net_widget:value()
	inst.components.PickyEater.mode = GetIndex(tempString,2)
	inst.components.PickyEater.menuType = GetIndex(tempString,3)
	inst.components.PickyEater.easy = GetIndex(tempString,4)
	inst.components.PickyEater.longterm = GetIndex(tempString,5)
	inst.components.PickyEater.rare = GetIndex(tempString,6)
	inst.components.PickyEater.caves = GetIndex(tempString,7)
end

local function OnUpdateDirty(inst)
	local menuIndex = inst.components.PickyEater.net_update:value()
	inst.components.PickyEater.progress[menuIndex] = 1
	inst.components.PickyEater.update = true
end

local function OnResetDirty(inst)
	inst.components.PickyEater.progress = inst.components.PickyEater.net_reset:value()
	inst.components.PickyEater.reset = true
	inst.components.PickyEater.update = true
end

local function OnLimitDirty(inst)
	inst.components.PickyEater.limit = inst.components.PickyEater.net_limit:value()
end

local function OnModeDirty(inst)
	inst.components.PickyEater.mode = inst.components.PickyEater.net_mode:value()
end

local PickyEater = Class(function(self, inst)
    self.inst = inst

	self.update = false
	self.win = false
	self.dayCount = 0
	self.menu = {}
	self.progress = {}
	self.food = {}
	self.mode = default_mode
	self.menuType = default_menuType
	self.limit = 20
	self.easy = default_easy
	self.longterm = default_longterm
	self.rare = default_rare
	self.caves = default_caves
	self.reset = false
	self.Reset = false
	
	self.net_menu = net_bytearray(self.inst.GUID, "menu", "menudirty" ) 
	self.net_progress = net_smallbytearray(self.inst.GUID, "progress", "progressdirty" )
	self.net_reset = net_smallbytearray(self.inst.GUID, "reset", "resetdirty" )
	self.net_widget = net_string(self.inst.GUID, "widget", "widgetdirty" )
	self.net_update = net_smallbyte(self.inst.GUID, "update", "updatedirty" )
	self.net_limit = net_smallbyte(self.inst.GUID, "limit", "limitdirty" )
	self.net_mode = net_tinybyte(self.inst.GUID, "mode", "modedirty" )	
	
	if TheWorld.ismastersim then
		self.OnEatfn = function(player,data) self:OnEat(player,data) end
		self.OnNextSeasonfn = function() self:OnNextSeason() end
		self.OnNextCyclefn = function() self:OnNextCycle() end		
		self.inst:ListenForEvent("oneat", self.OnEatfn)		
		self.inst:WatchWorldState("season", self.OnNextSeasonfn)   
		self.inst:WatchWorldState("cycles", self.OnNextCyclefn)   
		self.inst:StartUpdatingComponent(self)
		self.inst:DoTaskInTime(1.5, function() 
			if self.menu[1] == nil then 
				self.Reset = true
				self:ResetPlayerTable() 
			end 
		end)
	else
		self.inst:ListenForEvent("menudirty", OnMenuDirty)        
		self.inst:ListenForEvent("progressdirty", OnProgressDirty)  
		self.inst:ListenForEvent("widgetdirty", OnWidgetDirty) 
		self.inst:ListenForEvent("updatedirty", OnUpdateDirty) 
		self.inst:ListenForEvent("resetdirty", OnResetDirty) 	
		self.inst:ListenForEvent("limitdirty", OnLimitDirty) 	
		self.inst:ListenForEvent("modedirty", OnModeDirty) 		
	end
end)

function PickyEater:OnSave()
    return
    {
		dayCount = self.dayCount,
		menu = self.menu,
		progress = self.progress,
		food = self.food,
		limit = self.limit,
		--easy = self.easy,
		--longterm = self.longterm,
		--rare = self.rare,
		--caves = self.caves,
		mode = self.mode,
		--menuType = self.menuType,
	}
end

function PickyEater:OnLoad(data)
	if data and data.dayCount then
		self.dayCount = data.dayCount
	end
	if data and data.food then
		self.food = data.food
	end
	if data and data.limit then
		self.limit = data.limit
	end
	--[[
	if data and data.easy then
		self.easy = data.easy
	end
	if data and data.longterm then
		self.longterm = data.longterm
	end
	if data and data.rare then
		self.rare = data.rare
	end
	if data and data.caves then
		self.caves = data.caves
	end
	--]]
	if data and data.mode then
		self.mode = data.mode
	end
	if data and data.menuType then
		--self.menuType = data.menuType
	end
	if data and data.progress then
		self.progress = data.progress
	end
	if data and data.menu then
		self.menu = data.menu
		if TheNet:IsDedicated() or not TheWorld.ismastersim then
			self:GetMode()
		end
		self:RebuildPlayerTable()
	else
		self:ResetPlayerTable()
	end
end

function PickyEater:PrefersToEat(inst)
    return not (inst.prefab == "winter_food4" and self.inst:HasTag("player"))
        and self:TestFood(inst, self.preferseating)
end

function PickyEater:EaterChange(array)
	if picky_eater and self.inst.components.eater then
		local _PrefersToEat = self.inst.components.PickyEater.PrefersToEat
		self.inst.components.eater.PrefersToEat = function(self, food)
			return _PrefersToEat(self, food) and not array[food.prefab]
		end
	end
end

function PickyEater:GetMode()
	self.net_mode:set(self.mode)
end

function PickyEater:RebuildWidget()
	local tempString = "a" .. self.mode .. self.menuType .. self.easy .. self.longterm .. self.rare .. self.caves
	tostring(tempString)
	self.net_widget:set(tempString)
end

function PickyEater:ResetPlayerTable()
	local tempFoodList = {}
	local seed = os.time()
	
	self.food = {}
	
	for k,v in pairs(allFood) do
		self.food[k] = v
	end
	
	self.menu = {}
	self.progress = {}
	self.dayCount = 0
	self.limit = 30
	
	if self.menuType == 1 or self.menuType == 2 or self.menuType == 3 then
		if self.inst.prefab == "wathgrithr" then
			for k,v in pairs(wigfridCrockpot) do
				table.insert(tempFoodList,v)
			end
			if self.caves % 2 == 0 then
				table.insert(tempFoodList,"unagi")
			end
		elseif self.inst.prefab == "wurt" then
			for k,v in pairs(wurtCrockpot) do
				table.insert(tempFoodList,v)
			end
		else
			for k,v in pairs(crockpotFood) do
				table.insert(tempFoodList,v)
			end
			if self.rare % 2 == 0 then
				table.insert(tempFoodList,"mandrakesoup")
			end
			if self.easy % 2 == 0 then
				for k,v in pairs(crockpotHard) do
					table.insert(tempFoodList,v)
				end
			end
			if self.longterm % 2 == 0 then
				table.insert(tempFoodList,"flowersalad")
			end
			if self.caves % 2 == 0 then
				table.insert(tempFoodList,"unagi")
			end
		end	
		Shuffle(tempFoodList,seed)
	else
		if self.inst.prefab == "wathgrithr" then
			for k,v in pairs(wigfridFood) do
				table.insert(tempFoodList,v)
			end
			for k,v in pairs(wigfridCrockpot) do
				table.insert(tempFoodList,v)
			end
			if self.caves % 2 == 0 then
				table.insert(tempFoodList,"unagi")
			end
			if self.caves % 2 == 0 and self.easy %2 == 0 then
				table.insert(tempFoodList,"minotaurhorn")
			end	
			if self.longterm % 2 == 0 and self.easy %2 == 0 then
				table.insert(tempFoodList,"deerclops_eyeball")
			end				
			if self.longterm % 2 == 0 then
				for k,v in pairs(wigfridLongterm) do
					table.insert(tempFoodList,v)
				end
			end
			if self.caves % 2 == 0 then
				for k,v in pairs(wigfridCave) do
					table.insert(tempFoodList,v)
				end
			end			
		elseif self.inst.prefab == "wurt" then
			for k,v in pairs(wurtFood) do
				table.insert(tempFoodList,v)
			end
			for k,v in pairs(wurtCrockpot) do
				table.insert(tempFoodList,v)
			end
		else
			for k,v in pairs(allFoods) do
				table.insert(tempFoodList,v)
			end
			if self.rare % 2 == 0 then
				for k,v in pairs(allFoodsRare) do
					table.insert(tempFoodList,v)
				end
			end
			if self.easy % 2 == 0 then
				for k,v in pairs(allFoodsHard) do
					table.insert(tempFoodList,v)
				end
			end
			if self.longterm % 2 == 0 then
				for k,v in pairs(allFoodsLongterm) do
					table.insert(tempFoodList,v)
				end
			end
			if self.caves % 2 == 0 then
				for k,v in pairs(allFoodsCave) do
					table.insert(tempFoodList,v)
				end
			end
			if self.caves % 2 == 0 and self.easy %2 == 0 then
				table.insert(tempFoodList,"minotaurhorn")
			end	
			if self.longterm % 2 == 0 and self.easy %2 == 0 then
				table.insert(tempFoodList,"deerclops_eyeball")
			end	
			--[[
			if self.inst.prefab == "wx78" then
				table.insert(tempFoodList,"gears")
			end
			--]]
		end
		Shuffle(tempFoodList,seed)	
	end
	
	if self.menuType == 2 or self.menuType == 4 then
		self.limit = 10	
	elseif self.menuType == 5 or (self.menuType == 3 and self.inst.prefab ~= "wathgrithr") then
		self.limit = 20	
	elseif self.menuType == 6 and self.inst.prefab ~= "wathgrithr" then
		self.limit = 30	
	else
		self.limit = #tempFoodList
		if self.limit > 30 then
			self.limit = 30
		end
	end

	self.net_limit:set(self.limit)
	
	for i,v in ipairs(tempFoodList) do
		if self.limit >= i then 
			table.insert(self.menu,v)
			self.progress[i] = 0
		end
	end
	for i,v in ipairs(self.menu) do	
		self.food[v] = false
	end
	self:EaterChange(self.food)		
	local tempMenu = {}
	
	for k,v in pairs(self.menu) do
		table.insert(tempMenu,v)
	end

	Numerize(tempMenu)
	self.net_menu:set(tempMenu)
	local net_reset = {9,9,9}
	if self.Reset then
		self.Reset = false
		self.net_reset:set(net_reset)
		self.net_reset:set(self.progress)
		if TheWorld.ismastersim and not TheNet:IsDedicated() then
			self.reset = true
			self.update = true
		end
	else
		self.net_progress:set(net_reset)
		self.net_progress:set(self.progress)
		if TheWorld.ismastersim and not TheNet:IsDedicated() then
			self.update = true
		end
	end
end

function PickyEater:RebuildPlayerTable()
	local tempMenu = {}
	
	for k,v in pairs(self.menu) do
		table.insert(tempMenu,v)
	end

	Numerize(tempMenu)
	self:EaterChange(self.food)
	self.net_limit:set(self.limit)
	self.net_menu:set(tempMenu)
	self.net_progress:set(self.progress)
end

function PickyEater:OnEat(player, data)
	local menuIndex = nil
	if self.food[data.food.prefab] == false then
		self.food[data.food.prefab] = true
		for k,v in pairs(self.menu) do
			if v == data.food.prefab then
				self.progress[k] = 1
				menuIndex = k
			end
		end
		if self.mode == 1 then
			self:CheckList()
		end
		if not self.win then
			self:EaterChange(self.food)
			if menuIndex ~= nil then
				self.net_update:set(menuIndex)
				if TheWorld.ismastersim and not TheNet:IsDedicated() then
					self.update = true
				end
			end
		else
			self.win = false
		end
	end
end

function PickyEater:OnWin()
	local mode = ""	
	if self.mode == 1 then
		mode = "cycle"
	elseif self.mode == 2 then
		mode = "yearly"		
	elseif self.mode == 3 then
		mode = "seasonal"		
	end
	if win_message then
		TheNet:Say(("PickyEater: " .. self.inst.name .. " has completed their " .. mode .. " menu! Congrats!  \164\0\0"),false)
	end
end

function PickyEater:OnWinDirty()
	local name = self.inst.name
	local wintext = ""
	local And = ""
	local menuType = ""
	local mode = ""
	local easy = ""
	local longterm = ""
	local caves = ""
	local rare = ""
	local normal = ""
		
	if self.menuType == 1 then
		menuType = "all crockpot foods "
	elseif self.menuType == 2 then 
		menuType = "10 crockpot foods "		
	elseif self.menuType == 3 then 
		menuType = "20 crockpot foods "		
	elseif self.menuType == 4 then 
		menuType = "30 crockpot foods "		
	elseif self.menuType == 5 then 
		menuType = "10 random foods "		
	elseif self.menuType == 6 then 
		menuType = "20 random foods "		
	elseif self.menuType == 7 then
		menuType = "30 random foods "		
	end
	
	if self.mode == 1 then
		mode = "cycle mode "
	elseif self.mode == 2 then
		mode = "yearly mode "		
	elseif self.mode == 3 then
		mode = "seasonal mode "		
	end
	
	if self.easy %2 == 0 then
		easy = " easy"
		And = " and"
	end

	if self.longterm %2 == 0 then
		longterm = " longterm"
		And = " and"
	end	
	if self.caves %2 == 0 then
		caves = " cave"
		And = " and"
	end
	if self.rare %2 == 0 then
		rare = " rare"
	end
	if self.rare %2 == 1 and self.caves %2 == 1 and self.easy %2 == 1 and self.longterm %2 == 1 then
		normal = " normal"
	end
	
	self.inst.HUD.controls.foodMenu:OnWinMessage(name,And,menuType,mode,easy,longterm,caves,rare,normal)
end

function PickyEater:CheckList()
	local checker = 0
	for k,v in pairs(self.progress) do
		if v == 0 then
			checker = checker + 1
		end
	end
	if checker == 0 then
		self.win = true
		if win_message then
			self:OnWin()
		end
		self.Reset = true
		self:ResetPlayerTable()
	end		
end

function PickyEater:OnNextCycle()
	self.dayCount = self.dayCount + 1
	if self.mode == 2 and self.dayCount > year_length then
		if win_message then
			self:OnWin()
		end
		self.Reset = true
		self:ResetPlayerTable()
	end
end

function PickyEater:OnNextSeason()
	if self.mode == 3 then
		if win_message then
			self:OnWin()
		end
		self.Reset = true
		self:ResetPlayerTable() 
	end
end

return PickyEater