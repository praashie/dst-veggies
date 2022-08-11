local function GetConfig(s,default)
	local c=GetModConfigData(s)
	if c==nil then
		c=default
	end
	if type(c)=="table" then
		c=c.option_data
	end
	return c
end

local alpha = {"a","b","c","d","e","f","g","h","i","j","k","L","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}

toggle_Key = GetModConfigData("toggle_Key")
if type(toggle_Key) == "string" then
	toggle_Key = toggle_Key:lower():byte()
end

GLOBAL.Toggle_Key = alpha[toggle_Key - 96]
GLOBAL.widg_loc = GetConfig("widg_loc", 1)
GLOBAL.picky_eater = GetConfig("picky_eater", true)
GLOBAL.default_caves = GetConfig("default_caves", 1)
GLOBAL.default_longterm = GetConfig("default_longterm", 1)
GLOBAL.default_easy = GetConfig("default_easy", 1)
GLOBAL.default_rare = GetConfig("default_rare", 1)
GLOBAL.default_menuType = GetConfig("default_menuType", 3)
GLOBAL.default_mode = GetConfig("default_mode", 1)
GLOBAL.client_reset = GetConfig("client_reset", true)
GLOBAL.win_message = GetConfig("win_message", true)
GLOBAL.year_length = GetConfig("year_length", 70)

local menuShow = true
local FoodMenu = GLOBAL.require("widgets/FoodMenu")

local function IsDefaultScreen()
	return GLOBAL.TheFrontEnd:GetActiveScreen().name:find("HUD") ~= nil
		and not(GLOBAL.ThePlayer.HUD:IsControllerCraftingOpen() or GLOBAL.ThePlayer.HUD:IsControllerInventoryOpen())
end

local function ToggleMenu()
	if type(GLOBAL.ThePlayer) ~= "table" or type(GLOBAL.ThePlayer.HUD) ~= "table" then return end
	if not IsDefaultScreen() then return end

	if menuShow == true then
			controls.foodMenu:Hide()
			menuShow = false
	else
		controls.foodMenu:Show()
		menuShow = true
	end
end

function PlayerComponents( inst )
	inst:AddComponent("PickyEater")	
end

AddPlayerPostInit( PlayerComponents )

local function AddEater(self)
	controls = self
	if controls then
		if widg_loc == 2 then
			if controls.top_root then
				controls.foodMenu = controls.top_root:AddChild(FoodMenu())
			else 
				controls.foodMenu = controls:AddChild(FoodMenu())
			end	
		else
			if controls.bottom_root then
				controls.foodMenu = controls.bottom_root:AddChild(FoodMenu())
			else 
				controls.foodMenu = controls:AddChild(FoodMenu())
			end	
		end	
	else
		return
	end
	GLOBAL.TheInput:AddKeyDownHandler(toggle_Key, ToggleMenu)
end

AddClassPostConstruct("widgets/controls", AddEater)

AddPrefabPostInit(
    "gears",
    function(inst)
        if not GLOBAL.TheWorld.ismastersim then
            return
        end
        if inst.components.edible and inst.components.edible.hungervalue then
			inst.components.edible.hungervalue = 0
		end
	end
)

GLOBAL.AddModRPCHandler( "PickyEater", "reset", 
	function(inst,mode,menuType,easy,longterm,rare,caves)
		inst.components.PickyEater.mode = mode
		inst.components.PickyEater.menuType = menuType
		inst.components.PickyEater.easy = easy
		inst.components.PickyEater.longterm = longterm
		inst.components.PickyEater.rare = rare
		inst.components.PickyEater.caves = caves
		inst.components.PickyEater.Reset = true
		inst.components.PickyEater:ResetPlayerTable()
    end )





