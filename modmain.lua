local _G = GLOBAL
_G.Kochoseiapi = env
local TUNING = _G.TUNING
local require = _G.require
local cooking = require("cooking")
local ingredients = cooking.ingredients
local cookpot = { "cookpot", }
local spicer = { "portablespicer", }
local STRINGS = _G.STRINGS
local listmodneedcheck = {
    "2578692071",
    "1638724235",
    "1645013096",
    "2066838067",
    "2736985627",
    "2477561322",
    "2958351483",
    "2526778484",
}
TUNING.KOCHOSEI_CHECKWIFI_CONFIG = GetModConfigData("kochosei_va_waifu") -- Này là wifi
TUNING.KOCHOSEI_CHECKMOD = nil
TUNING.KOCHOSEI_CHECKWIFI = 0                                            -- Wifi mà, không phải waifu, nó là 0 vì nó nên như thế )
                                                                         -- ?

local modsToLoad = _G.KnownModIndex:GetModsToLoad()
for _, v in ipairs(modsToLoad) do
    local Mod = _G.KnownModIndex:GetModInfo(v)
    if v == "workshop-2812783478" or Mod.name:find("%[API%] Modded Skins") then
        TUNING.KOCHOSEI_CHECKMOD = 1
        print("Mod found:", v, Mod.name)
        break
    end
end

if TUNING.KOCHOSEI_CHECKWIFI_CONFIG == 1 then
    for _, v in ipairs(listmodneedcheck) do
        for _, listmod in ipairs(modsToLoad) do
            if listmod == "workshop-" .. v then
                TUNING.KOCHOSEI_CHECKWIFI = TUNING.KOCHOSEI_CHECKWIFI + 50
                break
            end
        end
    end
end

--[[ Không dùng nữa
local PREFAB_SKINS = _G.PREFAB_SKINS
local PREFAB_SKINS_IDS = _G.PREFAB_SKINS_IDS
local SKIN_AFFINITY_INFO = _G.require("skin_affinity_info")
	Không dùng nữa
--]]
-------------------Assets--------------
modimport("scripts/kochoas")

-------------------Assets--------------
local kochofood = {
    "kochofood_apple_cake",
    "kochofood_cheese_shrimp",
    "kochofood_beefsteak",
    "kochofood_grape_juice",
    "kochofood_fastfood",
    "kochofood_cheese_honey_cake",
    "kochofood_apple_candy",
    "kochofood_kiwi_juice",
    "kochofood_xienthit",
    "kochofood_seafood_soup",
    "kochofood_berry_cake",
    "kochofood_cafe",
    "kochofood_bunreal",
    "kochofood_banhmi_2",
}

local listiteminv = {
    "miohm",
    "kocho_lotus_flower",
    "kocho_lotus",
    "kocho_lotus_flower_cooked",
    "kochosei_purplemagic",
    "miku_usagi_backpack",
    "kocho_purplesword",
    "kocho_miku_cos",
    "kocho_miku_back",
    "kochosei_umbrella",
    "kochosei_demonlord",
    "kochosei_hat1",
    "kochosei_hat2",
    "kochosei_hat3",
    "ms_kochosei_hat2",
    "ms_kochosei_hat3",
    "kochotambourin",
    "kochosei_lantern",
    "kochosei_apple",
    "kochosei_apple_cooked",
    "kochobook",
    "kochosei_hatfl",
    "lucky_hammer",
    "kochosei_ancient_books",
    "kochosei_christmast_torch1",
}
-- Icon item ở đây không cần làm từng cái ở mỗi prefab nữa --
for _, prefab in ipairs(kochofood) do
    local atlas = "images/inventoryimages/kochofood.xml"
    local tex = prefab .. ".tex"
    RegisterInventoryItemAtlas(_G.resolvefilepath(atlas), tex)
end
for _, prefab in ipairs(listiteminv) do
    local atlas = "images/inventoryimages/kochosei_inv.xml"
    local tex = prefab .. ".tex"
    RegisterInventoryItemAtlas(_G.resolvefilepath(atlas), tex)
end

