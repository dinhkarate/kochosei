-- ============================================================
--                    Kochosei Buff Prefabs
-- ============================================================

local BUFF_DURATION       = 480  -- 8 phút (giây)
local BUFF_DURATION_HEAL  = 5    -- Heal regen giữ nguyên

local buff_prefabs = {
    "wolfgang_coach_buff_fx",
    "cane_rose_fx",
}

-- ============================================================
--                        Helpers
-- ============================================================

local function StopBuff(inst)
    inst.components.debuff:Stop()
end

local function OnDeathEvent(inst, target)
    inst:ListenForEvent("death", function()
        StopBuff(inst)
    end, target)
end

local function ExtendBuff(inst)
    local buffTaskKey =
        (inst.prefab == "elysia_3_buff"   and "bufftask_3")
        or (inst.prefab == "elysia_4_buff" and "bufftask_4")
        or (inst.prefab == "elysia_5_buff" and "bufftask_5")
        or (inst.prefab == "kocho_buff_heal" and "bufftask_heal")
        or "bufftask"

    if inst[buffTaskKey] then
        inst[buffTaskKey]:Cancel()
        inst[buffTaskKey] = inst:DoTaskInTime(BUFF_DURATION, StopBuff)
    end
end

local function AttachCommon(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0)
    OnDeathEvent(inst, target)
end

-- ============================================================
--                      Plant FX (Elysia 3)
-- ============================================================

local PLANTS_RANGE  = 1
local MAX_PLANTS    = 18
local PLANTFX_TAGS  = { "wormwood_plant_fx" }

local plantpool = { 1, 2, 3, 4 }
for i = #plantpool, 1, -1 do
    table.insert(plantpool, table.remove(plantpool, math.random(i)))
end

