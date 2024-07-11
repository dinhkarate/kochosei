local assets = {
    Asset("ANIM", "anim/kocho_lotus.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local function ondeploy(inst, pt, deployer)
    local plant = SpawnPrefab("kocho_lotus2")
    if plant ~= nil then
        plant.Transform:SetPosition(pt:Get())
        inst.components.stackable:Get():Remove()
        plant.components.pickable:MakeEmpty()
        if deployer ~= nil and deployer.SoundEmitter ~= nil then
            deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    MakeInventoryFloatable(inst, "small", 0.1, 1.12)
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("kocho_lotus")
    inst.AnimState:SetBuild("kocho_lotus")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFinalOffset(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM ---------------------
    inst:AddComponent("inventoryitem")

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.MEDIUM)
    inst.components.deployable:SetDeployMode(DEPLOYMODE.WATER)

    inst:AddComponent("inspectable")

    ---------------------
    MakeSmallBurnable(inst, TUNING.SMALL_FUEL)
    MakeSmallPropagator(inst)
    MakeHauntableIgnite(inst)
    ---------------------

    return inst
end
STRINGS.NAMES.KOCHO_LOTUS = "Hoa Sen"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHO_LOTUS = "Trong đầm gì đẹp bằng sen?"
STRINGS.RECIPE_DESC.KOCHO_LOTUS = "Trong đầm gì đẹp bằng sen?"

return Prefab("kocho_lotus", fn, assets),
    MakePlacer("kocho_lotus_placer", "kocho_lotus", "kocho_lotus", "idle_plant", nil, nil, nil, 1)
