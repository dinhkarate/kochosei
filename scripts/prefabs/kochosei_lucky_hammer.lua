local assets = {
    Asset("ANIM", "anim/lucky_hammer.zip"),
    Asset("ANIM", "anim/swap_lucky_hammer.zip"),
    Asset("ANIM", "anim/reskin_tool_fx.zip")
}

local builds = {
    "kochosei_snowmiku_skin1",
    "kochosei",
    "kochosei_skin_shinku_full",
    "kochosei_skin_shinku_notfull"
}


local conversion_table = {
    rocks = {
        "nitre",
        "goldnugget",
        "flint",
        "thulecite_pieces",
        "moonrocknugget",
        "moonglass",
        "rocks"
    },
    gems = {
        "redgem",
        "bluegem",
        "purplegem",
        "greengem",
        "orangegem"
    },
    tree = {
        "driftwood_tall",
        "evergreen",
        "evergreen_sparse",
        "deciduoustree",
        "twiggytree",
        "marsh_tree",
        "moon_tree",
        "kochosei_apple_tree",
        "mushtree_moon",
        "rock_petrified_tree"
    },
    other_rocks = {
        "rock1",
        "rock2",
        "rock_flintless",
        "rock_moon",
        "stalagmite_full",
        "stalagmite_tall_full",
        "wall_ruins",
        "ruins_statue_mage_nogem",
        "ruins_statue_head_nogem",
        "atrium_statue"
    },
    bee = {
        "beebox_hermit",
        "beehive",
        "wasphive",
        "beebox"
    },
    aohosongsuoi = {
        "lava_pond",
        "pond",
        "pond_mos",
        "pond_cave"
    },
    cocat = {
        "reeds",
        "grass",
        "sapling",
        "sapling_moon",
        "marsh_bush"
    },
    berry = {
        "berrybush_juicy",
        "berrybush",
        "berrybush2"
    },
    logg = {
        "driftwood_log",
        "log",
        "livinglog"
    },
    atvseeds = {
        "seeds",
        "carrot_seeds",
        "corn_seeds",
        "dragonfruit_seeds",
        "durian_seeds",
        "eggplant_seeds",
        "pomegranate_seeds",
        "pumpkin_seeds",
        "watermelon_seeds",
        "asparagus_seeds",
        "tomato_seeds",
        "potato_seeds",
        "onion_seeds",
        "pepper_seeds",
        "garlic_seeds"
    },
    hoa = {
        "succulent_picked",
        "petals",
        "petals_evil",
        "foliage"
    },
    hoammatdat = {
        "petals_evil",
        "petals"
    },
    traicay = {
        "farm_plant_carrot",
        "farm_plant_corn",
        "farm_plant_dragonfruit",
        "farm_plant_durian",
        "farm_plant_eggplant",
        "farm_plant_pomegranate",
        "farm_plant_pumpkin",
        "farm_plant_watermelon",
        "farm_plant_asparagus",
        "farm_plant_tomato",
        "farm_plant_potato",
        "farm_plant_onion",
        "farm_plant_pepper",
        "farm_plant_garlic"
    },
    -- Mặc đinh sẽ thay đổi về stage đầu tiên, t ko muốn làm nó rắc rối thêm ko cần thiết
    caykhonglo = {
        "carrot_oversized",
        "corn_oversized",
        "dragonfruit_oversized",
        "durian_oversized",
        "eggplant_oversized",
        "pomegranate_oversized",
        "pumpkin_oversized",
        "watermelon_oversized",
        "asparagus_oversized",
        "tomato_oversized",
        "potato_oversized",
        "onion_oversized",
        "pepper_oversized",
        "garlic_oversized"
    },

    caykhonglo_rotten = {
        "carrot_oversized_rotten",
        "corn_oversized_rotten",
        "dragonfruit_oversized_rotten",
        "durian_oversized_rotten",
        "eggplant_oversized_rotten",
        "pomegranate_oversized_rotten",
        "pumpkin_oversized_rotten",
        "watermelon_oversized_rotten",
        "asparagus_oversized_rotten",
        "tomato_oversized_rotten",
        "potato_oversized_rotten",
        "onion_oversized_rotten",
        "pepper_oversized_rotten",
        "garlic_oversized_rotten"
    },

    caykhonglo_waxed = {
        "carrot_oversized_waxed",
        "corn_oversized_waxed",
        "dragonfruit_oversized_waxed",
        "durian_oversized_waxed",
        "eggplant_oversized_waxed",
        "pomegranate_oversized_waxed",
        "pumpkin_oversized_waxed",
        "watermelon_oversized_waxed",
        "asparagus_oversized_waxed",
        "tomato_oversized_waxed",
        "potato_oversized_waxed",
        "onion_oversized_waxed",
        "pepper_oversized_waxed",
        "garlic_oversized_waxed"
    },
    hoaqua_traicay = {
        "carrot",
        "corn",
        "dragonfruit",
        "durian",
        "eggplant",
        "pomegranate",
        "pumpkin",
        "watermelon",
        "asparagus",
        "tomato",
        "potato",
        "onion",
        "pepper",
        "garlic"
    }
}

local check_lucky = false
if type(TUNING.KOCHO_LUCKYHAMMER_DURABILITY) == "number" then
    check_lucky = true
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_lucky_hammer", "swap_lucky_hammer")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function hieuung(inst)
    local fx_prefab = "explode_reskin"
    local fx = SpawnPrefab(fx_prefab)
    local x, y, z = inst.Transform:GetWorldPosition()
    fx.Transform:SetPosition(x, y, z)
