local assets = {
    Asset("ANIM", "anim/kochosei_armor_2.zip"),
    Asset("ANIM", "anim/kochosei_armor_1.zip")
}
local function OnEquip(inst, owner)
	owner.tangst = true

end

local function OnUnequip(inst, owner)
	owner.tangst = false
end

local function commonfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    inst.AnimState:PlayAnimation("anim")
    inst:AddTag("waterproofer")
    inst:AddTag("kochosei_hat")
    inst:AddTag("bramble_resistant")

    MakeInventoryFloatable(inst, "small", 0.1, 1.12)
    inst:AddTag("bramble_resistant")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddTag("bramble_resistant")
    inst:AddComponent("inspectable")

    inst:AddComponent("armor")

    inst.components.armor:InitIndestructible(TUNING.KOCHO_HAT1_ABSORPTION)
    inst.components.armor.condition = 100

    inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.dapperness = 0.15

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0.3)

    MakeHauntableLaunch(inst)

    return inst
end
local function kochosei_armor_1()
    local inst = commonfn()
    inst.AnimState:SetBank("kochosei_armor_1")
    inst.AnimState:SetBuild("kochosei_armor_1")
    return inst
end

if TUNING.KOCHOSEI_CHECKMOD ~= 1 and Kochoseiapi.MakeItemSkin ~= nil then
    Kochoseiapi.MakeItemSkin("kochosei_armor_1", "kochosei_armor_2", {
        name = "Áo giáp của lông xanh",
        atlas = "images/inventoryimages/kochosei_inv.xml",
        image = "kochosei_armor_2",
        build = "kochosei_armor_2",
        bank = "kochosei_armor_2",
        basebuild = "kochosei_armor_1",
        basebank = "kochosei_armor_1"
    })
end

STRINGS.NAMES.KOCHOSEI_ARMOR_1 = "Giáp của ai đó"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_ARMOR_1 = "10$ cho bộ giáp này, bạn nghĩ nó đắt hay rẻ?"
STRINGS.RECIPE_DESC.KOCHOSEI_ARMOR_1 = "Ai đó đã bỏ cả tháng lương của mình để thuê họa sĩ ngoài vẽ, chỉ vì con cò nào đó lười biếng"

return Prefab("kochosei_armor_1", kochosei_armor_1, assets)
