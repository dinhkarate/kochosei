local Ingredient = GLOBAL.Ingredient
local TECH = GLOBAL.TECH

local kochosei_tab = {
	name = "kochosei_tab",
	atlas = "images/inventoryimages/kochosei_inv.xml",
	image = "kochosei_tab_icon.tex",
}

-- Adding custom filters
AddRecipeFilter(kochosei_tab)

STRINGS.UI.CRAFTING_FILTERS.KOCHOSEI_TAB = "Cái con cò gì thế này?"
--[[
AddCharacterRecipe(
	"kochosei_fridge_5x5",
	{ Ingredient("goldnugget", 2), Ingredient("gears", 1), Ingredient("cutstone", 1) },
	TECH.SCIENCE_TWO,
	{
		builder_tag = "kochosei",
		placer = "kochosei_fridge_5x5_placer",
		min_spacing = 1,
	},

	{ "CHARACTER" }
)
AddCharacterRecipe(
	"kochosei_chest_5x5",
	{ Ingredient("boards", 3), Ingredient("rope", 3), Ingredient("petals", 2) },
	TECH.SCIENCE_ONE,
	{
		builder_tag = "kochosei",
		placer = "kochosei_chest_5x5_placer",
		min_spacing = 1,
	},

	{ "CHARACTER" }
)
--]]

