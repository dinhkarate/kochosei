require("prefabutil")

local assets = {
    Asset("ANIM", "anim/kochosei_coffin.zip"),
}

local prefabs = {}

local SCALE = 2.5

-----------------------------------------------------------------------
-- Hammered/Hit callbacks
-----------------------------------------------------------------------

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("open", false)  -- Đảo: mở là bình thường
    end
    if inst.components.sleepingbag ~= nil and inst.components.sleepingbag.sleeper ~= nil then
        inst.components.sleepingbag:DoWakeUp()
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("open")  -- Đảo: mở là bình thường
    inst.SoundEmitter:PlaySound("dontstarve/common/tent_craft")
end

local function onburnt(inst)
    -- Animation "burnt" không có trong SCML, dùng "open" thay thế
    inst.AnimState:PlayAnimation("open")
    inst:AddTag("burnt")
    inst:RemoveComponent("sleepingbag")
end

local function onignite(inst)
    if inst.components.sleepingbag then
        inst.components.sleepingbag:DoWakeUp()
    end
end

-----------------------------------------------------------------------
-- Sleep functions - Cho phép ngủ bất kỳ lúc nào
-----------------------------------------------------------------------

local function wakeuptest(inst, phase)
    -- Không có điều kiện thức dậy theo phase - có thể ngủ cả ngày lẫn đêm
    -- Player tự thức dậy khi muốn
end

local function onwake(inst, sleeper, nostatechange)
    if inst.sleeptask ~= nil then
        inst.sleeptask:Cancel()
        inst.sleeptask = nil
    end

    inst:StopWatchingWorldState("phase", wakeuptest)
    sleeper:RemoveEventCallback("onignite", onignite, inst)

    if not nostatechange then
        if sleeper.sg:HasStateTag("tent") then
            sleeper.sg.statemem.iswaking = true
        end
        sleeper.sg:GoToState("wakeup")
    end

    inst.AnimState:PlayAnimation("open")  -- Đảo: khi thức dậy, mở quan tài
end

local function onsleeptick(inst, sleeper)
    local isstarving = sleeper.components.beaverness ~= nil and sleeper.components.beaverness:IsStarving()

    -- Đói chậm hơn 2 lần (hunger_tick đã được set = TUNING value / 2)
    if sleeper.components.hunger ~= nil then
        sleeper.components.hunger:DoDelta(inst.hunger_tick, true, true)
        isstarving = sleeper.components.hunger:IsStarving()
    end

    -- Hồi sanity siêu nhanh (gấp 4 lần bình thường)
    if sleeper.components.sanity ~= nil and sleeper.components.sanity:GetPercentWithPenalty() < 1 then
        sleeper.components.sanity:DoDelta(inst.sanity_tick, true)
    end

    -- Hồi máu siêu nhanh + hồi máu đen (health penalty)
    if not isstarving and sleeper.components.health ~= nil then
        -- Hồi máu siêu nhanh (gấp 4 lần)
        sleeper.components.health:DoDelta(inst.health_tick, true, inst.prefab, true)
        -- Hồi máu đen - giảm health penalty
        sleeper.components.health:DeltaPenalty(-0.02)
    end

    -- Temperature control
    if sleeper.components.temperature ~= nil then
        if inst.is_cooling then
            if sleeper.components.temperature:GetCurrent() > TUNING.SLEEP_TARGET_TEMP_TENT then
                sleeper.components.temperature:SetTemperature(
                    sleeper.components.temperature:GetCurrent() - TUNING.SLEEP_TEMP_PER_TICK)
            end
        elseif sleeper.components.temperature:GetCurrent() < TUNING.SLEEP_TARGET_TEMP_TENT then
            sleeper.components.temperature:SetTemperature(
                sleeper.components.temperature:GetCurrent() + TUNING.SLEEP_TEMP_PER_TICK)
        end
    end

    if isstarving then
        inst.components.sleepingbag:DoWakeUp()
    end
end

