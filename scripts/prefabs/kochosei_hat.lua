local Assets = {Asset("ANIM", "anim/kochosei_hat1.zip"), Asset("ANIM", "anim/kochosei_hat2.zip"),
                Asset("ANIM", "anim/kochosei_hat3.zip"), Asset("ANIM", "anim/kochosei_hatfl.zip"),
                Asset("ANIM", "anim/ms_kochosei_hat2.zip"), Asset("ANIM", "anim/ms_kochosei_hat3.zip")}

local hats = {
    kochosei_hat1 = "kochosei_hat1",
    kochosei_hat2 = "kochosei_hat2",
    kochosei_hat3 = "kochosei_hat3",
    kochosei_hatfl = "kochosei_hatfl"
}

local function OnEquip(inst, owner)
    local hat = hats[inst.prefab]
    local skin_build = inst:GetSkinBuild()
    if hat then
        if skin_build ~= nil then
            owner.AnimState:OverrideItemSkinSymbol("swap_hat", skin_build, "swap_hat", inst.GUID, "swap_hat")
        else
            owner.AnimState:OverrideSymbol("swap_hat", hat, "swap_hat")
        end
    end
    if hat == "kochosei_hatfl" then
        if owner ~= nil and owner.components.sanity ~= nil then
            owner.components.sanity.neg_aura_absorb = TUNING.ARMOR_HIVEHAT_SANITY_ABSORPTION
            if owner.components.sanity.mode == SANITY_MODE_INSANITY then
                owner.components.sanity:EnableLunacy(true, "hatfl")
            end
        end
    end

    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
    end
end

local function OnUnequip(inst, owner)
    local hat = hats[inst.prefab]
    if hat == "kochosei_hatfl" then
        if owner ~= nil and owner.components.sanity ~= nil then
            owner.components.sanity.neg_aura_absorb = 0
            if owner.components.sanity.mode == SANITY_MODE_LUNACY then
                owner.components.sanity:EnableLunacy(false, "hatfl")
            end
        end
    end

    owner.AnimState:ClearOverrideSymbol("swap_hat")

    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
    end
end

local function MainFunction(bank, build, tag)

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)

    inst.AnimState:PlayAnimation("anim")
    inst:AddTag(tag)
    inst:AddTag("waterproofer")
    inst:AddTag("kochosei_hat")
    inst:AddTag("gestaltprotection")


    MakeInventoryFloatable(inst, "small", 0.1, 1.12)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddTag("bramble_resistant")
    inst:AddComponent("inspectable")

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.KOCHO_HAT1_DURABILITY + (TUNING.KOCHOSEI_CHECKWIFI * 2), TUNING.KOCHO_HAT1_ABSORPTION)

    inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.dapperness = (0.15)

    inst:AddComponent("waterproofer")
    -- Our hat shall grant 20% water resistance to the wearer!
    inst.components.waterproofer:SetEffectiveness(0.3)

    MakeHauntableLaunch(inst)

    return inst
end

STRINGS.NAMES.KOCHOSEI_HAT1 = "Kochosei Hat"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_HAT1 = "Its butterfly right? :>"
STRINGS.RECIPE_DESC.KOCHOSEI_HAT1 = "Armor hat"
STRINGS.NAMES.KOCHOSEI_HAT2 = "Kochosei Hat"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_HAT2 = "Its butterfly right? :>"
STRINGS.RECIPE_DESC.KOCHOSEI_HAT2 = "Armor hat"
STRINGS.NAMES.KOCHOSEI_HAT3 = "Kochosei Hat"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_HAT3 = "Its butterfly right? :>"
STRINGS.RECIPE_DESC.KOCHOSEI_HAT3 = "Armor hat"

STRINGS.NAMES.KOCHOSEI_HATFL = "Kochosei Hat"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_HATFL = "No more worrying about headaches, but something else is coming :>"
STRINGS.RECIPE_DESC.KOCHOSEI_HATFL = "No more worrying about headaches, but something else is coming :>"

return Prefab("common/inventory/kochosei_hat1", function()
    return MainFunction("kochosei_hat1", "kochosei_hat1", "kochosei_hat1")
end, Assets), Prefab("common/inventory/kochosei_hat2", function()
    return MainFunction("kochosei_hat2", "kochosei_hat2", "kochosei_hat2")
end, Assets), Prefab("common/inventory/kochosei_hat3", function()
    return MainFunction("kochosei_hat3", "kochosei_hat3", "kochosei_hat3")
end, Assets), Prefab("common/inventory/kochosei_hatfl", function()
    return MainFunction("kochosei_hatfl", "kochosei_hatfl", "kochosei_hatfl")
end, Assets)
