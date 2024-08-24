local buff_prefabs = {
    "wolfgang_coach_buff_fx",
    "cane_rose_fx",
}

local function StopBuff(inst)
    inst.components.debuff:Stop()
end

local function OnDeathEvent(inst, target)
    inst:ListenForEvent("death", function()
        StopBuff(inst)
    end, target)
end

local function ExtendBuff(inst)
    local buffTaskKey = (inst.prefab == "elysia_3_buff" and "bufftask_3")
                     or (inst.prefab == "elysia_4_buff" and "bufftask_4")
                     or (inst.prefab == "elysia_5_buff" and "bufftask_5")
                     or "bufftask"

    if inst[buffTaskKey] then
        inst[buffTaskKey]:Cancel()
        local duration = inst.prefab == "elysia_5_buff" and 120 or 60
        inst[buffTaskKey] = inst:DoTaskInTime(duration, StopBuff)
    end
end

local function AttachCommon(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0)
    OnDeathEvent(inst, target)
end

local function OnAttached(inst, target)
    AttachCommon(inst, target)
    inst.bufftask = inst:DoTaskInTime(60, StopBuff)

    if target and target:IsValid() and target.components.combat then
        local mult = TUNING.WOLFGANG_COACH_BUFF
        target.components.combat.externaldamagemultipliers:SetModifier(inst, mult, "buff_atk_kochosei")
        local fx = SpawnPrefab("wolfgang_coach_buff_fx")
        inst.bufffx = fx
        fx.entity:SetParent(target.entity)
    end
end

local function OnDetached(inst, target)
    if target and target:IsValid() and target.components.combat then
        target.components.combat.externaldamagemultipliers:RemoveModifier(inst, "buff_atk_kochosei")
    end
    if inst.bufffx and inst.bufffx:IsValid() then
        inst.bufffx:Remove()
    end
    inst.bufffx = nil
    inst:Remove()
end

local function OnAttached_3(inst, target)
    AttachCommon(inst, target)
    inst.bufftask_3 = inst:DoTaskInTime(60, StopBuff)

    if target and target:IsValid() and target.components.combat then
        target:AddDebuff("sweettea_buff", "sweettea_buff")
        target.magicfx_ancient = SpawnPrefab("cane_rose_fx")
        if target.magicfx_ancient then
            target.magicfx_ancient.entity:AddFollower()
            target.magicfx_ancient.entity:SetParent(target.entity)
            target.magicfx_ancient.Follower:FollowSymbol(target.GUID, "swap_body", 0, 0, 0)
        end
    end
end

local function OnDetached_3(inst, target)
    if target and target:IsValid() and target.components.combat then
        if target.magicfx_ancient then
            target.magicfx_ancient:Remove()
            target.magicfx_ancient = nil
        end
    end
    inst:Remove()
end

local function OnAttached_4(inst, target)
    AttachCommon(inst, target)
    target.tangst = true
    inst.bufftask_4 = inst:DoTaskInTime(60, StopBuff)
end

local function OnDetached_4(inst, target)
    if target and target:IsValid() then
        local hat = target.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if hat and hat.prefab == "kochosei_hatfl" then
            target.tangst = false
        end
    end
    inst:Remove()
end

local function OnAttached_5(inst, target)
    AttachCommon(inst, target)
    inst.bufftask_5 = inst:DoTaskInTime(120, StopBuff)
    target.AnimState:SetScale(2.5, 2.5)
    target.components.health.externalabsorbmodifiers:SetModifier(target, 0.35, "kocho_def_buff_food")
    target.components.hunger:SetMax(999)
    target.components.health:SetMaxHealth(999)
    target.components.sanity:SetMax(999)
    if not target.components.planarentity then
        target:AddComponent("planarentity")
    end
end

local function OnDetached_5(inst, target)
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

return Prefab("elysia_2_buff", function() return create_elysia_buff(OnAttached, OnDetached) end, nil, buff_prefabs),
       Prefab("elysia_3_buff", function() return create_elysia_buff(OnAttached_3, OnDetached_3) end, nil, buff_prefabs),
       Prefab("elysia_4_buff", function() return create_elysia_buff(OnAttached_4, OnDetached_4) end, nil, buff_prefabs),
       Prefab("elysia_5_buff", function() return create_elysia_buff(OnAttached_5, OnDetached_5) end, nil, buff_prefabs)