PrefabFiles = {
    "kochosei_apple_tree",
    "kochosei_apple_planted_tree",
    "kochosei_apple",
    "kochosei_apple_plantables",
    "kochosei",
    "kochosei_none",
    "kochosei_miohm",
    "kochosei_bearger",
    "kochosei_kochotambourin",
    "kochosei_hat",
    "kochosei_lantern",
    "kochosei_streetlight",
    "kochosei_streetlight1_musicbox",
    "kochosei_enemy",
    "kochosei_enemyb",
    "kochosei_lavaarena_blooms_kocho",
    "kochosei_house",
    "kochosei_purplemagic",
    "kochosei_magicbubble",
    "kochosei_miku_usagi_backpack",
    "kochosei_purplesword",
    "kochosei_lotus_flower",
    "kochosei_lotus",
    "kochosei_lotus2",
    "kochosei_decor",
    "kochosei_food",
    "kochosei_stalk",
    "kochosei_wishlamp",
    "kochosei_torigate",
    "kochosei_dragonfly",
    "kochosei_deerclops",
    "kochosei_umbrella",
    "kochosei_demonlord",
    "kochosei_lucky_hammer",
    "kochosei_ancient_books",
    "kochosei_bienbao", -- "kochosei_enemy_d" Mio k cho dung nua
    "kochosei_christmast_torch1",
	"kochosei_moonstorm_ground_lightning_fx",
}

local skin_modes = {
    {
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle",
        scale = 0.75,
        offset = {
            0,
            -25,
        },
    },
}

AddModCharacter("kochosei", "FEMALE", skin_modes)

keytonamngua = GetModConfigData("keykocho")

local function namngua(inst)
    if inst.prefab ~= "kochosei" then
        return
    end

    if inst.sg:HasStateTag("knockout") then
        inst.sg.statemem.cometo = nil
    elseif
        not (
            inst.sg:HasStateTag("sleeping")
            or inst.sg:HasStateTag("bedroll")
            or inst.sg:HasStateTag("tent")
            or inst.sg:HasStateTag("waking")
            or inst.sg:HasStateTag("drowning")
        )
    then
        if inst.sg:HasStateTag("jumping") then
            inst.sg.statemem.queued_post_land_state = "knockout"
        else
            inst:PushEvent("yawn", {
                grogginess = 4,
                knockoutduration = 99999999999,
            })
        end
    end

    if inst.sg:HasStateTag("sleeping") then
        if inst.sleepingbag ~= nil then
            inst.sleepingbag.components.sleepingbag:DoWakeUp()
            inst.sleepingbag = nil
        else
            inst.sg.statemem.iswaking = true
            inst.sg:GoToState("wakeup")
        end
    end
end

AddModRPCHandler("namnguaRPC", "namngua", namngua)

local function SendnamnguaRPC()
    SendModRPCToServer(GetModRPC("namnguaRPC", "namngua"), inst)
end
_G.TheInput:AddKeyDownHandler(keytonamngua, SendnamnguaRPC) -- Không rõ là cái gì nữa

modimport("scripts/value_dhkg_a")                           -- TUNING

modimport("scripts/widgets/balovali")                       -- balovali

_G.kochosei_hat1_init_fn = function(inst, build_name)
    _G.basic_init_fn(inst, build_name, "kochosei_hat1")
end

_G.kochosei_hat1_clear_fn = function(inst)
    _G.basic_clear_fn(inst, "kochosei_hat1")
end

--[[
if TUNING.KOCHOSEI_CHECKMOD ~= 1 then

    modimport("scripts/skins_api")

    SKIN_AFFINITY_INFO.kochosei = {
        "kochosei_snowmiku_skin1" -- Hornet: These skins will show up for the character when the Survivor filter is enabled
    }

    PREFAB_SKINS["kochosei"] = {"kochosei_none", "kochosei_snowmiku_skin1"}

    PREFAB_SKINS_IDS = {} -- Make sure this is after you  change the PREFAB_SKINS["character"] table
    for prefab, skins in pairs(PREFAB_SKINS) do
        PREFAB_SKINS_IDS[prefab] = {}
        for k, v in pairs(skins) do PREFAB_SKINS_IDS[prefab][v] = k end
    end

    AddSkinnableCharacter("kochosei") -- Hornet: The character youd like to skin, make sure you use the prefab name. And MAKE sure you run this function AFTER you import the skins_api file
    --------------------------------------------
end
--]]
modimport("scripts/vukhi")

