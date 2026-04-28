local assets = {
    Asset("ANIM", "anim/kochosei_streetlight1_left.zip"),
    Asset("ANIM", "anim/kochosei_streetlight1_right.zip")
}

local SCALE = 1.25

-- Hàm Bật Đèn
local function TurnOn(inst)
    inst.on = true
    inst.Light:Enable(true)
    inst.AnimState:PlayAnimation("idle_on", true)
end

-- Hàm Tắt Đèn
local function TurnOff(inst)
    inst.on = false
    inst.Light:Enable(false)
    inst.AnimState:PlayAnimation("idle_off", true)
end

-- Luôn cho phép tương tác (vì không cần nhiên liệu)
local function CanInteract(inst)
    return true
end

-- Tự động bật/tắt theo buổi (Thêm WatchWorldState để đèn tự nhạy bén)
local function OnChange(inst)
    if TheWorld.state.isnight or TheWorld.state.isdusk then
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

-- Hàm khởi tạo chung
local function commonfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(3.7, 3)
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.Light:SetIntensity(0.9)
    inst.Light:SetColour(255 / 255, 200 / 255, 255 / 255)
    inst.Light:SetFalloff(0.6)
    inst.Light:SetRadius(6)
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

    -- Component Machine để bật tắt thủ công
    inst:AddComponent("machine")
    inst.components.machine.turnonfn = TurnOn
    inst.components.machine.turnofffn = TurnOff
    inst.components.machine.caninteractfn = CanInteract
    inst.components.machine.cooldowntime = 0

    -- Lắng nghe sự kiện thế giới
    inst:WatchWorldState("isnight", OnChange)
    inst:WatchWorldState("isdusk", OnChange)
    inst:ListenForEvent("onbuilt", OnChange)

    return inst
end

-- Định nghĩa đèn bên Phải
local function right()
    local inst = commonfn()
    inst.AnimState:SetBank("kochosei_streetlight1_right")
    inst.AnimState:SetBuild("kochosei_streetlight1_right")
    inst.AnimState:PlayAnimation("idle_off", true)
    return inst
end

-- Định nghĩa đèn bên Trái
local function left()
    local inst = commonfn()
    inst.AnimState:SetBank("kochosei_streetlight1_left")
    inst.AnimState:SetBuild("kochosei_streetlight1_left")
    inst.AnimState:PlayAnimation("idle_off", true)
    return inst
end

-- Strings
STRINGS.NAMES.KOCHOSEI_STREETLIGHT1_RIGHT = "Kochosei streetlight right"
STRINGS.RECIPE_DESC.KOCHOSEI_STREETLIGHT1_RIGHT = "A beautiful lantern to decorate"
STRINGS.NAMES.KOCHOSEI_STREETLIGHT1_LEFT = "Kochosei streetlight left"
STRINGS.RECIPE_DESC.KOCHOSEI_STREETLIGHT1_LEFT = "A beautiful lantern to decorate"

return Prefab("kochosei_streetlight1_left", left, assets),
    MakePlacer("kochosei_streetlight1_left_placer", "kochosei_streetlight1_left", "kochosei_streetlight1_left", "idle_on", nil, nil, nil, SCALE),
    Prefab("kochosei_streetlight1_right", right, assets),
    MakePlacer("kochosei_streetlight1_right_placer", "kochosei_streetlight1_right", "kochosei_streetlight1_right", "idle_on", nil, nil, nil, SCALE)