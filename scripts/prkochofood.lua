-- https://forums.kleientertainment.com/forums/topic/69732-dont-use-addingredientvalues-in-mods

local prkochofood = {
    kochofood_apple_cake = {
        test = function(cooker, names, tags)
            return tags.apple
                and tags.apple <= 2
                and tags.veggie
                and tags.veggie <= 1
                and tags.egg
                and tags.egg <= 1
                and not tags.monster
                and not tags.meat
                and not tags.fish
                and not tags.inedible
        end,

        priority = 666,
        foodtype = FOODTYPE.MEAT,
        health = 35,
        hunger = 50,
        perishtime = TUNING.PERISH_MED,
        sanity = 20,
        cooktime = 0.3,
        potlevel = "med",
    },

    kochofood_beefsteak = {
        test = function(cooker, names, tags)
            return tags.meat
                and tags.meat >= 2
                and tags.sweetener
                and tags.sweetener >= 2
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
        perishtime = TUNING.PERISH_MED,
        sanity = 15,
        cooktime = 1,
        potlevel = "low",
        temperature = TUNING.HOT_FOOD_BONUS_TEMP * 2,
        temperatureduration = TUNING.BUFF_FOOD_TEMP_DURATION,
    },

    kochofood_berry_cake = {
        test = function(cooker, names, tags)
            return (names.berries or names.berries_cooked or names.berries_juicy or names.berries_juicy_cooked or 0)
                >= 1
                and tags.egg
                and tags.egg <= 1
                and tags.sweetener
                and tags.sweetener <= 1
                and not tags.veggie
                and not tags.fish
                and not tags.fat
                and not tags.inedible
        end,

        priority = 666,
        foodtype = FOODTYPE.MEAT,
        health = 30,
        hunger = 90,
        perishtime = TUNING.PERISH_MED,
        sanity = 50,
        cooktime = 1,
        potlevel = "med",
    },
    kochofood_cheese_shrimp = {
        test = function(cooker, names, tags)
            return tags.tom and tags.tom >= 1 and tags.bo and tags.bo >= 1 and tags.onion and tags.onion >= 1
        end, -- phesp gan ba gia may

        priority = 666,
        foodtype = FOODTYPE.MEAT,
        health = 666,
        hunger = 666,
        perishtime = TUNING.PERISH_MED,
        sanity = 666,
        cooktime = 3,
        potlevel = "low",
        oneatenfn = function(inst, eater)
            if eater:HasTag("kochosei") and eater.components.timer then
                if eater.components.timer:TimerExists("kochobufffood") then
                    eater.components.timer:SetTimeLeft("kochobufffood", 120)
                end
                eater.components.timer:StartTimer("kochobufffood", 120)
                eater.AnimState:SetScale(2.5, 2.5)
                eater.components.health.externalabsorbmodifiers:SetModifier(eater, 0.35, "kocho_def_buff_food")
				eater.components.hunger:SetMax(666)
				eater.components.health:SetMaxHealth(666)
				eater.components.sanity:SetMax(666)
				eater:AddComponent("planarentity")
            end
        end,
    },
    kochofood_cheese_honey_cake = {
        test = function(cooker, names, tags)
            return tags.egg
                and tags.egg == 2
                and tags.sweetener
                and tags.sweetener == 2
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
        perishtime = TUNING.PERISH_MED,
        sanity = 20,
        cooktime = 0.7,
        potlevel = "med",
    },
    kochofood_fastfood = {
        test = function(cooker, names, tags)
            return tags.egg
                and tags.egg >= 2
                and tags.meat
                and tags.meat >= 1
                and tags.veggie
                and tags.veggie >= 1
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
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_MED,
        cooktime = 1,
        potlevel = "high",
    },
    kochofood_grape_juice = {
        test = function(cooker, names, tags)
            return tags.veggie
                and tags.veggie >= 1
                and tags.sweetener
                and tags.sweetener >= 1
                and (names.berries or names.berries_cooked or names.berries_juicy or names.berries_juicy_cooked or 0) >=
                1
                and tags.frozen
                and tags.frozen >= 1
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
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_MED * 5,
        cooktime = 0.5,
        potlevel = "med",
        temperature = TUNING.COLD_FOOD_BONUS_TEMP,
        temperatureduration = TUNING.BUFF_FOOD_TEMP_DURATION,
        oneatenfn = function(inst, eater)
            if eater.components.freezable ~= nil then
                eater.components.freezable:AddColdness(2)
            end
        end,
    },
    kochofood_kiwi_juice = {
        test = function(cooker, names, tags)
            return tags.frozen
                and tags.frozen >= 2
                and tags.sweetener
                and tags.sweetener >= 1
                and (names.berries or names.berries_cooked or names.berries_juicy or names.berries_juicy_cooked or 0) >=
                1
                and not tags.fat
                and not tags.dairy
                and not tags.inedible
                and not tags.meat
        end,

        priority = 666,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_LARGE,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_MED * 5,
        cooktime = 0.5,
        potlevel = "med",
        temperature = TUNING.COLD_FOOD_BONUS_TEMP,
        temperatureduration = TUNING.BUFF_FOOD_TEMP_DURATION,
        oneatenfn = function(inst, eater)
            if eater.components.freezable ~= nil then
                eater.components.freezable:AddColdness(2)
            end
        end,
    },
    kochofood_seafood_soup = {
        test = function(cooker, names, tags)
            return tags.tom
                and tags.tom >= 1
                and tags.veggie
                and tags.veggie >= 1.5
                and tags.fish
                and tags.fish >= 1
                and not tags.inedible
        end,

        priority = 30,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MED * 2,
        hunger = TUNING.CALORIES_LARGE * 2,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_MED * 2,
        cooktime = 1,
        potlevel = "med",
        temperature = TUNING.HOT_FOOD_BONUS_TEMP * 2,
        temperatureduration = TUNING.BUFF_FOOD_TEMP_DURATION,
    },
    kochofood_bunreal = {
        test = function(cooker, names, tags)
            return tags.veggie and tags.veggie >= 2 and tags.fish and tags.fish >= 1 and not tags.inedible
        end,

        priority = 30,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MED * 2,
        hunger = TUNING.CALORIES_LARGE * 3,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_MED * 3,
        cooktime = 1,
        potlevel = "low",
        temperature = TUNING.HOT_FOOD_BONUS_TEMP,
        temperatureduration = TUNING.BUFF_FOOD_TEMP_DURATION,
    },
    kochofood_banhmi_2 = {
        test = function(cooker, names, tags)
            return (names.tomato or names.tomato_cooked) and tags.egg and tags.meat
        end,

        priority = 30,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_LARGE * 2,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_MED * 2,
        cooktime = 1,
        potlevel = "med",
    },
    kochofood_cafe = {
        test = function(cooker, names, tags)
            return tags.frozen and tags.frozen >= 3 and tags.sweetener and not tags.meat and not tags.egg
        end,

        priority = 30,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_LARGE,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_MED * 5,
        cooktime = 1,
        potlevel = "med",
        temperature = -TUNING.HOT_FOOD_BONUS_TEMP,
        temperatureduration = TUNING.BUFF_FOOD_TEMP_DURATION,
        oneatenfn = function(inst, eater)
            if eater.components.freezable ~= nil then
                eater.components.freezable:AddColdness(2)
                eater:AddDebuff("sweettea_buff", "sweettea_buff")
            end
        end,
    },

    kochofood_xienthit = {
        test = function(cooker, names, tags)
            return names.twigs and tags.meat and tags.meat < 1
        end,

        priority = 666,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_LARGE,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_MED,
        cooktime = 1,
        potlevel = "med",
    },

    kochofood_apple_candy = {
        name = "kochofood_apple_candy",
        test = function(cooker, names, tags)
            return (names.kochosei_apple or names.kochosei_apple_cooked)
                and (names.twigs or 0) >= 1
                and (names.honey or 0) >= 1
                and tags.fruit
                and not tags.meat
                and not tags.egg
        end,
        priority = 666,
        weight = 1,
        foodtype = FOODTYPE.MEAT,
        health = -TUNING.HEALING_SMALL * 3,
        hunger = TUNING.CALORIES_SMALL * 2,
        perishtime = TUNING.PERISH_SLOW,
        sanity = TUNING.SANITY_MED * 4,
        cooktime = 1,
        potlevel = "med",
        floater = { "med", nil, 0.55 },
        tags = { "honeyed" },
    },
}

for k, v in pairs(prkochofood) do
    v.name = k
    v.weight = v.weight or 1
    v.priority = v.priority or 0

    v.cookbook_atlas = "images/cb_kochofood.xml"
    v.cookbook_tex = "cookbook_" .. k .. ".tex"
    v.cookbook_category = "cookpot"
    --AddCookerRecipe("cookpot", v)
end

return prkochofood
