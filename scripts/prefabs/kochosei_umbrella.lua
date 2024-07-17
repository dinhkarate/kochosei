local assets = {
    Asset("ANIM", "anim/kochosei_umbrella.zip"),
    Asset("ANIM", "anim/swap_kochosei_umbrella.zip"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_kochosei_umbrella", "swap_kochosei_umbrella")

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    -- owner.DynamicShadow:SetSize(2.2, 1.4)

    inst.components.fueled:StartConsuming()
		inst.magicfx = SpawnPrefab("cane_candy_fx")
	if inst.magicfx then
		inst.magicfx.entity:AddFollower()
		inst.magicfx.entity:SetParent(owner.entity)
		inst.magicfx.Follower:FollowSymbol(owner.GUID, "swap_object", 0, -350, 0)
	end
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    inst.components.fueled:StopConsuming()
	if inst.magicfx ~= nil then
		inst.magicfx:Remove()
		inst.magicfx = nil
	end
end

local function onequiptomodel(inst, owner, from_ground)
    if inst.components.fueled then
        inst.components.fueled:StopConsuming()
    end
end

local function onperish(inst)
    local equippable = inst.components.equippable
    if equippable ~= nil and equippable:IsEquipped() then
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        if owner ~= nil then
            local data = {
                prefab = inst.prefab,
                equipslot = equippable.equipslot,
            }
            inst:Remove()
            owner:PushEvent("umbrellaranout", data)
            return
        end
    end
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("kochosei_umbrella")
    inst.AnimState:SetBuild("kochosei_umbrella")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetScale(1.2, 1.2)

    inst:AddTag("nopunch")
    inst:AddTag("umbrella")

    --waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")

    MakeInventoryFloatable(inst, "large")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("tradable")

    inst:AddComponent("waterproofer")
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable.dapperness = 0.033

    inst:AddComponent("insulator")
    inst.components.insulator:SetSummer()

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:SetDepletedFn(onperish)
    inst.components.fueled:InitializeFuelLevel(TUNING.UMBRELLA_PERISHTIME * 2)

    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_ABSOLUTE)

    inst.components.insulator:SetInsulation(240)
    inst.components.insulator:SetSummer()

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    -- inst.components.floater:SetScale({1.0, 0.4, 1.0})
    --  inst.components.floater:SetBankSwapOnFloat(true, -40, {sym_build = "swap_kochosei_umbrella"})

    MakeHauntableLaunch(inst)

    return inst
end

STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_UMBRELLA = "Kochosei Umbrella"
STRINGS.RECIPE_DESC.KOCHOSEI_UMBRELLA = "Kochosei Umbrella"
STRINGS.NAMES.KOCHOSEI_UMBRELLA = "Kochosei Umbrella"

return Prefab("kochosei_umbrella", fn, assets)
