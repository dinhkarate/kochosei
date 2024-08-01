-- This information tells other players more about the mod
name = "Kochosei in Onmyoji"
description = [[
Cảm ơn bạn đã ghé qua, bạn có thể dùng nút cấu hình phía dưới, nếu có bất kì vấn đề gì với Kochosei nhắn cho bọn mình biết nhé.

Thank you for using this mod, you can use the config button below and let me know if there is any problem with Kochosei.
	
]]
author = "Mio, dinhkarate, Haruhi Kawaii"
version = "18.0.21"
forumthread = ""

folder_name = folder_name or "workshop-"
if folder_name:match("2978066706") then
	name = "Kochosei Bản Test"
elseif folder_name:match("2733891656") then
	name = "Kochosei in Onmyoji"
else
	name = "Test Local"
	-- ?
end

api_version = 10

-- Compatible with Don't Starve Together
dst_compatible = true

-- Not compatible with Don't Starve
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false

-- Character mods are required by all clients
all_clients_require_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- The mod's tags displayed on the server list
server_filter_tags = { "character", "kochosei", "onmyoji" }
string = string or ""
local function Title(title)
	return {
		name = title,
		hover = "",
		options = { { description = "", data = 0 } },
		default = 0,
	}
end

local option_kocho = {}
local optionsbasic = {}
local optionslave_basic_damage = {}
local optionsbasic_weapon = {}
local optionsbasic_weapon_dub = {}

local options_kocho_so_gi_be_xiu_vay = { -- Ủa, sao không lặp for được nữa?
	{ description = "0%", data = 0 },
	{ description = "10%", data = 0.1 },
	{ description = "20%", data = 0.2 },
	{ description = "30%", data = 0.3 },
	{ description = "40%", data = 0.4 },
	{ description = "50%", data = 0.6 },
	{ description = "60%", data = 0.6 },
	{ description = "70%", data = 0.7 },
	{ description = "80%", data = 0.8 },
	{ description = "90%", data = 0.9 },
	{ description = "95%", data = 0.95 },
}
local mot_toi_20 = {
	{ description = "1", data = 1 },
	{ description = "2", data = 2 },
	{ description = "3", data = 3 },
	{ description = "4", data = 4 },
	{ description = "5", data = 5 },
	{ description = "6", data = 6 },
	{ description = "7", data = 7 },
	{ description = "8", data = 8 },
	{ description = "9", data = 9 },
	{ description = "10", data = 10 },
	{ description = "20", data = 20 },
	{ description = "50", data = 50 },
	{ description = "100", data = 100 },
	{ description = "250", data = 250 },
	{ description = "500", data = 500 },
	{ description = "1000", data = 1000 },
	{ description = "2000", data = 2000 },
}

for i = 1, 10, 1 do
	option_kocho[#option_kocho + 1] = {
		description = string.format("%d", i),
		data = i,
	}
end

for i = 10, 100, 10 do
	optionsbasic_weapon[#optionsbasic_weapon + 1] = {
		description = string.format("%d", i),
		data = i,
	}
end
for i = 200, 1000, 100 do
	optionsbasic_weapon[#optionsbasic_weapon + 1] = {
		description = string.format("%d", i),
		data = i,
	}
end

for i = 50, 1000, 50 do
	optionsbasic_weapon_dub[#optionsbasic_weapon_dub + 1] = {
		description = string.format("%d", i),
		data = i,
	}
end
optionsbasic_weapon_dub[#optionsbasic_weapon_dub + 1] = {
	description = "Infinite",
	data = "Infinite",
}

for i = 50, 1000, 50 do
	optionslave_basic_damage[#optionslave_basic_damage + 1] = {
		description = string.format("%d", i),
		data = i,
	}
	optionsbasic[#optionsbasic + 1] = {
		description = string.format("%d", i),
		data = i,
	}
end

for i = 2000, 10000, 1000 do
	optionslave_basic_damage[#optionslave_basic_damage + 1] = {
		description = string.format("%d", i),
		data = i,
	}
end

for i = 20000, 100000, 10000 do
	optionslave_basic_damage[#optionslave_basic_damage + 1] = {
		description = string.format("%d", i),
		data = i,
	}
end

