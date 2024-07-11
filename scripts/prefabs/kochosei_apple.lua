local assets = {
    Asset("ANIM", "anim/kochosei_apple_fruit.zip"),
}

local prefabs = {
    "kochosei_apple",
    "kochosei_apple_cooked",
    "spoiled_food",
    "kochosei_apple_tree_sapling",
    "kochosei_apple_plantables",
}

local function Plant(inst, growtime)
    local sapling = SpawnPrefab("kochosei_apple_tree_sapling")
    sapling:StartGrowing()
    sapling.Transform:SetPosition(inst.Transform:GetWorldPosition())
    sapling.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
    inst:Remove()
end

local LEIF_TAGS = { "leif" }

local function OnDeploy(inst, pt, deployer)
    inst = inst.components.stackable:Get()
    inst.Transform:SetPosition(pt:Get())
    local timeToGrow =
        GetRandomWithVariance(TUNING.KOCHOSEI_APPLE_TREE_GROWTIME.base, TUNING.KOCHOSEI_APPLE_TREE_GROWTIME.random)
    Plant(inst, timeToGrow)
end

local function OnLoad(inst, data)
    if data and data.growtime then
        Plant(inst, data.growtime)
    end
end

local function commonfn(name, anim)
    local inst = CreateEntity()
    local abc = name
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeInventoryFloatable(inst, "small", 0.1, 1.12)

    MakeInventoryPhysics(inst)

    inst.Physics:SetFriction(1)
    inst.Physics:SetDamping(0)
    inst.Physics:SetRestitution(1)

    inst.AnimState:SetBank("kochosei_apple_fruit")
    inst.AnimState:SetBuild("kochosei_apple_fruit")
    inst.AnimState:PlayAnimation(anim)
    inst:AddTag("icebox_valid")
    inst:AddTag("show_spoilage")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("bait")

    inst:AddComponent("edible")
    ---NOTEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE -- Yeah that's is

    inst:AddComponent("inventoryitem")

    -- The inventory WHich I have already solve fucking things --

    inst:AddComponent("inspectable")

    inst:AddComponent("perishable")
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")

    MakeHauntableLaunchAndPerish(inst)

    return inst
end

local function kochosei_apple()
    local inst = commonfn("kochosei_apple", "idle")

    inst:AddTag("deployedplant")
    inst:AddTag("cookable")

    --	MakeInventoryFloatable(inst, "small", 0.2, {0.85, 0.6, 0.85})

    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("cookable")
    inst.components.cookable.product = "kochosei_apple_cooked"

    inst:AddComponent("deployable")
    inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
    --inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.LARGE) -- RANGE TREE AND TREE = 1 SQUARE
    inst.components.deployable.ondeploy = OnDeploy

    inst.components.edible.foodtype = FOODTYPE.VEGGIE
    inst.components.edible.hungervalue = 1
    inst.components.edible.healthvalue = 1

    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)

    inst.OnLoad = OnLoad

    return inst
end

local function kochosei_apple_cooked()
    local inst = commonfn("kochosei_apple_cooked", "cooked")

    --	MakeInventoryFloatable(inst, "small", 0.2, {0.85, 0.6, 0.85})

    if not TheWorld.ismastersim then
        return inst
    end
    inst.components.edible.foodtype = FOODTYPE.VEGGIE
    inst.components.edible.hungervalue = 3
    inst.components.edible.healthvalue = 3

    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

    return inst
end

STRINGS.NAMES.KOCHOSEI_APPLE = "Kochosei's Apple"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_APPLE = "An apple a day, keep doctor away"

STRINGS.NAMES.KOCHOSEI_APPLE_COOKED = "Kochosei's Cooked Apple"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_APPLE_COOKED = "Looks nice!"

return Prefab("kochosei_apple", kochosei_apple, assets, prefabs),
    Prefab("kochosei_apple_cooked", kochosei_apple_cooked, assets, prefabs),
    MakePlacer("kochosei_apple_placer", "kochosei_apple_fruit", "kochosei_apple_fruit", "idle_planted")
