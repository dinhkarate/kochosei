local Ingredient = GLOBAL.Ingredient
local TECH = GLOBAL.TECH

AddCharacterRecipe(
	"miohm",
	{ Ingredient("goldnugget", 10), Ingredient("rope", 1), Ingredient("hammer", 1) },
	TECH.NONE,
	{ atlas = "images/inventoryimages/kochosei_inv.xml", image = "miohm.tex", builder_tag = "kochosei" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_christmast_torch1",
	{ Ingredient("beeswax", 5), Ingredient("deerclops_eyeball", 1), Ingredient("log", 20), Ingredient("nitre", 10)  },
	TECH.NONE,
	{ atlas = "images/inventoryimages/kochosei_inv.xml", image = "kochosei_christmast_torch1.tex", builder_tag = "kochosei" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_purplesword",
	{ Ingredient("goldnugget", 10), Ingredient("axe", 1), Ingredient("log", 15) },
	TECH.NONE,
	{ atlas = "images/inventoryimages/kochosei_inv.xml", image = "kocho_purplesword.tex", builder_tag = "kochosei" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_purplemagic",
	{ Ingredient("goldnugget", 10), Ingredient("purplegem", 1), Ingredient("petals", 5) },
	TECH.NONE,
	{ atlas = "images/inventoryimages/kochosei_inv.xml", image = "kochosei_purplemagic.tex", builder_tag = "kochosei" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_demonlord",
	{ Ingredient("shadowheart", 1), Ingredient("skeletonhat", 1) },
	TECH.MAGIC_THREE,
	{ atlas = "images/inventoryimages/kochosei_inv.xml", image = "kochosei_demonlord.tex", builder_tag = "kochosei" },

	{ "CHARACTER" }
)

AddCharacterRecipe(
	"miku_usagi_backpack",
	{ Ingredient("goldnugget", 5), Ingredient("silk", 5), Ingredient("gears", 1) },
	TECH.NONE,
	{ atlas = "images/inventoryimages/kochosei_inv.xml", image = "miku_usagi_backpack.tex", builder_tag = "kochosei" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochotambourin",
	{ Ingredient("goldnugget", 10), Ingredient("greengem", 1), Ingredient("butterfly", 5) },
	TECH.NONE,
	{ atlas = "images/inventoryimages/kochosei_inv.xml", image = "kochotambourin.tex", builder_tag = "kochosei" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_hat1",
	{ Ingredient("silk", 3), Ingredient("rope", 1), Ingredient("pigskin", 1) },
	TECH.NONE,
	{ atlas = "images/inventoryimages/kochosei_inv.xml", image = "kochosei_hat1.tex", builder_tag = "kochosei" },
	{ "CHARACTER" }
)
------------------------------------ Cái này sẽ chạy khi không có modded api-----------------------------
if GLOBAL.TUNING.KOCHOSEI_CHECKMOD ~= 1 then
	AddCharacterRecipe(
		"kochosei_hat2",
		{ Ingredient("silk", 3), Ingredient("rope", 1), Ingredient("pigskin", 1) },
		TECH.NONE,
		{ atlas = "images/inventoryimages/kochosei_inv.xml", image = "kochosei_hat2.tex", builder_tag = "kochosei" },
		{ "CHARACTER" }
	)

	AddCharacterRecipe(
		"kochosei_hat3",
		{ Ingredient("silk", 3), Ingredient("rope", 1), Ingredient("pigskin", 1) },
		TECH.NONE,
		{ atlas = "images/inventoryimages/kochosei_inv.xml", image = "kochosei_hat3.tex", builder_tag = "kochosei" },
		{ "CHARACTER" }
	)
end

------------------------------------------------------------------------------------------------------------
AddCharacterRecipe(
	"kochosei_house",
	{ Ingredient("log", 40) },
	TECH.SCIENCE_ONE,
	{
		atlas = "images/inventoryimages/kochosei_inv.xml",
		image = "kochosei_house_icon.tex",
		builder_tag = "kochosei",
		placer = "kochosei_house_placer",
	},

	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_torigate",
	{ Ingredient("log", 20) },
	TECH.SCIENCE_ONE,
	{
		atlas = "images/inventoryimages/kochosei_inv.xml",
		image = "kochosei_torigate.tex",
		builder_tag = "kochosei",
		placer = "kochosei_torigate_placer",
		min_spacing = 1
	},

	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_wishlamp",
	{ Ingredient("log", 10) },
	TECH.SCIENCE_ONE,
	{
		atlas = "images/inventoryimages/kochosei_inv.xml",
		image = "kochosei_wishlamp.tex",
		builder_tag = "kochosei",
		placer = "kochosei_wishlamp_placer",
		min_spacing = 1
	},

	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_building_redlantern",
	{ Ingredient("log", 10) },
	TECH.SCIENCE_ONE,
	{
		atlas = "images/inventoryimages/kochosei_inv.xml",
		image = "kochosei_building_redlantern.tex",
		builder_tag = "kochosei",
		placer = "kochosei_building_redlantern_placer",
		min_spacing = 1
	},

	{ "CHARACTER" }
)
--Con cò mio
------------------------------

AddCharacterRecipe(
	"kocho_lotus",
	{ Ingredient("petals", 20) },
	TECH.SCIENCE_ONE,
	{ atlas = "images/inventoryimages/kochosei_inv.xml", image = "kocho_lotus_flower.tex", builder_tag = "kochosei" },

	{ "CHARACTER" }
)

-------------------------------------- DST ITEM ----------------------------------------------------------------------

AddCharacterRecipe(
	"kocho_butterfly",
	{ Ingredient("petals", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "butterfly" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_moonbutterfly",
	{ Ingredient("moon_tree_blossom", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "moonbutterfly" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_messagebottleempty",
	{ Ingredient("moonglass", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "messagebottleempty" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_chum",
	{ Ingredient("spoiled_food", 10) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "chum" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_oceanfishinglure_hermit_rain",
	{ Ingredient("stinger", 10) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "oceanfishinglure_hermit_rain" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_oceanfishinglure_hermit_snow",
	{ Ingredient("stinger", 5) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "oceanfishinglure_hermit_snow" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_oceanfishinglure_hermit_heavy",
	{ Ingredient("stinger", 5) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "oceanfishinglure_hermit_heavy" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_oceanfishinglure_hermit_drowsy",
	{ Ingredient("stinger", 6) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "oceanfishinglure_hermit_drowsy" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_oceanfishinglure_spoon_red",
	{ Ingredient("stinger", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "oceanfishinglure_spoon_red" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_oceanfishinglure_spoon_green",
	{ Ingredient("stinger", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "oceanfishinglure_spoon_green" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_oceanfishinglure_spoon_blue",
	{ Ingredient("stinger", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "oceanfishinglure_spoon_blue" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_oceanfishingbobber_oval",
	{ Ingredient("log", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "oceanfishingbobber_oval" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_supertacklecontainer",
	{ Ingredient("boneshard", 10) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "supertacklecontainer" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_oceanfishingrod",
	{ Ingredient("log", 5) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "oceanfishingrod" },
	{ "CHARACTER" }
)

if TUNING.KOCHOSEI_WICK ~= 0 and TUNING.KOCHOSEI_WICK2 == 0 then
	AddCharacterRecipe(
		"kocho_bookstation",
		{ Ingredient("livinglog", 2), Ingredient("papyrus", 4), Ingredient("featherpencil", 1) },
		TECH.NONE,
		{ builder_tag = "kochosei", product = "bookstation", placer = "bookstation_placer" },
		{ "CHARACTER" }
	)
end
if TUNING.KOCHOSEI_WICK2 ~= 1 then
	AddCharacterRecipe(
		"kocho_book_fish",
		{Ingredient("papyrus", 2), Ingredient("oceanfishingbobber_ball", 2)},	
		TECH.NONE,
		{ builder_tag = "kochosei", product = "book_fish" },
		{ "CHARACTER" }
	)

	AddCharacterRecipe(
		"kocho_book_rain",
		{Ingredient("papyrus", 2), Ingredient("goose_feather", 2)}, 		
		TECH.NONE,
		{ builder_tag = "kochosei", product = "book_rain" },
		{ "CHARACTER" }
	)

	AddCharacterRecipe(
		"kocho_book_moon",
		{Ingredient("papyrus", 2), Ingredient("opalpreciousgem", 1), Ingredient("moonbutterflywings", 2)},
		TECH.NONE,
		{ builder_tag = "kochosei", product = "book_moon" },
		{ "CHARACTER" }
	)

	AddCharacterRecipe(
		"kocho_book_silviculture",
		{Ingredient("papyrus", 2), Ingredient("livinglog", 1)},		
		TECH.NONE,
		{ builder_tag = "kochosei", product = "book_silviculture" },
		{ "CHARACTER" }
	)
	AddCharacterRecipe(
		"kocho_book_horticulture_upgraded",
		{Ingredient("book_horticulture", 1), Ingredient("featherpencil", 1), Ingredient("papyrus", 2)},	
		TECH.NONE,
		{ builder_tag = "kochosei", product = "book_horticulture_upgraded" },
		{ "CHARACTER" }
	)

	AddCharacterRecipe(
		"kocho_book_fire",
		{Ingredient("book_brimstone", 1), Ingredient("featherpencil", 1), Ingredient("papyrus", 2)},
		TECH.NONE,
		{ builder_tag = "kochosei", product = "book_fire" },
		{ "CHARACTER" }
	)

	AddCharacterRecipe(
		"kocho_book_tentacles",
		{Ingredient("papyrus", 2), Ingredient("tentaclespots", 1)},				
		TECH.NONE,
		{ builder_tag = "kochosei", product = "book_tentacles" },
		{ "CHARACTER" }
	)
end

AddCharacterRecipe(
	"kocho_polly_rogershat",
	{ Ingredient("silk", 10) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "polly_rogershat" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_antlionhat",
	{ Ingredient("silk", 10) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "antlionhat" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_honeycomb",
	{ Ingredient("honey", 10) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "honeycomb" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_compostwrap",
	{ Ingredient("poop", 3), Ingredient("spoiled_food", 1) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "compostwrap" },
	{ "CHARACTER" }
)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

AddCharacterRecipe(
	"kochosei_lantern",
	{ Ingredient("butterfly", 5), Ingredient("twigs", 10) },
	TECH.NONE,
	{ atlas = "images/inventoryimages/kochosei_inv.xml", image = "kochosei_lantern.tex", builder_tag = "kochosei" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_streetlight1_left",
	{ Ingredient("log", 10), Ingredient("rope", 1), Ingredient("petals", 2) },
	TECH.NONE,
	{
		atlas = "images/inventoryimages/kochosei_inv.xml",
		image = "kochosei_streetlight1_left.tex",
		builder_tag = "kochosei",
		placer = "kochosei_streetlight1_left_placer",
		min_spacing = 1
	},

	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_streetlight1_right",
	{ Ingredient("log", 10), Ingredient("rope", 1), Ingredient("petals", 2) },
	TECH.SCIENCE_ONE,
	{
		atlas = "images/inventoryimages/kochosei_inv.xml",
		image = "kochosei_streetlight1_right.tex",
		builder_tag = "kochosei",
		placer = "kochosei_streetlight1_right_placer",
		min_spacing = 1
	},

	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_streetlight1_musicbox",
	{ Ingredient("log", 40), Ingredient("rope", 20), Ingredient("petals", 20) },
	TECH.SCIENCE_ONE,
	{
		atlas = "images/inventoryimages/kochosei_inv.xml",
		image = "kochosei_streetlight1_musicbox.tex",
		builder_tag = "kochosei",
		placer = "kochosei_streetlight1_musicbox_placer",
		min_spacing = 1
	},

	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_madscience_lab",
	{ Ingredient("log", 20), Ingredient("transistor", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "madscience_lab" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_miku_cos",
	{ Ingredient("petals", 1) },
	TECH.SCIENCE_ONE,
	{ atlas = "images/inventoryimages/kochosei_inv.xml", image = "kocho_miku_cos.tex", builder_tag = "kochosei" },

	{ "CHARACTER" }
)
AddCharacterRecipe(
	"kocho_miku_back",
	{ Ingredient("petals", 1) },
	TECH.SCIENCE_ONE,
	{ atlas = "images/inventoryimages/kochosei_inv.xml", image = "kocho_miku_back.tex", builder_tag = "kochosei" },

	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_apple",
	{ Ingredient("berries", 1), Ingredient("acorn", 1), Ingredient("spoiled_food", 1) },

	TECH.SCIENCE_ONE,
	{ atlas = "images/inventoryimages/kochosei_inv.xml", image = "kochosei_apple.tex", builder_tag = "kochosei" },

	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_umbrella",
	{ Ingredient("petals", 10), Ingredient("umbrella", 1) },

	TECH.NONE,
	{ atlas = "images/inventoryimages/kochosei_inv.xml", image = "kochosei_umbrella.tex", builder_tag = "kochosei" },

	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_hatfl",
	{ Ingredient("flowerhat", 1), Ingredient("moonglass", 25), Ingredient("hivehat", 1),Ingredient("purebrilliance", 4) },

	TECH.NONE,
	{ atlas = "images/inventoryimages/kochosei_inv.xml", image = "kochosei_hatfl.tex", builder_tag = "kochosei" },

	{ "CHARACTER" }
)

AddCharacterRecipe(
	"lucky_hammer",
	{ Ingredient("goldnugget", 50), Ingredient("log", 20), Ingredient("yellowgem", 5) },

	TECH.NONE,
	{ atlas = "images/inventoryimages/kochosei_inv.xml", image = "lucky_hammer.tex", builder_tag = "kochosei" },

	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_ancient_books",
	{ Ingredient("walrus_tusk", 10), Ingredient("papyrus", 10), Ingredient("featherpencil", 2), Ingredient("rope", 4) },

	TECH.NONE,
	{
		atlas = "images/inventoryimages/kochosei_inv.xml",
		image = "kochosei_ancient_books.tex",
		builder_tag = "kochosei",
	},

	{ "CHARACTER" }
)


-- seed craft
AddCharacterRecipe(
	"kochosei_premium_seed_packet",
	{ Ingredient("goldnugget", 6), Ingredient("papyrus", 1) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "yotc_seedpacket_rare" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_medium_seed_packet",
	{ Ingredient("goldnugget", 3) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "yotc_seedpacket" },
	{ "CHARACTER" }
)

--kitcoon craft
AddCharacterRecipe(
	"kochosei_ticoon",
	{ Ingredient("goldnugget", 10) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "ticoon_builder" },
	{ "CHARACTER" }
)

--FOOD craft
AddCharacterRecipe(
	"kochosei_butter",
	{ Ingredient("honey", 20) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "butter" },
	{ "CHARACTER" }
)