
local function onfreeze(inst, target)
    if not target:IsValid() then
        --target killed or removed in combat damage phase
        return
    end

    if target.components.burnable ~= nil then
        if target.components.burnable:IsBurning() then
            target.components.burnable:Extinguish()
        elseif target.components.burnable:IsSmoldering() then
            target.components.burnable:SmotherSmolder()
        end
    end

    if target.components.combat ~= nil and inst.crab and inst.crab:IsValid() then
        target.components.combat:SuggestTarget(inst.crab)
    end

    if target.sg ~= nil and not target.sg:HasStateTag("frozen") and inst.crab and inst.crab:IsValid() then
        target:PushEvent("attacked", { attacker = inst.crab, damage = 0, weapon = inst })
    end

    if target.components.freezable ~= nil then
        target.components.freezable:AddColdness(10,10 + Remap((inst.crab and inst.crab:IsValid() and inst.crab.gemcount.blue or 0),0,9,0,10) )
        target.components.freezable:SpawnShatterFX()
    end
end

local function dofreezefz(inst)
    if inst.freezetask then
        inst.freezetask:Cancel()
        inst.freezetask = nil
    end
    local time = 0.1
    inst.freezetask = inst:DoTaskInTime(time,function() inst.freezefx(inst) end)
end

local function freezefx(inst)
    local function spawnfx()
        local MAXRADIUS = inst.crab and inst.crab:IsValid() and inst.crab:GetFreezeRange() or (TUNING.CRABKING_FREEZE_RANGE * 0.75)
        local x,y,z = inst.Transform:GetWorldPosition()
        local theta = math.random()*TWOPI
        local radius = 4+ math.pow(math.random(),0.8)* MAXRADIUS
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))

        local prefab = "crab_king_icefx"
        local fx = SpawnPrefab(prefab)
        fx.Transform:SetPosition(x+offset.x,y+offset.y,z+offset.z)
    end

    local MAXFX = Remap(( inst.crab and inst.crab:IsValid() and inst.crab.gemcount.blue or 0),0, 9,5,15)


    local fx = Remap(inst.components.age:GetAge(),0,TUNING.CRABKING_CAST_TIME_FREEZE - (math.min((inst.crab and inst.crab:IsValid() and math.floor(inst.crab.gemcount.yellow/2) or 0),4)),1,MAXFX)

    for i=1,fx do
        if math.random()<0.2 then
            spawnfx()
        end
    end

    dofreezefz(inst)
end

local FREEZE_CANT_TAGS = { "crabking_ally", "shadow", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "INLIMBO" }

local function dofreeze(inst)
    local interval = 0.2
    local pos = Vector3(inst.Transform:GetWorldPosition())
    local range = inst.crab and inst.crab:IsValid() and inst.crab:GetFreezeRange() or (TUNING.CRABKING_FREEZE_RANGE * 0.75)
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, range, nil, FREEZE_CANT_TAGS)
    for i,v in pairs(ents)do
        if v.components.temperature then
            local rate = (TUNING.CRABKING_BASE_FREEZE_AMOUNT + ((inst.crab and inst.crab:IsValid() and inst.crab.gemcount.blue or 0) * TUNING.CRABKING_FREEZE_INCRAMENT)) /( (TUNING.CRABKING_CAST_TIME_FREEZE - (inst.crab and inst.crab:IsValid() and math.floor(inst.crab.gemcount.yellow/2) or 0) ) /interval)
            if v.components.moisture then
                rate = rate * Remap(v.components.moisture:GetMoisture(),0,v.components.moisture.maxmoisture,1,3)
            end

            local mintemp = v.components.temperature.mintemp
            local curtemp = v.components.temperature:GetCurrent()
            if mintemp < curtemp then
                v.components.temperature:DoDelta(math.max(-rate, mintemp - curtemp))
            end
        end
    end

    local time = 0.2
    inst.lowertemptask = inst:DoTaskInTime(time,function() inst.dofreeze(inst) end)
end

local function endfreeze(inst)
    if inst.freezetask then
        inst.freezetask:Cancel()
        inst.freezetask = nil
    end

    if inst.lowertemptask then
        inst.lowertemptask:Cancel()
        inst.lowertemptask = nil
    end
    inst:DoTaskInTime(1, inst.Remove)
end

local function freezefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("fx")
    inst:AddTag("crabking_spellgenerator")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("age")

    inst.persists = false

    inst.freezefx = freezefx
    inst.dofreeze = dofreeze
    inst:DoTaskInTime(0,function()
        dofreezefz(inst)
        dofreeze(inst)
    end)

    inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/ice_attack")

    inst:ListenForEvent("onremove", function()
        if inst.burbletask then
            inst.burbletask:Cancel()
            inst.burbletask = nil
        end
    end)

    inst:ListenForEvent("endspell", function()
        endfreeze(inst)
    end)

    inst:DoTaskInTime(TUNING.CRABKING_CAST_TIME+2,function()
        endfreeze(inst)
    end)

    return inst
end

local function fcmnx()

        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst:AddTag("FX")
        inst.AnimState:SetBank("deer_ice_flakes")
        inst.AnimState:SetBuild("deer_ice_flakes")
        inst.AnimState:PlayAnimation("idle", true)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetFinalOffset(1)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
		
        return inst

   
end

return   Prefab("kochosei_crabking_feeze", freezefn)
--,  Prefab("kochosei_idle_crabking_feeze", fcmnx, nil, freezeprefabs)