end

local current_build = 1

local function doiskin(inst)
    current_build = (current_build % 4) + 1
    inst.AnimState:SetBuild(builds[current_build])
end

local function convert_rocks(inst, replacement)
    -- Kiểm tra đối tượng đang tồn tại và tên đối tượng thay thế đã được xác định
    if inst:IsValid() and replacement ~= nil then
        -- Tạo đối tượng thay thế và đặt số lượng của đối tượng ban đầu (nếu có)
        local replacementObj = SpawnPrefab(replacement)
        if replacementObj ~= nil then
            if replacementObj.components.stackable ~= nil and inst.components.stackable ~= nil then
                replacementObj.components.stackable:SetStackSize(inst.components.stackable.stacksize)
            end
            local x, y, z = inst.Transform:GetWorldPosition()
            inst:Remove()
            replacementObj.Transform:SetPosition(x, y, z)
            if replacementObj ~= nil and replacementObj.prefab == "wall_ruins" then
                if replacementObj.components.health ~= nil then
                    replacementObj.components.health:DoDelta(999)
                end
            end
        end
    end
end

local function next_element_in_list(tbl, current)
    for i = 1, #tbl do
        if tbl[i] == current then
            return tbl[i % #tbl + 1] -- Return the next element, or the first if current is the last element
        end
    end
end

local function can_cast_fn(doer, target, pos)
    local prefab_to_skin = target.prefab
    if PREFAB_SKINS[prefab_to_skin] ~= nil then
        for _, item_type in pairs(PREFAB_SKINS[prefab_to_skin]) do
            if TheInventory:CheckClientOwnership(doer.userid, item_type) then
                return true
            end
        end
    end

    -- Kiểm tra xem có nằm trong conversion_table không?
    for category, mapping in pairs(conversion_table) do
        for i, v in ipairs(mapping) do
            if v == target.prefab then
                return true
            end
        end
    end

    return false
end

local function spellCB(tool, target, pos, caster)
    -- target = target or caster --if no target, then self target for beards no beards. Beards cút
    if target == nil then -- Bail.
        return
    end
    hieuung(target)

    if target and (target == caster or target.prefab == "kochosei_enemy" or target.prefab == "kochosei_enemyb") then
        doiskin(target)
        -- print(target.prefab.AnimState:GetBuild()) --hàm getbuild có tồn tại, có thể sử dụng để lưu current_build.
    end

    for category, mapping in pairs(conversion_table) do
        for i, v in ipairs(mapping) do
            if v == target.prefab then
                local next_prefab = next_element_in_list(mapping, target.prefab)
                convert_rocks(target, next_prefab)
                if check_lucky then
                    tool.components.finiteuses:Use(1)
                end
                return
            end
        end
    end

    tool:DoTaskInTime(0, function()

        local prefab_to_skin = target.prefab

        if target:IsValid() and tool:IsValid() and tool.parent and tool.parent:IsValid() then
            local curr_skin = target.skinname
            local userid = tool.parent.userid or ""
            local cached_skin = tool._cached_reskinname[prefab_to_skin]
            local search_for_skin = cached_skin ~= nil -- also check if it's owned
            if curr_skin == cached_skin or (search_for_skin and not TheInventory:CheckClientOwnership(userid, cached_skin)) then
                local new_reskinname = nil

                if PREFAB_SKINS[prefab_to_skin] ~= nil then
                    for _, item_type in pairs(PREFAB_SKINS[prefab_to_skin]) do
                        if search_for_skin then
                            if cached_skin == item_type then
                                search_for_skin = false
                            end
                        else
                            if TheInventory:CheckClientOwnership(userid, item_type) then
                                new_reskinname = item_type
                                break
                            end
                        end
                    end
                end
                tool._cached_reskinname[prefab_to_skin] = new_reskinname
                cached_skin = new_reskinname
            end

            TheSim:ReskinEntity(target.GUID, target.skinname, cached_skin, nil, userid)

        end
    end)
end

local function CanCast(doer, target, pos)
    return true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small", 0.1, 1.12)

    inst.AnimState:SetBank("lucky_hammer")
    inst.AnimState:SetBuild("lucky_hammer")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("staff")
    inst.entity:AddNetwork()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(10)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(spellCB)
    inst.components.spellcaster:SetCanCastFn(can_cast_fn)
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.quickcast = true
    --	inst.components.spellcaster.CanCast = CanCast
    --  Bỏ commonent CanCast để có thể dùng cho một số đối tượng giới hạn
    if check_lucky then
        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(TUNING.KOCHO_LUCKYHAMMER_DURABILITY)
        inst.components.finiteuses:SetUses(TUNING.KOCHO_LUCKYHAMMER_DURABILITY)
        inst.components.finiteuses:SetOnFinished(inst.Remove)
    end

    inst._cached_reskinname = {}
    return inst
end
STRINGS.NAMES.LUCKY_HAMMER = "Lucky Hammer"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.LUCKY_HAMMER = "I know what you want with this!! UwU"
STRINGS.RECIPE_DESC.LUCKY_HAMMER = "Change something to what you want from Ore, Tree, gem, mineral. Change free skin of clone and make you become a rich person!!"
return Prefab("lucky_hammer", fn, assets)