if TUNING.KOCHOSEI_CHECKMOD ~= 1 then
    modimport("scripts/api_skins_soraaaaa") -- Không thấy modded nên dùng api đáng lẽ api cũ cơ
end

---- Tùy chỉnh item cho phép give clone ----

AddPrefabPostInitAny(function(inst)
    if not _G.TheWorld.ismastersim then
        return inst
    end
    if
        (inst.components.equippable and inst.components.inventoryitem)
        or inst.components.armor
        or inst.components.weapon
        or inst.prefab == "dragon_scales"
        or inst.prefab == "deerclops_eyeball"
        or inst.prefab == "bearger_fur"
        or inst:HasTag("light") and not inst.components.tradeable
    then
        if not inst.components.tradeable then
            inst:AddComponent("tradable")
        end
    end
end)

AddComponentPostInit("skinner",function(self)
	function self:Kochosei_GetSkinName()
		return self.skin_name
	end
end)

--- Cái này là buff đọc từ sách cổ đại ---
local function kochospeed(inst, data)
    if data.name == "kochobuffspeed_time" then
        inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "kochosei_speed_mod")
    end
end
local function bufffood(inst, data)
    if data.name == "kochobufffood" then
        inst.AnimState:SetScale(1, 1)
		inst.components.health:SetMaxHealth(TUNING.KOCHOSEI_HEALTH)
		inst.components.hunger:SetMax(TUNING.KOCHOSEI_HUNGER)
		inst.components.sanity:SetMax(TUNING.KOCHOSEI_SANITY)
        inst.components.health.externalabsorbmodifiers:RemoveModifier(inst, "kocho_def_buff_food")
		if inst.components.planarentity then
			inst:RemoveComponent("planarentity")
		end
    end
end


AddPrefabPostInit("kochosei", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    if not inst.components.timer then
        inst:AddComponent("timer")
    end
    inst:ListenForEvent("timerdone", kochospeed)
    inst:ListenForEvent("timerdone", bufffood)
end)

--- Hồi sinh từ bướm ---
local function CustomOnHauntkochosei(inst, haunter)
    if haunter and haunter.prefab == "kochosei" then
        if inst.components.health then
            inst.components.health:Kill()
        end -- Tôi năm nay 80 tuổi nhưng chưa thấy ai độc ác như này, hồi sinh bằng bứm ạ
        haunter:PushEvent("respawnfromghost", {
            source = inst,
        })
    end
end

AddPrefabPostInit("butterfly", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    AddHauntableCustomReaction(inst, CustomOnHauntkochosei, true, false, true)
end)

-- Boss Drop nơ siêu cấp--

AddPrefabPostInit("alterguardian_phase3", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    inst.components.lootdropper:AddChanceLoot("kochosei_hatfl", 1)
end)

--[[
AddGamePostInit(function()
    local addhat = GLOBAL.LootTables.alterguardian_phase3
    table.insert(addhat, {"kochosei_hatfl", 1.0})

end)
-]]
-- Boss Drop nơ siêu cấp--
--------Wick đó----------

AddPrefabPostInit("kochosei", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    if TUNING.KOCHOSEI_WICK2 ~= 0 then
        inst:AddTag("bookbuilder")
        if inst.components.builder ~= nil then
            inst.components.builder:UnlockRecipe("book_silviculture")
            inst.components.builder:UnlockRecipe("book_tentacles")
        end
    end
end)

AddPrefabPostInit("kochosei_hatfl", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("planardefense")
    inst.components.planardefense:SetBaseDefense(TUNING.ARMOR_LUNARPLANT_PLANAR_DEF)
end)


--------Wick đó----------