local function PlantTick(inst)
    if not inst.entity:IsVisible() then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()

    if #TheSim:FindEntities(x, y, z, PLANTS_RANGE, PLANTFX_TAGS) >= MAX_PLANTS then
        return
    end

    local map = TheWorld.Map
    local pt  = Vector3(0, 0, 0)

    local offset = FindValidPositionByFan(
        math.random() * 2 * PI,
        math.random() * PLANTS_RANGE,
        3,
        function(offset)
            pt.x = x + offset.x
            pt.z = z + offset.z
            local tile = map:GetTileAtPoint(pt:Get())
            return tile ~= GROUND.ROCKY
                and tile ~= GROUND.ROAD
                and tile ~= GROUND.WOODFLOOR
                and tile ~= GROUND.CARPET
                and tile ~= GROUND.IMPASSABLE
                and tile ~= GROUND.INVALID
                and #TheSim:FindEntities(pt.x, 0, pt.z, 0.5, PLANTFX_TAGS) < 3
                and map:IsDeployPointClear(pt, nil, 0.5)
                and not map:IsPointNearHole(pt, 0.4)
        end
    )

    if offset ~= nil then
        local plant = SpawnPrefab("wormwood_plant_fx")
        plant.Transform:SetPosition(x + offset.x, 0, z + offset.z)

        -- Ưu tiên variation chưa dùng gần đây
        local rnd = math.random()
        rnd = table.remove(plantpool, math.clamp(math.ceil(rnd * rnd * #plantpool), 1, #plantpool))
        table.insert(plantpool, rnd)
        plant:SetVariation(rnd)
    end
end

-- ============================================================
--                  Elysia 2 — Tăng Sát Thương
-- ============================================================

local function Ely_2_TangST(inst, target)
    AttachCommon(inst, target)
    inst.bufftask = inst:DoTaskInTime(BUFF_DURATION, StopBuff)

    if target and target:IsValid() and target.components.combat then
        local mult = TUNING.WOLFGANG_COACH_BUFF
        target.components.combat.externaldamagemultipliers:SetModifier(inst, mult, "buff_atk_kochosei")

        local fx = SpawnPrefab("wolfgang_coach_buff_fx")
        inst.bufffx = fx
        fx.entity:SetParent(target.entity)
    end
end

local function D_Ely_2_TangST(inst, target)
    if target and target:IsValid() and target.components.combat then
        target.components.combat.externaldamagemultipliers:RemoveModifier(inst, "buff_atk_kochosei")
    end

    if inst.bufffx and inst.bufffx:IsValid() then
        inst.bufffx:Remove()
    end
    inst.bufffx = nil

    inst:Remove()
end

-- ============================================================
--              Elysia 3 — Hồi Não + Tăng Tốc Độ
-- ============================================================

local function Ely_3_HoiNao_TangSpeed(inst, target)
    AttachCommon(inst, target)
    inst.bufftask_3 = inst:DoTaskInTime(BUFF_DURATION, StopBuff)

    if target and target:IsValid() and target.components.combat then
        target:AddDebuff("sweettea_buff", "sweettea_buff")
        target.no_hoa_di = target:DoPeriodicTask(0.25, PlantTick)
        target.components.locomotor:SetExternalSpeedMultiplier(target, "kochosei_speed_mod_ancient", 1.25)
    end
end

local function D_Ely_3_HoiNao_TangSpeed(inst, target)
    if target and target:IsValid() and target.components.combat then
        if target.no_hoa_di ~= nil then
            target.no_hoa_di:Cancel()
            target.no_hoa_di = nil
        end
        target.components.locomotor:RemoveExternalSpeedMultiplier(target, "kochosei_speed_mod_ancient")
    end

    inst:Remove()
end

-- ============================================================
--                  Elysia 4 — Buff Cực Phẩm
-- ============================================================

local function Ely_4_Buff_CucPham(inst, target)
    AttachCommon(inst, target)
    target.tangst          = true
    inst.bufftask_4 = inst:DoTaskInTime(BUFF_DURATION, StopBuff)
end

local function D_Ely_4_Buff_CucPham(inst, target)
    if target and target:IsValid() then
        local hat = target.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if hat and hat.prefab == "kochosei_hatfl" then
            target.tangst = false
        end
    end

    inst:Remove()
end

-- ============================================================
--                  Elysia 5 — Buff Food Tôm
-- ============================================================

local function Buff_Food_Tom(inst, target)
    AttachCommon(inst, target)
    inst.bufftask_5 = inst:DoTaskInTime(BUFF_DURATION, StopBuff)

    target.AnimState:SetScale(2.5, 2.5)
    target.components.health.externalabsorbmodifiers:SetModifier(target, 0.35, "kocho_def_buff_food")
    target.components.hunger:SetMax(999)
    target.components.health:SetMaxHealth(999)
    target.components.sanity:SetMax(999)
end

local function D_Buff_Food_Tom(inst, target)
    if target and target:IsValid() then
        target.AnimState:SetScale(1, 1)
        target.components.health:SetMaxHealth(TUNING.KOCHOSEI_HEALTH)
        target.components.hunger:SetMax(TUNING.KOCHOSEI_HUNGER)
        target.components.sanity:SetMax(TUNING.KOCHOSEI_SANITY)
        target.components.health.externalabsorbmodifiers:RemoveModifier(target, "kocho_def_buff_food")

        if target.components.planarentity then
            target:RemoveComponent("planarentity")
        end
    end

    inst:Remove()
end

-- ============================================================
--                    Kocho Buff — Hồi Máu
-- ============================================================

local function Buff_heal(inst, target)
    AttachCommon(inst, target)
    inst.bufftask_heal = inst:DoTaskInTime(BUFF_DURATION_HEAL, StopBuff)

    if target.components.health then
        target.components.health:AddRegenSource(target, TUNING.KOCHO_TAMBOURIN_HEAL, 0.5, "heal_from_kochosei")
    end
end

local function D_Buff_heal(inst, target)
    if target and target:IsValid() then
        target.components.health:RemoveRegenSource(target, "heal_from_kochosei")
    end

    inst:Remove()
end

-- ============================================================
--                      Prefab Factory
-- ============================================================

local function common()
    local inst = CreateEntity()

    if not TheWorld.ismastersim then
        inst:DoTaskInTime(0, inst.Remove)
        return inst
    end

    inst.entity:AddTransform()
    inst.persists = false
    inst:AddTag("CLASSIFIED")
    inst:AddComponent("debuff")

    return inst
end

local function create_elysia_buff(onAttached, onDetached)
    local inst = common()
    inst.components.debuff:SetAttachedFn(onAttached)
    inst.components.debuff:SetDetachedFn(onDetached)
    inst.components.debuff:SetExtendedFn(ExtendBuff)
    inst.components.debuff.keepondespawn = true
    return inst
end

-- ============================================================
--                         Exports
-- ============================================================

return
    Prefab("elysia_2_buff", function() return create_elysia_buff(Ely_2_TangST,           D_Ely_2_TangST)           end, nil, buff_prefabs),
    Prefab("elysia_3_buff", function() return create_elysia_buff(Ely_3_HoiNao_TangSpeed, D_Ely_3_HoiNao_TangSpeed) end, nil),
    Prefab("elysia_4_buff", function() return create_elysia_buff(Ely_4_Buff_CucPham,     D_Ely_4_Buff_CucPham)     end, nil),
    Prefab("elysia_5_buff", function() return create_elysia_buff(Buff_Food_Tom,           D_Buff_Food_Tom)           end, nil),
    Prefab("kocho_buff_heal",function() return create_elysia_buff(Buff_heal,              D_Buff_heal)               end, nil)