local kocho_hunger = {
	name = "kocho_hunger",
	label = "1) Kochosei Hunger 󰀎",
	hover = "How much hunger Kocho has?",
	options = optionsbasic,
	default = 150,
}
local kocho_sanity = {
	name = "kocho_sanity",
	label = "2) Kochosei Sanity 󰀓",
	hover = "How much sanity Kocho has?",
	options = optionsbasic,
	default = 200,
}
local kocho_hp = {
	name = "kocho_hp",
	label = "3) Kochosei HP 󰀍",
	hover = "How much HP Kocho has?",
	options = optionsbasic,
	default = 150,
}
local kocho_damage = {
	name = "kocho_damage",
	label = "5) Kochosei Damage Multiple 󰀘",
	hover = "How much damage multiple Kocho has?",
	options = option_kocho,
	default = 1,
}
local kocho_armor_fix = {
	name = "kocho_armor_fix",
	label = "4) Kochosei Armor",
	hover = "How much armor Kocho has?",
	options = options_kocho_so_gi_be_xiu_vay,
	default = 0,
}

local kocho_slave_damage = {
	name = "kocho_slave_damage",
	label = "6) Kochosei Slave Damage 󰀘",
	hover = "How much damage slave has?",
	options = optionslave_basic_damage,
	default = 50,
}

local kocho_slave_hp = {
	name = "kocho_slave_hp",
	label = "8) Kochosei Slave HP 󰀍",
	hover = "How much hp slave has?",
	options = optionslave_basic_damage,
	default = 100,
}
local deerclops_slave_health = {
	name = "deerclops_slave_health",
	label = "10) Deerclops health 󰀍",
	hover = "Health of Deerclops slave",
	options = optionslave_basic_damage,
	default = 100,
}
local dragonfly_slave_health = {
	name = "dragonfly_slave_health",
	label = "11) Dragonfly health 󰀍",
	hover = "Health of Dragonfly slave",
	options = optionslave_basic_damage,
	default = 100,
}
local bearger_slave_health = {
	name = "bearger_slave_health",
	label = "12) Bearger health 󰀍",
	hover = "Health of Bearger slave",
	options = optionslave_basic_damage,
	default = 100,
}
local stalker_altrium_slave_health = {
	name = "stalker_altrium_slave_health",
	label = "13) Acientfuelweaver health 󰀍",
	hover = "Health of Acientfuelweaver slave",
	options = optionslave_basic_damage,
	default = 100,
}
local deerclops_slave_damage = {
	name = "deerclops_slave_damage",
	label = "14) Deerclops damage 󰀘",
	hover = "Damage of Deerclops slave",
	options = optionslave_basic_damage,
	default = 50,
}
local dragonfly_slave_damage = {
	name = "dragonfly_slave_damage",
	label = "15) Dragonfly damage 󰀘",
	hover = "Damage of Dragonfly slave",
	options = optionslave_basic_damage,
	default = 50,
}
local bearger_slave_damage = {
	name = "bearger_slave_damage",
	label = "16) Bearger damage 󰀘",
	hover = "Damage of Bearger slave",
	options = optionslave_basic_damage,
	default = 50,
}
local stalker_altrium_slave_damage = {
	name = "stalker_altrium_slave_damage",
	label = "17) Acientfuelweaver damage 󰀘",
	hover = "Damage of Acientfuelweaver slave",
	options = optionslave_basic_damage,
	default = 100,
}
local purplemagic_damage = {
	name = "purplemagic_damage",
	label = "19) Purplemagic Damage 󰀘",
	hover = "How much damage Purplemagic has?",
	options = optionsbasic_weapon,
	default = 10,
}
local purplemagic_durability = {
	name = "purplemagic_durability",
	label = "20) Purplemagic Durability",
	hover = "How much Purplemagic Durability has?",
	options = optionsbasic_weapon_dub,
	default = 50,
}
local demonlord_damage = {
	name = "demonlord_damage",
	label = "21) Demonlord Damage 󰀘",
	hover = "How much damage Demonlord has?",
	options = optionsbasic_weapon,
	default = 10,
}
local demonlord_durability = {
	name = "demonlord_durability",
	label = "22) Demonlord Durability",
	hover = "How much Demonlord Durability has?",
	options = optionsbasic_weapon_dub,
	default = 50,
}
local kocho_miohm_damage = {
	name = "kocho_miohm_damage",
	label = "23) Miohm Basic Damage 󰀘",
	hover = "How much damage basic miohm has?",
	options = optionsbasic_weapon,
	default = 10,
}
local kocho_miohm_dub = {
	name = "kocho_miohm_dub",
	label = "24) Miohm Durability",
	hover = "Kochosei Miohm Durability",
	options = optionsbasic_weapon_dub,
	default = 500,
}
local kocho_miohm_damage_spell = {
	name = "kocho_miohm_damage_spell",
	label = "27) Miohm Damage Spell 󰀘",
	hover = "Kochosei Miohm Damage Spell",
	options = optionslave_basic_damage,
	default = 50,
}
local kocho_miohm_repair = {
	name = "kocho_miohm_repair",
	label = "28) Miohm Repair",
	hover = "Kochosei Miohm Repair with gold",
	options = optionsbasic_weapon,
	default = 20,
}
local kocho_sword_damage = {
	name = "kocho_sword_damage",
	label = "29) Kochosei Sword Damage 󰀘",
	hover = "How much damage basic sword has?",
	options = optionsbasic_weapon,
	default = 50,
}
local kocho_sword_dub = {
	name = "kocho_sword_dub",
	label = "30) Kochosei Sword Durability",
	hover = "Kochosei Sword Durability",
	options = optionsbasic_weapon_dub,
	default = 500,
}
local kocho_luckyhammer_durability = {
	name = "kocho_luckyhammer_durability",
	label = "31)Lucky hammer durability",
	hover = "Lucky hammer durability",
	options = optionsbasic_weapon_dub,
	default = 50,
}

