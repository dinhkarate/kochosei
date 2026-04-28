local assets = {
    Asset("ANIM", "anim/kochosei_streetlight1_musicbox.zip"),
    Asset("SOUND", "sound/kochosei_streetlight1_musicbox.fsb"),
}

local SCALE = 1.25

local PLANT_TAGS = { "tendable_farmplant" }

-- Hàm chăm sóc cây diện rộng
local function TendToPlantsAOE(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    for _, v in pairs(TheSim:FindEntities(x, y, z, 30, nil, nil, PLANT_TAGS)) do
        if v.components.farmplanttendable ~= nil then
            v.components.farmplanttendable:TendTo(inst)
        end
    end
end

local function TurnOn(inst)
    -- Xử lý âm nhạc
    local music = TUNING.KOCHOSEI_TURNOFFMUSIC
    inst.AnimState:PlayAnimation("idle_on", true)
    if music == 1 then
        inst.SoundEmitter:PlaySound(inst.songToPlay, "kochosei_streetlight1_musicbox/play")
    end

    -- Xử lý hiệu ứng đi kèm
    inst:PushEvent("turnedon")
    if not inst.components.sanityaura then
        inst:AddComponent("sanityaura")
    end
    inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL * 1.2
    
    inst.on = true
    inst.Light:Enable(true)
    
    -- Chăm sóc cây
    if inst.plantafeliz == nil then
        inst.plantafeliz = inst:DoPeriodicTask(0.5, TendToPlantsAOE)
    end
    inst:AddTag("daylight")
end

local function TurnOff(inst)
    inst.AnimState:PlayAnimation("idle_off", true)
    inst.SoundEmitter:KillSound("kochosei_streetlight1_musicbox/play")
    
    inst:RemoveComponent("sanityaura")
    inst:PushEvent("turnedoff")
    
    inst.on = false
    inst.Light:Enable(false)
    
    -- Dừng chăm sóc cây
    if inst.plantafeliz then
        inst.plantafeliz:Cancel()
        inst.plantafeliz = nil
    end
    inst:RemoveTag("daylight")
end

-- Luôn có thể bật/tắt vì không dùng nhiên liệu
local function CanInteract(inst)
    return true
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker) end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(3.7, 3)
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.songToPlay = "kochosei_streetlight1_musicbox/play"

    inst.Light:SetIntensity(0.9)
    inst.Light:SetColour(255 / 255, 200 / 255, 255 / 255)
    inst.Light:SetFalloff(0.9)
    inst.Light:SetRadius(16)
    inst.Light:Enable(false)

    MakeObstaclePhysics(inst, 0.05)

    inst.AnimState:SetBank("kochosei_streetlight1_musicbox")
    inst.AnimState:SetBuild("kochosei_streetlight1_musicbox")
    inst.AnimState:PlayAnimation("idle_off", true)

    inst.Transform:SetScale(SCALE, SCALE, SCALE)

    inst:AddTag("kochosei_streetlight1_musicbox")

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

    -- Component Machine để bật/tắt thủ công
    inst:AddComponent("machine")
    inst.components.machine.turnonfn = TurnOn
    inst.components.machine.turnofffn = TurnOff
    inst.components.machine.caninteractfn = CanInteract
    inst.components.machine.cooldowntime = 0

    return inst
end

STRINGS.NAMES.KOCHOSEI_STREETLIGHT1_MUSICBOX = "Kochosei streetlight musicbox"
STRINGS.RECIPE_DESC.KOCHOSEI_STREETLIGHT1_MUSICBOX = "A beautiful lantern to play music and tend to plants"

return Prefab("kochosei_streetlight1_musicbox", fn, assets),
    MakePlacer("kochosei_streetlight1_musicbox_placer", "kochosei_streetlight1_musicbox", "kochosei_streetlight1_musicbox", "idle_on", nil, nil, nil, SCALE)