local function onsleep(inst, sleeper)
    inst:WatchWorldState("phase", wakeuptest)
    sleeper:ListenForEvent("onignite", onignite, inst)

    inst.AnimState:PlayAnimation("close", true)  -- Đảo: khi ngủ, đóng quan tài

    if inst.sleeptask ~= nil then
        inst.sleeptask:Cancel()
    end
    inst.sleeptask = inst:DoPeriodicTask(TUNING.SLEEP_TICK_PERIOD, onsleeptick, nil, sleeper)
end

-----------------------------------------------------------------------
-- Save/Load
-----------------------------------------------------------------------

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

-----------------------------------------------------------------------
-- Main function
-----------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.8)

    inst:AddTag("tent")
    inst:AddTag("structure")
    inst:AddTag("siestahut")

    inst.AnimState:SetBank("kochosei_coffin_5x5")
    inst.AnimState:SetBuild("kochosei_coffin")
    inst.AnimState:PlayAnimation("open", false)  -- Đảo: mở là bình thường
    inst.AnimState:SetScale(SCALE, SCALE, SCALE)

    inst.MiniMapEntity:SetIcon("kochosei_coffin_close_64.tex")

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

    inst:AddComponent("sleepingbag")
    inst.components.sleepingbag.onsleep = onsleep
    inst.components.sleepingbag.onwake = onwake
    inst.components.sleepingbag.dryingrate = math.max(0, -TUNING.SLEEP_WETNESS_PER_TICK / TUNING.SLEEP_TICK_PERIOD)
    
    -- CHO PHÉP NGỦ BẤT KỲ LÚC NÀO (ngày, chiều, tối)
    -- Set sleep_phase = nil để WakeUpTest không bao giờ đánh thức player theo phase
    inst.components.sleepingbag.sleep_phase = nil
    
    -- Override GetSleepPhase để luôn trả về phase hiện tại (không bao giờ wake up theo phase)
    inst.components.sleepingbag.GetSleepPhase = function(self)
        return TheWorld.state.phase  -- Luôn trả về phase hiện tại nên không bao giờ bị đánh thức
    end
    
    -- CHO PHÉP NGỦ BẤT KỲ LÚC NÀO - Override CanSleep để bỏ qua kiểm tra phase
    -- Đây là hàm kiểm tra trước khi player được phép nằm xuống ngủ
    inst.components.sleepingbag.CanSleep = function(self, sleeper)
        print("Kochosei Coffin: CanSleep override called")
        -- Kiểm tra cơ bản: sleeper phải tồn tại và có thể ngủ
        if sleeper == nil then
            return false
        end
        -- Luôn cho phép ngủ, bỏ qua mọi điều kiện phase (ngày/đêm)
        return true
    end

    -- Tốc độ hồi phục siêu nhanh (SET VÀO COMPONENT, KHÔNG PHẢI INST!)
    -- Sanity: gấp 8 lần bình thường
    inst.components.sleepingbag.sanity_tick = TUNING.SLEEP_SANITY_PER_TICK * 8
    -- Health: gấp 8 lần bình thường  
    inst.components.sleepingbag.health_tick = TUNING.SLEEP_HEALTH_PER_TICK * 8
    -- Hunger: chậm hơn 4 lần (giảm 1/4 tốc độ đói)
    inst.components.sleepingbag.hunger_tick = TUNING.SLEEP_HUNGER_PER_TICK / 4
    
    -- Cũng giữ lại trong inst cho onsleeptick custom (nếu được dùng)
    inst.sanity_tick = inst.components.sleepingbag.sanity_tick
    inst.health_tick = inst.components.sleepingbag.health_tick
    inst.hunger_tick = inst.components.sleepingbag.hunger_tick

    MakeSnowCovered(inst)
    inst:ListenForEvent("onbuilt", onbuilt)

    MakeLargeBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnIgniteFn(onignite)
    inst.components.burnable:SetOnBurntFn(onburnt)
    MakeMediumPropagator(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

    MakeHauntableWork(inst)

    return inst
end

return Prefab("kochosei_coffin", fn, assets, prefabs),
    MakePlacer("kochosei_coffin_placer", "kochosei_coffin_5x5", "kochosei_coffin", "open", nil, nil, nil, SCALE)
