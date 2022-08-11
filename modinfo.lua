name = "Eat Your Veggies! (fix)"
description = "Diet restriction minigame."
author = "Joeshmocoolstuff" 
version = "1.7.1"
api_version = 10

dont_starve_compatible = false
reign_of_giants_compatible = false
dst_compatible = true

forumthread = ""

all_clients_require_mod = true
client_only_mod = false

server_filter_tags = {}

icon_atlas = "modicon.xml"
icon = "modicon.tex"

local alpha = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
local KEY_A = 97
local keyslist = {}
for i = 1,#alpha do keyslist[i] = {description = alpha[i],data = i + KEY_A - 1} end

configuration_options =
{
    {
        name = "toggle_Key",
        label = "Board Toggle Key",
		hover = "The keyboard toggle to open/close the board",
        options = keyslist,
        default = 98, --B
    }, 
		{
        name = "widg_loc",
        label = "Board Location",
		options =
		{
			{description = "Top", data = 1},
			{description = "Bottom", data = 2},
		},
		default = 1,
    }, 
	{
        name = "picky_eater",
        label = "Food Restriction",
		hover = "For those who want to use the crockpot info without having to deal with the food restrictions.",
		options =
		{
			{description = "On", data = true},
			{description = "Off", data = false},
		},
		default = true,
    }, 
	{
        name = "year_length",
        label = "Length of Year",
		hover = "Amount of days before the menu resets for year mode.",
		options =
		{
			{description = "10", data = 10},
			{description = "20", data = 20},
			{description = "30", data = 30},
			{description = "40", data = 40},
			{description = "50", data = 50},
			{description = "70", data = 70},
		},
		default = 70,
    }, 
	{
        name = "client_reset",
        label = "Non-admin Menu Reset",
		hover = "Allow non-admins to reset their own boards?",
		options =
		{
			{description = "Yes", data = true},
			{description = "No", data = false},
		},
		default = true,
    }, 
	{
        name = "win_message",
        label = "Win Message",
		hover = "Tell others when someone clears their menu?",
		options =
		{
			{description = "Yes", data = true},
			{description = "No", data = false},
		},
		default = true,
    }, 
	{
        name = "default_mode",
        label = "Default Mode",
		hover = "This sets the default game mode.",
		options =
		{
			{description = "Yearly", data = 2},
			{description = "Seasonal", data = 3},
			{description = "Cycle", data = 1},
		},
		default = 1,
    }, 
	{
        name = "default_menuType",
        label = "Default Menu Type",
		hover = "This sets the default menu.",
		options =
		{
			{description = "All crockpot", data = 1},
			{description = "10 rand crockpot", data = 2},
			{description = "20 rand crockpot", data = 3},
			{description = "10 rand food", data = 4},
			{description = "20 rand food", data = 5},
			{description = "30 rand food", data = 6},
		},
		default = 3,
    }, 
	{
        name = "default_easy",
        label = "Default Hard Items",
		hover = "This adds hard items by default.",
		options =
		{
			{description = "No", data = 1},
			{description = "Yes", data = 2},
		},
		default = 1,
    }, 
	{
        name = "default_rare",
        label = "Default Rare Items",
		hover = "This adds rare items by default.",
		options =
		{
			{description = "No", data = 1},
			{description = "Yes", data = 2},
		},
		default = 1,
    }, 
	{
        name = "default_longterm",
        label = "Default Longterm Items",
		hover = "This adds longterm items by default.",
		options =
		{
			{description = "No", data = 1},
			{description = "Yes", data = 2},
		},
		default = 1,
    }, 
	{
        name = "default_caves",
        label = "Default Cave Items",
		hover = "This adds cave items by default.",
		options =
		{
			{description = "No", data = 1},
			{description = "Yes", data = 2},
		},
		default = 1,
    }, 
}