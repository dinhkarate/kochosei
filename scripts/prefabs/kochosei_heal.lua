local Assets = {Asset("ANIM", "anim/kochosei_heal.zip")}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("heal_kochosei")
    inst.AnimState:SetBuild("heal_kochosei")
    inst.AnimState:PlayAnimation("heal_doc")
    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    inst.Transform:SetEightFaced()

    if not TheWorld.ismastersim then
        return inst
    end
    inst:ListenForEvent("animover", function()
        inst:Remove()
    end)

    return inst
end
local function fnitem()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("thiensu_xanh")
    inst.AnimState:SetBuild("thiensu_xanh")
    inst.AnimState:PlayAnimation("idle")
    MakeInventoryFloatable(inst, "med", 0.05, 0.65)
    MakeInventoryPhysics(inst)

    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
    inst:AddComponent("itemhealingkochosei")
    return inst
end
STRINGS.NAMES.KOCHOSEI_HEAL_ITEM = "Item Hồi Máu Ó"
STRINGS.RECIPE_DESC.KOCHOSEI_HEAL_ITEM = "Hồi máu cho đồng đội"

return Prefab("kochosei_heal", fn, Assets), Prefab("kochosei_heal_item", fnitem, Assets)
