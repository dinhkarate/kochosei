-- https://forums.kleientertainment.com/forums/topic/69732-dont-use-addingredientvalues-in-mods

----------------------------------------------------------------
-- Helpers
----------------------------------------------------------------
local function CountNames(names, ...)
    local total = 0
    for _, k in ipairs({...}) do
        total = total + (names[k] or 0)
    end
    return total
end

local function HasAny(names, ...)
    for _, k in ipairs({...}) do
        if names[k] then
            return true
        end
    end
    return false
end

----------------------------------------------------------------
-- Recipes
----------------------------------------------------------------
local prkochofood = {

    kochofood_apple_cake = {
        test = function(_, _, tags)
            return tags.apple and tags.apple <= 2
                and tags.veggie and tags.veggie <= 1
                and tags.egg and tags.egg <= 1
                and not tags.monster
                and not tags.meat
                and not tags.fish
                and not tags.inedible
        end,
        priority = 666,
        foodtype = FOODTYPE.MEAT,
        health = 35,
        hunger = 50,
        sanity = 20,
        perishtime = TUNING.PERISH_MED,
        cooktime = 0.3,
        potlevel = "med",
    },

    kochofood_beefsteak = {
        test = function(_, _, tags)
            return tags.meat and tags.meat >= 2
                and tags.sweetener and tags.sweetener >= 2
                and not tags.veggie
                and not tags.fish
                and not tags.egg
                and not tags.fat
                and not tags.dairy
                and not tags.inedible
        end,
        priority = 666,
        foodtype = FOODTYPE.MEAT,
        health = 50,
        hunger = 80,
        sanity = 15,
        perishtime = TUNING.PERISH_MED,
        cooktime = 1,
        potlevel = "low",
        temperature = TUNING.HOT_FOOD_BONUS_TEMP * 2,
        temperatureduration = TUNING.BUFF_FOOD_TEMP_DURATION,
    },

    kochofood_berry_cake = {
        test = function(_, names, tags)
            return CountNames(names,
                    "berries",
                    "berries_cooked",
                    "berries_juicy",
                    "berries_juicy_cooked") >= 1
                and tags.egg and tags.egg <= 1
                and tags.sweetener and tags.sweetener <= 1
                and not tags.veggie
                and not tags.fish
                and not tags.fat
                and not tags.inedible
        end,
        priority = 666,
        foodtype = FOODTYPE.MEAT,
        health = 30,
        hunger = 90,
        sanity = 50,
        perishtime = TUNING.PERISH_MED,
        cooktime = 1,
        potlevel = "med",
    },

    kochofood_cheese_shrimp = {
        test = function(_, _, tags)
            return tags.tom and tags.tom >= 1
                and tags.bo and tags.bo >= 1
                and tags.veggie and tags.veggie >= 1
        end,
        priority = 666,
        foodtype = FOODTYPE.MEAT,
        health = 666,
        hunger = 666,
        sanity = 666,
        perishtime = TUNING.PERISH_MED,
        cooktime = 3,
        potlevel = "low",
        oneatenfn = function(_, eater)
            if eater:HasTag("kochosei") then
                eater:AddDebuff("elysia_5_buff", "elysia_5_buff")
            end
        end,
    },

    kochofood_cheese_honey_cake = {
        test = function(_, _, tags)
            return tags.egg and tags.egg == 2
                and tags.sweetener and tags.sweetener == 2
                and not tags.veggie
                and not tags.meat
                and not tags.fish
                and not tags.fat
                and not tags.dairy
                and not tags.inedible
        end,
        priority = 666,
        foodtype = FOODTYPE.MEAT,
        health = 30,
        hunger = 35,
        sanity = 20,
        perishtime = TUNING.PERISH_MED,
        cooktime = 0.7,
        potlevel = "med",
    },

    kochofood_fastfood = {
        test = function(_, _, tags)
            return tags.egg and tags.egg >= 2
                and tags.meat and tags.meat >= 1
                and tags.veggie and tags.veggie >= 1
                and not tags.sweetener
                and not tags.fish
                and not tags.fat
                and not tags.dairy
                and not tags.inedible
        end,
        priority = 666,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_LARGE * 2,
        sanity = TUNING.SANITY_MED,
        perishtime = TUNING.PERISH_MED,
        cooktime = 1,
        potlevel = "high",
    },

    kochofood_grape_juice = {
        test = function(_, names, tags)
            return tags.veggie and tags.veggie >= 1
                and tags.sweetener and tags.sweetener >= 1
                and CountNames(names,
                    "berries",
                    "berries_cooked",
                    "berries_juicy",
                    "berries_juicy_cooked") >= 1
                and tags.frozen and tags.frozen >= 1
                and not tags.fish
                and not tags.fat
                and not tags.dairy
                and not tags.inedible
                and not tags.meat
        end,
        priority = 666,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_LARGE,
        sanity = TUNING.SANITY_MED * 5,
        perishtime = TUNING.PERISH_MED,
        cooktime = 0.5,
        potlevel = "med",
        temperature = TUNING.COLD_FOOD_BONUS_TEMP,
        temperatureduration = TUNING.BUFF_FOOD_TEMP_DURATION,
        oneatenfn = function(_, eater)
            if eater.components.freezable then
                eater.components.freezable:AddColdness(2)
            end
        end,
    },

    kochofood_kiwi_juice = {
        test = function(_, names, tags)
            return tags.frozen and tags.frozen >= 2
                and tags.sweetener and tags.sweetener >= 1
                and CountNames(names,
                    "berries",
                    "berries_cooked",
                    "berries_juicy",
                    "berries_juicy_cooked") >= 1
                and not tags.fat
                and not tags.dairy
                and not tags.inedible
                and not tags.meat
        end,
        priority = 666,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_LARGE,
        sanity = TUNING.SANITY_MED * 5,
        perishtime = TUNING.PERISH_MED,
        cooktime = 0.5,
        potlevel = "med",
        temperature = TUNING.COLD_FOOD_BONUS_TEMP,
        temperatureduration = TUNING.BUFF_FOOD_TEMP_DURATION,
    },

    kochofood_tyrant_juice = {
        test = function(_, names, tags)
            return CountNames(names,
                    "kochosei_apple",
                    "kochosei_apple_cooked") >= 1
                and (names.ice or 0) >= 3
                and not tags.meat
                and not tags.egg
                and not tags.inedible
        end,
        priority = 666,
        foodtype = FOODTYPE.MEAT,
        health = 40,
        hunger = 10,
        sanity = 40,
        perishtime = TUNING.PERISH_MED,
        cooktime = 0.5,
        potlevel = "med",
        temperature = TUNING.COLD_FOOD_BONUS_TEMP,
        temperatureduration = TUNING.BUFF_FOOD_TEMP_DURATION,
    },
}

----------------------------------------------------------------
-- Post process
----------------------------------------------------------------
for k, v in pairs(prkochofood) do
    v.name     = k
    v.weight   = v.weight   ~= nil and v.weight   or 1
    v.priority = v.priority ~= nil and v.priority or 0

    v.cookbook_atlas    = "images/cb_kochofood.xml"
    v.cookbook_tex      = "cookbook_" .. k .. ".tex"
    v.cookbook_category = "cookpot"
end

return prkochofood
-- Tât cả tại cò dinh không thiết kế theo chuẩn