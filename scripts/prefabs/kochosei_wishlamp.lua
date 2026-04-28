local assets = {
    Asset("ANIM", "anim/kochosei_wishlamp.zip"),
    Asset("ANIM", "anim/kochosei_building_redlantern.zip"),
}

local SCALE = 1.25

-- Hàm Bật Đèn
local function TurnOn(inst)
    inst.on = true
    inst.Light:Enable(true)
    -- Đã bỏ dòng tiêu tốn nhiên liệu
    inst.AnimState:PlayAnimation("idle_on", true)
end

-- Hàm Tắt Đèn
local function TurnOff(inst)
    inst.on = false
    inst.Light:Enable(false)
    -- Đã bỏ dòng dừng tiêu tốn nhiên liệu
    inst.AnimState:PlayAnimation("idle_off", true)
end

-- Cho phép tương tác bất cứ lúc nào (vì không còn check nhiên liệu)
local function CanInteract(inst)
    return true
end

-- Tự động bật/tắt theo thời gian (ví dụ: tối tự bật)
local function OnChange(inst)
    if TheWorld.state.isnight then
        inst.components.machine:TurnOn()
    else
        inst.components.machine:TurnOff()
    end
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker) end

-- Hàm chính khởi tạo Entity
local function commonfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(3.7, 3)
    inst.entity:AddMiniMapEntity()

    inst.entity:AddNetwork()

    inst.entity:AddLight()
    inst.Light:SetIntensity(0.9)
    inst.Light:SetColour(255 / 255, 241 / 255, 141 / 255)
    inst.Light:SetFalloff(0.4)
    inst.Light:SetRadius(3)
    inst.Light:Enable(false)

    MakeObstaclePhysics(inst, 0.05)

    inst.Transform:SetScale(SCALE, SCALE, SCALE)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.on = false

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    -- Hệ thống máy móc để Bật/Tắt
    inst:AddComponent("machine")
    inst.components.machine.turnonfn = TurnOn
    inst.components.machine.turnofffn = TurnOff
    inst.components.machine.caninteractfn = CanInteract
    inst.components.machine.cooldowntime = 0

    -- Lắng nghe sự kiện chuyển buổi để tự động bật tắt
    inst:WatchWorldState("isnight", OnChange)
    inst:ListenForEvent("onbuilt", OnChange)

    return inst
end

-- Cột đèn Wishlamp
local function cottreolongden()
    local inst = commonfn()
    inst.AnimState:SetBank("kochosei_wishlamp")
    inst.AnimState:SetBuild("kochosei_wishlamp")
    inst.AnimState:PlayAnimation("idle_off", true)
    return inst
end

-- Cột đèn Red Lantern
local function cotden()
    local inst = commonfn()
    inst.AnimState:SetBank("kochosei_building_redlantern")
    inst.AnimState:SetBuild("kochosei_building_redlantern")
    inst.AnimState:PlayAnimation("idle_off", true)
    return inst
end

-- Strings & Prefabs
STRINGS.NAMES.KOCHOSEI_WISHLAMP = "Wish lamp"
STRINGS.RECIPE_DESC.KOCHOSEI_WISHLAMP = "A beautiful Japan lantern to decorate"
STRINGS.NAMES.KOCHOSEI_BUILDING_REDLANTERN = "Wish lamp"
STRINGS.RECIPE_DESC.KOCHOSEI_BUILDING_REDLANTERN = "A beautiful Japan lantern to decorate"

return Prefab("kochosei_wishlamp", cottreolongden, assets),
    Prefab("kochosei_building_redlantern", cotden, assets),
    MakePlacer("kochosei_wishlamp_placer", "kochosei_wishlamp", "kochosei_wishlamp", "idle_on", nil, nil, nil, SCALE),
    MakePlacer("kochosei_building_redlantern_placer", "kochosei_building_redlantern", "kochosei_building_redlantern", "idle_on", nil, nil, nil, SCALE)