AddCharacterRecipe(
	"doro_xamchiemtraidat",
	{ Ingredient("twigs", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"miohm",
	{ Ingredient("goldnugget", 10), Ingredient("rope", 1), Ingredient("hammer", 1) },
	TECH.NONE,
	{ builder_tag = "kochosei" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_christmast_torch1",
	{ Ingredient("beeswax", 5), Ingredient("deerclops_eyeball", 1), Ingredient("log", 20), Ingredient("nitre", 10) },
	TECH.NONE,
	{
		builder_tag = "kochosei",
	},
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_purplesword",
	{ Ingredient("goldnugget", 10), Ingredient("axe", 1), Ingredient("log", 15) },
	TECH.NONE,
	{ builder_tag = "kochosei" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_purplemagic",
	{ Ingredient("goldnugget", 10), Ingredient("purplegem", 1), Ingredient("petals", 5) },
	TECH.NONE,
	{ builder_tag = "kochosei" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_demonlord",
	{ Ingredient("shadowheart", 1), Ingredient("skeletonhat", 1) },
	TECH.MAGIC_THREE,
	{ builder_tag = "kochosei" },

	{ "CHARACTER" }
)

AddCharacterRecipe(
	"miku_usagi_backpack",
	{ Ingredient("goldnugget", 5), Ingredient("silk", 5), Ingredient("gears", 1) },
	TECH.NONE,
	{ builder_tag = "kochosei" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochotambourin",
	{ Ingredient("goldnugget", 10), Ingredient("greengem", 1), Ingredient("butterfly", 5) },
	TECH.NONE,
	{ builder_tag = "kochosei" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_hat2",
	{ Ingredient("silk", 3), Ingredient("rope", 1), Ingredient("petals", 10) },
	TECH.NONE,
	{ builder_tag = "kochosei" },
	{ "CHARACTER" }
)

------------------------------------ Cái này sẽ chạy khi không có modded api-----------------------------
-- Thế ko có modded api thì coi như tịt ngòi ? Verify đã thay đổi, không còn dùng 3 item craft riêng biệt nữa mà dùng sora api

------------------------------------------------------------------------------------------------------------
AddCharacterRecipe("kochosei_house", { Ingredient("log", 40) }, TECH.SCIENCE_ONE, {
	builder_tag = "kochosei",
	placer = "kochosei_house_placer",
}, { "CHARACTER" })

AddCharacterRecipe("kochosei_torigate", { Ingredient("log", 20) }, TECH.SCIENCE_ONE, {
	builder_tag = "kochosei",
	placer = "kochosei_torigate_placer",
	min_spacing = 1,
}, { "CHARACTER" })

AddCharacterRecipe("kochosei_wishlamp", { Ingredient("log", 10) }, TECH.SCIENCE_ONE, {
	builder_tag = "kochosei",
	placer = "kochosei_wishlamp_placer",
	min_spacing = 1,
}, { "CHARACTER" })

AddCharacterRecipe("kochosei_building_redlantern", { Ingredient("log", 10) }, TECH.SCIENCE_ONE, {
	builder_tag = "kochosei",
	placer = "kochosei_building_redlantern_placer",
	min_spacing = 1,
}, { "CHARACTER" })

AddCharacterRecipe("kochosei_may_gacha", { Ingredient("log", 10) }, TECH.SCIENCE_ONE, {
	builder_tag = "kochosei",
	placer = "kochosei_may_gacha_placer",
	min_spacing = 1,
}, { "CHARACTER" })

----------------------Con cò mio------------------------------

AddCharacterRecipe(
	"kocho_lotus",
	{ Ingredient("petals", 20) },
	TECH.SCIENCE_ONE,
	{ builder_tag = "kochosei" },

	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_thien_su_ban_phuc_xanh",
	{ Ingredient("reviver", 3), Ingredient("spidergland", 20) },
	TECH.ANCIENT_TWO,
	{
		numtogive = 10,
		builder_tag = "kochosei",
	},

	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_thien_su_ban_phuc_hong",
	{ Ingredient("spoiled_food", 10), Ingredient("lavae_egg", 1) },
	TECH.ANCIENT_TWO,
	{
		numtogive = 50,
		builder_tag = "kochosei",
	},

	{ "CHARACTER" }
)

AddCharacterRecipe("kochosei_thien_su_ban_phuc_cam", { Ingredient("gunpowder", 10) }, TECH.ANCIENT_TWO, {
	numtogive = 10,
	builder_tag = "kochosei",
}, { "CHARACTER" })

-------------------------------------- DST ITEM ----------------------------------------------------------------------

AddRecipe2(
	"kocho_butterfly",
	{ Ingredient("petals", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "butterfly" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_moonbutterfly",
	{ Ingredient("moon_tree_blossom", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "moonbutterfly" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_messagebottleempty",
	{ Ingredient("moonglass", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "messagebottleempty" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_chum",
	{ Ingredient("spoiled_food", 10) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "chum" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_oceanfishinglure_hermit_rain",
	{ Ingredient("stinger", 10) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "oceanfishinglure_hermit_rain" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_oceanfishinglure_hermit_snow",
	{ Ingredient("stinger", 5) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "oceanfishinglure_hermit_snow" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_oceanfishinglure_hermit_heavy",
	{ Ingredient("stinger", 5) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "oceanfishinglure_hermit_heavy" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_oceanfishinglure_hermit_drowsy",
	{ Ingredient("stinger", 6) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "oceanfishinglure_hermit_drowsy" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_oceanfishinglure_spoon_red",
	{ Ingredient("stinger", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "oceanfishinglure_spoon_red" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_oceanfishinglure_spoon_green",
	{ Ingredient("stinger", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "oceanfishinglure_spoon_green" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_oceanfishinglure_spoon_blue",
	{ Ingredient("stinger", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "oceanfishinglure_spoon_blue" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_oceanfishingbobber_oval",
	{ Ingredient("log", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "oceanfishingbobber_oval" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_supertacklecontainer",
	{ Ingredient("boneshard", 10) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "supertacklecontainer" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_oceanfishingrod",
	{ Ingredient("log", 5) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "oceanfishingrod" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_bookstation",
	{ Ingredient("livinglog", 2), Ingredient("papyrus", 4), Ingredient("featherpencil", 1) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "bookstation", placer = "bookstation_placer" },
	{ "KOCHOSEI_TAB" }
)
AddRecipe2(
	"kocho_book_fish",
	{ Ingredient("papyrus", 2), Ingredient("oceanfishingbobber_ball", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "book_fish" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_book_rain",
	{ Ingredient("papyrus", 2), Ingredient("goose_feather", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "book_rain" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_book_moon",
	{ Ingredient("papyrus", 2), Ingredient("opalpreciousgem", 1), Ingredient("moonbutterflywings", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "book_moon" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_book_silviculture",
	{ Ingredient("papyrus", 2), Ingredient("livinglog", 1) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "book_silviculture" },
	{ "KOCHOSEI_TAB" }
)
AddRecipe2(
	"kocho_book_horticulture_upgraded",
	{ Ingredient("book_horticulture", 1), Ingredient("featherpencil", 1), Ingredient("papyrus", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "book_horticulture_upgraded" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_book_fire",
	{ Ingredient("book_brimstone", 1), Ingredient("featherpencil", 1), Ingredient("papyrus", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "book_fire" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_book_tentacles",
	{ Ingredient("papyrus", 2), Ingredient("tentaclespots", 1) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "book_tentacles" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_polly_rogershat",
	{ Ingredient("silk", 10) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "polly_rogershat" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_antlionhat",
	{ Ingredient("silk", 10) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "antlionhat" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_honeycomb",
	{ Ingredient("honey", 10) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "honeycomb" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_compostwrap",
	{ Ingredient("poop", 3), Ingredient("spoiled_food", 1) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "compostwrap" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kocho_madscience_lab",
	{ Ingredient("log", 20), Ingredient("transistor", 2) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "madscience_lab" },
	{ "KOCHOSEI_TAB" }
)
-- seed craft
AddRecipe2(
	"kochosei_premium_seed_packet",
	{ Ingredient("goldnugget", 6), Ingredient("papyrus", 1) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "yotc_seedpacket_rare" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2(
	"kochosei_medium_seed_packet",
	{ Ingredient("goldnugget", 3) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "yotc_seedpacket" },
	{ "KOCHOSEI_TAB" }
)

AddRecipe2("kochosei_harvest_book", { Ingredient(CHARACTER_INGREDIENT.SANITY, 150) }, TECH.NONE, {
	builder_tag = "kochosei",
}, { "KOCHOSEI_TAB" })

--kitcoon craft
AddRecipe2(
	"kochosei_ticoon",
	{ Ingredient("goldnugget", 10) },
	TECH.NONE,
	{ builder_tag = "kochosei", product = "ticoon_builder" },
	{ "KOCHOSEI_TAB" }
)

-- Bán mình cho MCW, đừng cản t
-- Gomen, Amanai. Ore wa ima, omae no tame ni okottenai. Daremo nikunjainai. Ima wa tada tada kono sekai ga kokochi ii.
-- 🫸 🔴🔵🫷, Kyoshiki, "Murasaki" 🤌🫴🟣
if GLOBAL.TUNING.KOCHOSEI_CHECKMOD_KYOUKA == 1 then
	AddRecipe2(
		"lucky_hammer_mcw",
		{ Ingredient("goldnugget", 50), Ingredient("log", 20), Ingredient("yellowgem", 5) },
		TECH.NONE,
		{ builder_tag = "mcw", product = "lucky_hammer" },
		{ "KOCHOSEI_TAB" }
	)
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

AddRecipe2("kochosei_duke_crown", { Ingredient("yellowgem", 1) }, TECH.NONE, {
	builder_tag = nil,
	product = "kochosei_duke_crown",
}, { "KOCHOSEI_TAB" })

AddCharacterRecipe(
	"kochosei_lantern",
	{ Ingredient("butterfly", 5), Ingredient("twigs", 10) },
	TECH.NONE,
	{ builder_tag = "kochosei" },
	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_streetlight1_left",
	{ Ingredient("log", 10), Ingredient("rope", 1), Ingredient("petals", 2) },
	TECH.NONE,
	{

		builder_tag = "kochosei",
		placer = "kochosei_streetlight1_left_placer",
		min_spacing = 1,
	},

	{ "CHARACTER" }
)

AddCharacterRecipe("cay_hoa_sang", { Ingredient("plantmeat", 2), Ingredient("petals", 2) }, TECH.SCIENCE_TWO, {

	builder_tag = "kochosei",
	placer = "cay_hoa_sang_placer",
	min_spacing = 1,
}, { "CHARACTER" })

AddCharacterRecipe(
	"kochosei_streetlight1_right",
	{ Ingredient("log", 10), Ingredient("rope", 1), Ingredient("petals", 2) },
	TECH.SCIENCE_ONE,
	{

		builder_tag = "kochosei",
		placer = "kochosei_streetlight1_right_placer",
		min_spacing = 1,
	},

	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_streetlight1_musicbox",
	{ Ingredient("log", 40), Ingredient("rope", 20), Ingredient("petals", 20) },
	TECH.SCIENCE_ONE,
	{

		builder_tag = "kochosei",
		placer = "kochosei_streetlight1_musicbox_placer",
		min_spacing = 1,
	},

	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kocho_miku_cos",
	{ Ingredient("petals", 1) },
	TECH.SCIENCE_ONE,
	{ builder_tag = "kochosei" },

	{ "CHARACTER" }
)
AddCharacterRecipe(
	"kocho_miku_back",
	{ Ingredient("petals", 1) },
	TECH.SCIENCE_ONE,
	{ builder_tag = "kochosei" },

	{ "CHARACTER" }
)

AddCharacterRecipe(
	"kochosei_apple",
	{ Ingredient("berries", 1), Ingredient("acorn", 1), Ingredient("spoiled_food", 1) },

	TECH.SCIENCE_ONE,
	{ builder_tag = "kochosei" },

	{ "CHARACTER" }
)

AddCharacterRecipe("kochosei_umbrella", { Ingredient("petals", 10), Ingredient("umbrella", 1) }, TECH.NONE, { builder_tag = "kochosei" }, { "CHARACTER" })

AddCharacterRecipe("kochosei_hatfl", {
	Ingredient("flowerhat", 1),
	Ingredient("moonglass", 25),
	Ingredient("hivehat", 1),
	Ingredient("purebrilliance", 4),
}, TECH.NONE, { builder_tag = "kochosei" }, { "CHARACTER" })

AddCharacterRecipe("kochosei_armor_1", {
	Ingredient("flowerhat", 1),
	Ingredient("moonglass", 20),
	Ingredient("thulecite", 1),
}, TECH.NONE, { builder_tag = "kochosei" }, { "CHARACTER" })

AddCharacterRecipe("lucky_hammer", { Ingredient("goldnugget", 50), Ingredient("log", 20), Ingredient("yellowgem", 5) }, TECH.NONE, { builder_tag = "kochosei" }, { "CHARACTER" })

AddCharacterRecipe(
	"kochosei_ancient_books",
	{ Ingredient("papyrus", 10), Ingredient("featherpencil", 2), Ingredient("thulecite", 4) },

	TECH.NONE,
	{

		builder_tag = "kochosei",
	},

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

-- Elysia Gift - decorative structure with light, warmth and sanity aura
AddRecipe2(
	"kochosei_elysia_gift",
	{ Ingredient("petals", 10), Ingredient("twigs", 2) },
	TECH.NONE,
	{ 
		placer = "kochosei_elysia_gift_placer", 
		min_spacing = 1,
		atlas = "images/inventoryimages/kochosei_elysia_gift_64.xml",
		image = "kochosei_elysia_gift_64.tex",
	},
	{ "KOCHOSEI_TAB" }
)
