local assets = {
    Asset("ANIM", "anim/lucky_hammer.zip"),
    Asset("ANIM", "anim/swap_lucky_hammer.zip")
}


local builds = {
    "kochosei_snowmiku_skin1",
    "kochosei",
    "kochosei_skin_shinku_full",
    "kochosei_skin_shinku_notfull"
}

local buildsmiohm = {
    "miohm", 
    "kochosei_purplebattleaxe",
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
        "orangegem",
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
        "rock_petrified_tree",
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
        "atrium_statue",
    },
    bee = {
        "beebox_hermit", 
        "beehive", 
        "wasphive", 
        "beebox", 
    },
    aohosongsuoi = {
        "lava_pond", 
        "pond", 
        "pond_mos", 
        "pond_cave", 
    },
    cocat = {
        "reeds", 
        "grass", 
        "sapling", 
        "sapling_moon", 
        "marsh_bush", 
    },
    berry = {
        "berrybush_juicy", 
        "berrybush", 
        "berrybush2", 
    },
    hat = {
        "kochosei_hat3", 
        "kochosei_hat1", 
        "kochosei_hat2", 
    },
    logg = {
        "driftwood_log", 
        "log", 
        "livinglog", 
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
        "garlic_seeds",
    },
    hoa = {
        "succulent_picked", 
        "petals", 
        "petals_evil", 
        "foliage", 
    },
    hoammatdat = {
        "petals_evil", 
        "petals", 
    },
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

local current_build_2 = 1

local function doiskin_2(inst)
    current_build_2 = (current_build_2 % 4) + 1
    inst.AnimState:SetBuild(builds[current_build_2])
end

local current_buildmiohm = 1

local function doiskinmiohm(inst)
    current_buildmiohm = (current_buildmiohm % 2) + 1
    inst.AnimState:SetBuild(buildsmiohm[current_buildmiohm])
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
            -- Tìm chủ sở hữu của đối tượng ban đầu và kiểm tra xem đối tượng có phải là vật phẩm trong túi đồ của chủ sở hữu không
            local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
            local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
            if holder ~= nil then
                -- Nếu đối tượng ban đầu là vật phẩm trong túi đồ, thì chuyển đối tượng thay thế vào vị trí của đối tượng ban đầu trong túi đồ
                local slot = holder:GetItemSlot(inst)
                inst:Remove()
                holder:GiveItem(replacementObj, slot)
            else
                -- Nếu đối tượng ban đầu không nằm trong túi đồ của bất kỳ ai, thì đặt đối tượng thay thế vào vị trí của đối tượng ban đầu trên đất
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
end



local function next_element_in_list(tbl, current)
    for i = 1, #tbl do
        if tbl[i] == current then
            return tbl[i % #tbl + 1]  -- Return the next element, or the first if current is the last element
        end
    end
end

local function UseStaff(inst, target)
    local caster = inst.components.inventoryitem.owner
    if target and (target == caster or target.prefab == "kochosei_enemy" or target.prefab == "kochosei_enemyb") then
        doiskin(target)
        --print(target.prefab.AnimState:GetBuild()) --hàm getbuild có tồn tại, có thể sử dụng để lưu current_build.
        hieuung(target)
    end
    if target == caster then
        doiskin_2(caster)
        hieuung(caster)
    end
--   if target and target.prefab == "miohm" then
--       doiskinmiohm(target)
--       hieuung(target)
--    end
--  Tính fix nhưng thôi, rắc rối vô hẳn soraapi + reskin_tool để nghiên cứu, lười

    for category, mapping in pairs(conversion_table) do
        for i, v in ipairs(mapping) do
            if v == target.prefab then
                local next_prefab = next_element_in_list(mapping, target.prefab)
                convert_rocks(target, next_prefab)
                if check_lucky then
                    inst.components.finiteuses:Use(1)
                end
                hieuung(target)
                return
            end
        end
    end
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
    inst.components.spellcaster:SetSpellFn(UseStaff)
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.quickcast = true
    inst.components.spellcaster.CanCast = CanCast
    if check_lucky then
        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(TUNING.KOCHO_LUCKYHAMMER_DURABILITY)
        inst.components.finiteuses:SetUses(TUNING.KOCHO_LUCKYHAMMER_DURABILITY)
        inst.components.finiteuses:SetOnFinished(inst.Remove)
    end
    return inst
end
STRINGS.NAMES.LUCKY_HAMMER = "Lucky Hammer"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.LUCKY_HAMMER = "I know what you want with this!! UwU"
STRINGS.RECIPE_DESC.LUCKY_HAMMER =
    "Change something to what you want from Ore, Tree, gem, mineral. Change free skin of clone and make you become a rich person!!"
return Prefab("lucky_hammer", fn, assets)
