require("prefabutil")

local assets = {
    Asset("ANIM", "anim/kochosei_elysia_gift.zip"),
}

local prefabs = {}

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:PushAnimation("idle", true)
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:PushAnimation("idle", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/packaged")
end

local function onburnt(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.5)

    inst:AddTag("structure")

    -- Animation setup
    inst.AnimState:SetBank("kochosei_elysia_gift_2")  -- Entity with idle animation from SCML
    inst.AnimState:SetBuild("kochosei_elysia_gift")
    inst.AnimState:PlayAnimation("idle", true)

    -- Light setup - soft warm glow
    inst.Light:Enable(true)
    inst.Light:SetRadius(4)
    inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(0.8)
    inst.Light:SetColour(255/255, 200/255, 150/255) -- Warm orange/yellow color
    local SCALE = 0.6
    inst.AnimState:SetScale(SCALE, SCALE, SCALE)

    -- Minimap icon
    inst.MiniMapEntity:SetIcon("kochosei_elysia_gift.tex")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    -- Heater component - warmth like campfire
    inst:AddComponent("heater")
    inst.components.heater.heat = 80
    inst.components.heater:SetThermics(true, false) -- heating enabled, cooling disabled

    -- Sanity aura +15
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = 15

    MakeSnowCovered(inst)
    inst:ListenForEvent("onbuilt", onbuilt)

    MakeSmallBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnBurntFn(onburnt)
    MakeSmallPropagator(inst)

    MakeHauntableWork(inst)

    return inst
end

STRINGS.NAMES.KOCHOSEI_ELYSIA_GIFT = "Elysia Gift"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_ELYSIA_GIFT = "A warm and comforting gift from Elysia"
STRINGS.RECIPE_DESC.KOCHOSEI_ELYSIA_GIFT = "Provides warmth, light, and peace of mind"

return Prefab("kochosei_elysia_gift", fn, assets, prefabs),
    MakePlacer("kochosei_elysia_gift_placer", "kochosei_elysia_gift_2", "kochosei_elysia_gift", "idle")