configuration_options = {
	{
		name = "kochosei_va_waifu",
		label = "Kochosei adjusts power",
		hover = "Kochosei adjusts its power based on enabled mods",
		options = {
			{ description = "No", data = 0 },
			{ description = "Yes", data = 1 },
		},
		default = 1,
	},
	{
		name = "regemapkochosei",
		label = "Regenerate  Butterfly Island?",
		options = {
			{ description = "Yes", data = 0 }, --- Cái nài bị ngược do t không muốn người ta phải config lại, sorry ae, sorry bro
			{ description = "No", data = 1 },
		},
		default = 0,
	},
	{
		name = "keykocho",
		label = "A) Key to sleep",
		options = {
			{ description = "INS", data = 277 },
			{ description = "HOME", data = 278 },
			{ description = "Page Up", data = 280 },
			{ description = "Page Dn", data = 281 },
			{ description = "Del", data = 127 },
			{ description = "End", data = 279 },
		},
		default = 279,
	},
	{
		name = "turnoffmusic",
		label = "B) Structure Music",
		options = {
			{ description = "OFF", data = 0 },
			{ description = "ON", data = 1 },
		},
		default = 1,
	},

	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------

	Title("Basic Stats"),
	kocho_hunger,
	kocho_sanity,
	kocho_hp,
	kocho_armor_fix,
	kocho_damage,
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------

	Title("Kochosei Slave"),
	kocho_slave_damage,
	kocho_slave_hp,
	{
		name = "kocho_slave_max_fix",
		label = "7) Kochosei Slave Max",
		hover = "How much slave has?",
		options = mot_toi_20,
		default = 2,
	},
	{
		name = "kocho_slave_cost",
		label = "9) Kochosei Slave Cost",
		hover = "How much sanity cost to spawn slave?",
		options = {
			{ description = "10", data = 10 },
			{ description = "30", data = 30 },
			{ description = "40", data = 40 },
			{ description = "50", data = 50 },
		},
		default = 10,
	},

	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	Title("Health of Boss slave"),
	deerclops_slave_health,
	dragonfly_slave_health,
	bearger_slave_health,
	stalker_altrium_slave_health,

	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------

	Title("Damage of Boss slave"),
	deerclops_slave_damage,
	dragonfly_slave_damage,
	bearger_slave_damage,
	stalker_altrium_slave_damage,

	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------

	Title("Miku Usagi backpack"),
	{
		name = "miku_usagi_backpack",
		label = "18) Miku Usagi backpack refresh",
		hover = "Bigger is fresher",
		options = {
			{ description = "Nothing", data = 1 },
			{ description = "20%", data = 0.9 },
			{ description = "30%", data = 0.8 },
			{ description = "40%", data = 0.7 },
			{ description = "50%", data = 0.6 },
			{ description = "60%", data = 0.5 },
			{ description = "70%", data = 0.4 },
			{ description = "80%", data = 0.3 },
			{ description = "90%", data = 0.2 },
			{ description = "100%", data = 0.1 },
		},
		default = 0.5,
	},

	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------

	Title("Kochosei Weapon"),
	purplemagic_damage,
	purplemagic_durability,
	demonlord_damage,
	demonlord_durability,
	kocho_miohm_damage,
	kocho_miohm_dub,

	{
		name = "sat_thuong_pt_mau",
		label = "Percent Health Damage",
		hover = "Percent Health Damage Miohm",
		options = {
			{ description = "0.25", data = 0.25 },
			{ description = "0.5", data = 0.5 },
			{ description = ".75", data = 0.75 },
			{ description = "1", data = 1 },
			{ description = "2.5", data = 2.5 },
			{ description = "5", data = 5 },
			{ description = "7.5", data = 7.5 },
			{ description = "10", data = 10 },
			{ description = "20", data = 20 },
		},
		default = 0.25,
	},
	{
		name = "sat_thuong_pt_mau_hoatdong",
		label = "Percent Health Damage",
		hover = "Percent Health Damage Miohm",
		options = {
			{ description = "10000", data = 10000 },
			{ description = "25000", data = 25000 },
			{ description = "50000", data = 50000 },
			{ description = "100000", data = 100000 },
			{ description = "250000", data = 250000 },
			{ description = "500000", data = 500000 },
			{ description = "1000000", data = 1000000 },
		},
		default = 100000,
	},
	{
		name = "kocho_miohm_max_level",
		label = "25) Miohm max damage",
		hover = "Max damage of Miohm",
		options = {
			{ description = "50", data = 50 },
			{ description = "100", data = 100 },
			{ description = "200", data = 200 },
			{ description = "400", data = 400 },
			{ description = "500", data = 500 },
			{ description = "700", data = 700 },
			{ description = "1000", data = 1000 },
			{ description = "2000", data = 2000 },
			{ description = "3000", data = 3000 },
			{ description = "4000", data = 4000 },
			{ description = "5000", data = 5000 },
			{ description = "Infinite", data = 99999999999 },
		},
		default = 100,
	},
	{
		name = "kocho_lv_perkill",
		label = "26) Increase damage per kill",
		hover = " Increase damage per kill",
		options = mot_toi_20,
		default = 1,
	},
	kocho_miohm_damage_spell,
	kocho_miohm_repair,
	kocho_sword_damage,
	kocho_sword_dub,
	kocho_luckyhammer_durability,
	{
		name = "kocho_acientbooks_cooldown",
		label = "32)Acientbooks Cooldown",
		hover = "Acient books cooldown",
		options = {
			{ description = "10s", data = 10 },
			{ description = "20s", data = 20 },
			{ description = "40s", data = 40 },
			{ description = "60s", data = 60 },
			{ description = "120s", data = 120 },
			{ description = "180s", data = 180 },
			{ description = "240s", data = 240 },
			{ description = "360s", data = 360 },
			{ description = "480s", data = 480 },
			{ description = "560s", data = 560 },
		},
		default = 120,
	},

	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------

	Title("Kochosei Hat"),
	{
		name = "kocho_hat1_durability",
		label = "33) Kochosei Hat1 Durability",
		hover = "How durable Kochosei Hat 1 should be?",
		options = {
			{ description = "315", data = 315, hover = "Same as Football Helmet" },
			{ description = "420", data = 420 },
			{ description = "840", data = 840, hover = "Same as Thulecite Crown" },
			{ description = "1050", data = 1050 },
			{ description = "1500", data = 1500 },
			{ description = "2000", data = 2000 },
			{ description = "4000", data = 4000 },
			{ description = "Infinite", data = "Infinite" },
		},
		default = 315,
	},
	{
		name = "kocho_hat1_absorption",
		label = "34) Kochosei Hat1 Armor",
		hover = "How much Kochosei Hat 1 reduces incoming damage?",
		options = options_kocho_so_gi_be_xiu_vay,
		default = 0.8,
	},

	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------

	Title("Kochotambourin Heal"),
	{
		name = "kocho_tambourin_heal",
		label = "35) Kochotambourin Heal 󰀍",
		hover = "Kochotambourin Heal",
		options = {
			{ description = "5", data = 5 },
			{ description = "10", data = 10 },
			{ description = "15", data = 15 },
			{ description = "20", data = 20 },
			{ description = "50", data = 50 },
		},
		default = 10,
	},

	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------

	Title("Kochosei Apple tree"),
	{
		name = "Kochosei's apple spawn rates",
		label = "36) Kochosei's apple spawn rates",
		options = {
			{ description = "Default", data = "Default" },
			{ description = "More", data = "More" },
			{ description = "Less", data = "Less" },
			{ description = "None", data = "None" },
		},
		default = "Default",
	},
}