-- NOTE: If the thing already had a tag with the same name, you will still overwrite the old value, unless keepoldvalues is true. E.g if fish already had a tag seafood with value 0.5 and now you use this function with value 1, the result will be 1.
function InsertIngredientValues(names, tags, cancook, candry, keepoldvalues) -- if cancook or candry is true, the cooked/dried variant of the thing will also get the tags and the tags precook/dried.
    for _, name in pairs(names) do
        if ingredients[name] == nil then                                     -- if it is not cookable already, it will be nil. Following code is just a copy of the normal AddIngredientValues function
            ingredients[name] = {
                tags = {},
            }

            if cancook then
                ingredients[name .. "_cooked"] = {
                    tags = {},
                }
            end

            if candry then
                ingredients[name .. "_dried"] = {
                    tags = {},
                }
            end

            for tagname, tagval in pairs(tags) do
                ingredients[name].tags[tagname] = tagval
                -- print(name,tagname,tagval,ingtable[name].tags[tagname])

                if cancook then
                    ingredients[name .. "_cooked"].tags.precook = 1
                    ingredients[name .. "_cooked"].tags[tagname] = tagval
                end
                if candry then
                    ingredients[name .. "_dried"].tags.dried = 1
                    ingredients[name .. "_dried"].tags[tagname] = tagval
                end
            end
        else                                                            -- but if there are already some tags, don't delete previous tags, just add the new ones.
            for tagname, tagval in pairs(tags) do
                if ingredients[name].tags[tagname] == nil or not keepoldvalues then -- only overwrite old value, if there is no old value, or if keepoldvalues is not true (will be not true by default)
                    ingredients[name].tags[tagname] = tagval            -- this will overwrite the old value, if there was one
                end
                -- print(name,tagname,tagval,ingtable[name].tags[tagname])

                if cancook then
                    if ingredients[name .. "_cooked"] == nil then
                        ingredients[name .. "_cooked"] = {
                            tags = {},
                        }
                    end
                    if ingredients[name .. "_cooked"].tags.precook == nil or not keepoldvalues then
                        ingredients[name .. "_cooked"].tags.precook = 1
                    end
                    if ingredients[name .. "_cooked"].tags[tagname] == nil or not keepoldvalues then
                        ingredients[name .. "_cooked"].tags[tagname] = tagval
                    end
                end
                if candry then
                    if ingredients[name .. "_dried"] == nil then
                        ingredients[name .. "_dried"] = {
                            tags = {},
                        }
                    end
                    if ingredients[name .. "_dried"].tags.dried == nil or not keepoldvalues then
                        ingredients[name .. "_dried"].tags.dried = 1
                    end
                    if ingredients[name .. "_dried"].tags[tagname] == nil or not keepoldvalues then
                        ingredients[name .. "_dried"].tags[tagname] = tagval
                    end
                end
            end
        end
    end
end

-- Thêm giá trị cho các món---
InsertIngredientValues({
    "foliage",
}, {
    veggie = 0.5,
    rau = 1,
})
InsertIngredientValues({
    "kocho_lotus_flower_cooked",
}, {
    veggie = 0.5,
    rau = 1,
})
InsertIngredientValues({
    "kocho_lotus_flower",
}, {
    veggie = 0.5,
    rau = 1,
})
InsertIngredientValues({
    "kochosei_apple_cooked",
}, {
    fruit = 1,
    apple = 1,
})
InsertIngredientValues({
    "kochosei_apple",
}, {
    fruit = 1,
    apple = 1,
})
InsertIngredientValues({
    "wobster_sheller_land",
}, {
    tom = 1,
})
InsertIngredientValues({
    "onion",
}, {
    onion = 1,
})
InsertIngredientValues({
    "goatmilk",
}, {
    bo = 1,
})
InsertIngredientValues({
    "butter",
}, {
    bo = 1,
})
-----------------------------------------------------------------------------------------------

for _, v in pairs(cookpot) do
    for _, recipe in pairs(require("prkochofood")) do
        AddCookerRecipe(v, recipe)
    end
end
for _, v in pairs(spicer) do
    for _, recipe in pairs(require("kocho_spicedfoods")) do
        AddCookerRecipe(v, recipe)
    end
end

