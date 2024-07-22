local MakeMinion = require("prefabs/player_common")
local assets = {
    Asset("ANIM", "anim/kochosei.zip"),
    Asset("ANIM", "anim/kochosei_snowmiku_skin1.zip"),
    Asset("SOUND", "sound/maxwell.fsb"),
}

local brain = require("brains/kochosei_enemy_brain")
local prefabs = {
    "shadow_despawn",
    "statue_transition_2",
}

local function haru(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local spell = SpawnPrefab("crab_king_icefx")
    spell.Transform:SetPosition(x, y, z)
end

local items = { -- a local table to store the item names
    kocho_miku_cos = true,
    kocho_miku_back = true,
    dragon_scales = true,
    bearger_fur = true,
}

local function NhanItemCuaDinhCute(inst, item)
    local dinh = item.prefab
    return items[dinh]                                                                                                             -- check if the item name is in the table
        or item.components.equippable                                                                                              -- check if the item is equippable
        and (
            item.components.equippable.equipslot == EQUIPSLOTS.HEAD                                                                -- check if the equipslot is HEAD
            or item.components.equippable.equipslot == EQUIPSLOTS.HANDS                                                            -- check if the equipslot is HANDS
            or item.components.equippable.equipslot == EQUIPSLOTS.BODY) and
        not (item.components.projectile or item.prefab == "fanhundie")                                                             -- check if the item is not a projectile
end

local function m_killPet(inst)
    if inst.components.health and not inst.components.health:IsDead() then
        inst.components.health:Kill()
    end
end

local function doiskin(inst)
    inst.AnimState:SetBuild("kochosei_snowmiku_skin1")
    haru(inst)
end

local function SlaveDeoNhanDoRaidenFuckYou(inst, giver, item)
    inst.sg:GoToState("facepalm")
    inst.components.talker:Say("I dont take this, my master! You give me wrong thing! Please try again!", 5, false)
end

local function OnGetItemFromPlayer(inst, giver, item)
    local equippable = item.components.equippable
    if equippable and (equippable.equipslot == EQUIPSLOTS.HEAD
            or equippable.equipslot == EQUIPSLOTS.HANDS
            or equippable.equipslot == EQUIPSLOTS.BODY) then
        local newslot = equippable.equipslot
        local current = inst.components.inventory:GetEquippedItem(newslot)
        if current then
            inst.components.inventory:DropItem(current)
        end
        inst.components.inventory:Equip(item)
    end

    if item.prefab == "kocho_miku_cos" then
        doiskin(inst)
    elseif giver.prefab == "kochosei" then
        local x, y, z = inst.Transform:GetWorldPosition()

        if item.prefab == "kocho_miku_back" then
            giver.components.petleash:DespawnPet(inst)
            giver.components.petleash:SpawnPetAt(x, y, z, "kochosei_enemyb")
        elseif item.prefab == "dragon_scales" then
            giver.components.petleash:DespawnPet(inst)
            local df = giver.components.petleash:SpawnPetAt(x, y, z, "kochodragonfly")
            local rot = inst.Transform:GetRotation()
            if df then
                df.Transform:SetPosition(x, y, z)
                df.components.follower:SetLeader(giver)
                df.Transform:SetRotation(rot)
                df.sg:GoToState("land")
            end
        elseif item.prefab == "bearger_fur" then
            giver.components.petleash:DespawnPet(inst)
            local bear = giver.components.petleash:SpawnPetAt(x, y, z, "kocho_bearger")
            local rot = inst.Transform:GetRotation()
            if bear then
                bear.Transform:SetPosition(x, y, z)
                bear.components.follower:SetLeader(giver)
                bear.Transform:SetRotation(rot)
                --  bear.sg:GoToState("taunt")
            end
        end
    end
end

local function linktoplayer(inst, player)
    inst.components.lootdropper:SetLoot(LOOT)
    inst.persists = false
    inst._playerlink = player
    player.kochosei_enemy = inst
    player.components.leader:AddFollower(inst)
    for k, v in pairs(player.shurr_yken) do
        k:Refresh()
    end
    player:ListenForEvent("onremove", unlink, inst)
end

local function m_checkLeaderExisting(inst)
    local leader = inst.components.follower:GetLeader()
    if
        leader ~= nil
        and leader.components.health ~= nil
        and not (leader.components.health:IsDead() or leader:HasTag("playerghost"))
    then
        return
    elseif inst._killtask == nil then
        inst._killtask = inst:ResumeTask(2, m_killPet)
        inst.sg:GoToState("cry")
    end
end

local function OnAttacked(inst, data)
    if data.attacker ~= nil then
        if data.attacker.components.petleash ~= nil and data.attacker.components.petleash:IsPet(inst) then
            m_killPet(inst)
        elseif data.attacker.components.combat ~= nil then
            inst.components.combat:SuggestTarget(data.attacker)
        end
    end
end

local function retargetfn(inst)
    local leader = inst.components.follower:GetLeader()
    return leader ~= nil
        and FindEntity(leader, TUNING.SHADOWWAXWELL_TARGET_DIST, function(guy)
            return guy ~= inst
                and (guy.components.combat:TargetIs(leader) or guy.components.combat:TargetIs(inst))
                and inst.components.combat:CanTarget(guy)
        end, { "_combat" }, { "playerghost", "INLIMBO" })
        or nil
end

local function keeptargetfn(inst, target)
    return inst.components.follower:IsNearLeader(14)
        and inst.components.combat:CanTarget(target)
        and target.components.minigame_participator == nil
end

local function spearfn(inst)
    inst.components.health:SetMaxHealth(TUNING.KOCHOSEI_SLAVE_HP + TUNING.KOCHOSEI_CHECKWIFI)
    inst.components.health:StartRegen(TUNING.SHADOWWAXWELL_HEALTH_REGEN, TUNING.SHADOWWAXWELL_HEALTH_REGEN_PERIOD)

    inst.components.combat:SetDefaultDamage(TUNING.KOCHOSEI_SLAVE_DAMAGE)
    inst.components.combat:SetAttackPeriod(0.4)
    inst.components.combat:SetRetargetFunction(2, retargetfn)
    inst.components.combat:SetKeepTargetFunction(keeptargetfn)

    return inst
end

local function OnEnterWater(inst)
    inst.hop_distance = inst.components.locomotor.hop_distance
    inst.components.locomotor.hop_distance = 4

    inst.AnimState:SetBuild("spider_water_water")
end

local function OnExitWater(inst)
    if inst.hop_distance then
        inst.components.locomotor.hop_distance = inst.hop_distance
    end

    inst.AnimState:SetBuild("spider_water")
end

local function ondeath(inst)
    inst.components.inventory:DropEverythingWithTag("weapon")
end
local function OnEquipCustom(inst, data)
    local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if equipped and equipped.components.weapon then
        local check = equipped.components.weapon.attackrange
        inst.components.combat:SetRange(check or 1)
    end
end

local function OnUnequipCustom(inst, data)
    if data.item ~= nil then
        if data.item.components.weapon then
            inst.components.combat:SetRange(1)
        end
    end
end

local function MakeMinion(prefab, tool, hat, master_postinit)
    local assets = {}

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()
        inst.entity:AddDynamicShadow()

        MakeGhostPhysics(inst, 1, .75)
        inst.Transform:SetFourFaced(inst)


        inst.AnimState:SetBank("wilson")

        inst.AnimState:SetBuild("kochosei")

        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:SetScale(0.8, 0.8)

        inst.Transform:SetFourFaced(inst)

        if tool ~= nil then
            inst.AnimState:OverrideSymbol("swap_object", tool, tool)
            inst.AnimState:Hide("ARM_normal")
        else
            inst.AnimState:Hide("ARM_carry")
        end

        if hat ~= nil then
            inst.AnimState:OverrideSymbol("swap_hat", hat, "swap_hat")
            inst.AnimState:Hide("HAIR_NOHAT")
            inst.AnimState:Hide("HAIR")
        else
            inst.AnimState:Hide("HAT")
            inst.AnimState:Hide("HAIR_HAT")
        end

        inst:AddTag("scarytoprey")
        inst:AddTag("kochosei_enemy")
        inst:AddTag("kochosei_enemy_skin_1")
        inst:AddTag("trader")
        inst:SetPrefabNameOverride("kochosei_enemy")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end
        inst:AddComponent("inspectable")

        inst:AddComponent("locomotor")
        inst.components.locomotor.runspeed = 12
        inst.components.locomotor:SetSlowMultiplier(0.6)
        inst.components.locomotor:SetAllowPlatformHopping(true)

        inst:AddComponent("embarker")

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(TUNING.KOCHOSEI_SLAVE_HP)

        inst:AddComponent("sanity")

        function inst.components.sanity:DoDelta(delta, overtime)
            return
        end

        function inst.components.sanity:Recalc(dt)
            return
        end

        inst:AddComponent("combat")
        inst:AddComponent("debuffable")
        inst.components.combat.hiteffectsymbol = "torso"
        inst.components.combat:SetRange(2)
        inst.components.combat:SetAttackPeriod(3)

        inst:AddComponent("inventory")

        inst:AddComponent("trader")
        inst.components.trader:SetAcceptTest(NhanItemCuaDinhCute)
        inst.components.trader.onaccept = OnGetItemFromPlayer
        inst.components.trader.onrefuse = SlaveDeoNhanDoRaidenFuckYou
        inst.components.trader.deleteitemonaccept = false

        inst:AddComponent("follower")
        inst.components.follower:KeepLeaderOnAttacked()
        inst.components.follower.keepdeadleader = true
        inst.components.follower.keepleaderduringminigame = true

        inst:AddComponent("lootdropper")
        inst:AddComponent("talker")

        inst:SetBrain(brain)
        inst:SetStateGraph("SGkochosei_enemy")

        inst:ListenForEvent("death", ondeath)
        inst:ListenForEvent("attacked", OnAttacked)

        inst:ListenForEvent("equip", OnEquipCustom)
        inst:ListenForEvent("unequip", OnUnequipCustom)

        --inst:DoPeriodicTask(1, m_checkLeaderExisting)

        inst.LinkToPlayer = linktoplayer
        if master_postinit ~= nil then
            master_postinit(inst)
        end

        return inst
    end

    STRINGS.NAMES.KOCHOSEI_ENEMY = "Kochosei Clone"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_ENEMY = "ヾ(•ω•`)o"

    return Prefab(prefab, fn, assets, prefabs)
end

--------------------------------------------------------------------------
local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function onbuilt(inst, builder)
    local theta = math.random() * 2 * PI
    local pt = builder:GetPosition()
    local radius = math.random(3, 6)
    local offset = FindWalkableOffset(pt, theta, radius, 12, true, true, NoHoles)
    if offset ~= nil then
        pt.x = pt.x + offset.x
        pt.z = pt.z + offset.z
    end
    builder.components.petleash:SpawnPetAt(pt.x, 0, pt.z, inst.pettype)
    inst:Remove()
end

local function MakeBuilder(prefab)
    --These shadows are summoned this way because petleash needs to
    --be the component that summons the pets, not the builder.
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()

        inst:AddTag("CLASSIFIED")

        --[[Non-networked entity]]
        inst.persists = false

        --Auto-remove if not spawned by builder
        inst:DoTaskInTime(0, inst.Remove)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.pettype = prefab
        inst.OnBuiltFn = onbuilt

        return inst
    end

    return Prefab(prefab .. "_builder", fn, nil, { prefab })
end

--------------------------------------------------------------------------

return MakeMinion("kochosei_enemy", nil, nil, spearfn), MakeBuilder("kochosei_enemy")