-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
STRINGS.NAMES.KOCHOFOOD_APPLE_CAKE = "Apple Cake"
STRINGS.NAMES.KOCHOFOOD_BEEFSTEAK = "Beefsteak"
STRINGS.NAMES.KOCHOFOOD_BERRY_CAKE = "Berry Cake"
STRINGS.NAMES.KOCHOFOOD_CHEESE_SHRIMP = "Cheese Shrimp"
STRINGS.NAMES.KOCHOFOOD_CHEESE_HONEY_CAKE = "Cheese Honey Cake"
STRINGS.NAMES.KOCHOFOOD_FASTFOOD = "Fastfood"
STRINGS.NAMES.KOCHOFOOD_GRAPE_JUICE = "Grape Juice"
STRINGS.NAMES.KOCHOFOOD_KIWI_JUICE = "Kiwi Juice"
STRINGS.NAMES.KOCHOFOOD_SEAFOOD_SOUP = "Súp"
STRINGS.NAMES.KOCHOFOOD_XIENTHIT = "Xiên Thịt"
STRINGS.NAMES.KOCHOFOOD_APPLE_CANDY = "Apple Candy"
STRINGS.NAMES.KOCHOFOOD_BUNREAL = "Bún Real"
STRINGS.NAMES.KOCHOFOOD_BANHMI_2 = "Bánh Mì"
STRINGS.NAMES.KOCHOFOOD_CAFE = "Cà Phê Sữa Đá"
STRINGS.SKIN_NAMES.kochosei_hat2 = "Kochosei Hat 2"
STRINGS.SKIN_NAMES.kochosei_hat3 = "Kochosei Hat 3"
--------------------------------------
STRINGS.NAMES.LYDOCHET = "Cast Revive Kochotambourin"
STRINGS.NAMES.LYDOHOISINH = "Kochotambourin"
STRINGS.NAMES.CHETBOICLONE = "Kochosei Enemy"

STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_ENEMY_D = "may cut khoi dia ban cua tao - Dinh bảo thế"

STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_ENEMY_C = "may cut khoi dia ban cua tao - Dinh bảo thế"
---------------------------------------

-- The character select screen lines
STRINGS.CHARACTER_TITLES.kochosei = "Kochou no Sei"
STRINGS.CHARACTER_NAMES.kochosei = "Kochousei"
STRINGS.CHARACTER_DESCRIPTIONS.kochosei =
"*Love Singing & friendly\n*Regen sanity + health herself and friends around after full sanity when she is singing\n*The plant on the field will be happy if she is singing near them"
STRINGS.CHARACTER_QUOTES.kochosei = "<3 Hora hora"
STRINGS.CHARACTER_SURVIVABILITY.kochosei = "CUTEEE!"

-- Custom speech strings
STRINGS.CHARACTERS.KOCHOSEI = require("speech_kochosei")

-- The character's name as appears in-game
STRINGS.NAMES.KOCHOSEI = "Kochousei"
STRINGS.SKIN_NAMES.kochosei_none = "Kochousei"

STRINGS.SKIN_NAMES.kochosei_none = "Kochosei"
STRINGS.SKIN_NAMES.kochosei_snowmiku_skin1 = "Kochosei cosplay Miku"

STRINGS.SKIN_QUOTES.kochosei_snowmiku_skin1 =
"Ai đó đã phải làm việc như trâu để có skin này. Congratulation"
STRINGS.SKIN_DESCRIPTIONS.kochosei_snowmiku_skin1 = "o((>ω< ))o"
-----------------------------------------------------------------------------------------------
--[[local oldHAUNTT = ACTIONS.HAUNT.fn
ACTIONS.HAUNT.fn = function(act)
	if act.doer ~= nil and act.doer:HasTag("kochosei") and act.doer:HasTag("playerghost")
	and act.inst ~= nil and act.inst.components.health and not act.inst:HasTag("structure") then
		act.inst.components.health:Kill()
		act.doer:PushEvent("respawnfromghost", { source = act.inst, user = act.inst })
		return true
	else
		return oldHAUNTT(act)
	end
end


AddComponentPostInit("fishingrod", function(self)
	function self:GetWaitTimes()
		return self.minwaittime, self.maxwaittime
	end
end)


AddStategraphState("wilson",GLOBAL.State{
	name = "tillconcomio",
	onenter = function(inst)
		inst.sg:GoToState("till", 0.2) --'2 seconds, but you can change this into whatever you want'
	end,
})

----lam chua xong 

AddStategraphActionHandler("wilson",GLOBAL.ActionHandler(GLOBAL.ACTIONS.TILL,function(inst)
            return inst:HasTag("kochosei") and "tillconcomio" or  "till_start"   end))
AddStategraphActionHandler("wilson_client",GLOBAL.ActionHandler(GLOBAL.ACTIONS.TILL,function(inst)
            return inst:HasTag("kochosei") and "tillconcomio" or  "till_start"   end))
				
--]]			