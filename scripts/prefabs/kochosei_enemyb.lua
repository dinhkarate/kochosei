local assets = {
	Asset("ANIM", "anim/kochosei.zip"),
	Asset("ANIM", "anim/kochosei_snowmiku_skin1.zip"),
	Asset("SOUND", "sound/maxwell.fsb"),
}

local brain = require("brains/kochosei_enemy_brain_b")
local prefabs = {
	"shadow_despawn",
	"statue_transition_2",
}

local function onopen(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
	inst.sg:GoToState("dance")
	if inst.brain ~= nil then
		inst.brain:Stop()
	end
end

local function onclose(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
	inst.sg:GoToState("idle")
	if inst.brain ~= nil then
		inst.brain:Start()
	end
end

local function m_killPet(inst)
	if inst.components.container ~= nil then
		inst.components.container:DropEverything()
	end
	if inst.components.health and not inst.components.health:IsDead() then
		inst.components.health:Kill()
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
	else
		m_killPet(inst)
	end
end

local function OnAttacked(inst, data)
	if data.attacker ~= nil then
		if data.attacker.components.petleash ~= nil and data.attacker.components.petleash:IsPet(inst) then
			m_killPet(inst)
		end
	end
end

local function balovali(inst)
	inst.AnimState:OverrideSymbol("swap_body", "swap_miku_usagi_backpack", "usagi")
	inst.AnimState:OverrideSymbol("swap_body", "swap_miku_usagi_backpack", "swap_body")

	inst:AddComponent("inventory")
	inst.components.inventory.maxslots = 0
	inst.components.inventory.GetOverflowContainer = function(self)
		return self.inst.components.container
	end

	inst:AddComponent("container")
	inst.components.container:WidgetSetup("chester")
	inst.components.container.onopenfn = onopen
	inst.components.container.onclosefn = onclose

	inst.components.health:SetMaxHealth(TUNING.KOCHOSEI_SLAVE_HP * 2)
	inst.components.health:StartRegen(TUNING.SHADOWWAXWELL_HEALTH_REGEN, TUNING.SHADOWWAXWELL_HEALTH_REGEN_PERIOD)

	return inst
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

		--MakeGiantCharacterPhysics(inst, 50, .7)
		MakeGhostPhysics(inst, 0.5, 0.5)
		inst.Transform:SetFourFaced(inst)

		--Scale of your kochosei_enemy.
		--inst.Transform:SetScale(1.75, 1.75, 1.75)

		inst.AnimState:SetBank("wilson")

		inst.AnimState:SetBuild("kochosei")

		inst.AnimState:PlayAnimation("idle")
		inst.AnimState:SetScale(0.8, 0.8)

		inst.Transform:SetFourFaced(inst)

		inst:AddTag("scarytoprey")
		inst:AddTag("NOBLOCK")
		inst:AddTag("summonerally")
		inst:AddTag("kochosei_enemy")

		inst:SetPrefabNameOverride("kochosei_enemy")

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			inst.OnEntityReplicated = function(inst)
				inst.replica.container:WidgetSetup("chester")
			end
			return inst
		end
		inst.needtostop = 0
		inst:AddComponent("inspectable")
		inst:AddComponent("locomotor")
		inst.components.locomotor.runspeed = 12
		inst.components.locomotor:SetTriggersCreep(false)
		inst.components.locomotor.pathcaps = { allowocean = false }
		inst.components.locomotor:SetSlowMultiplier(0.6)
		inst.components.locomotor:SetAllowPlatformHopping(true)

		inst:AddComponent("embarker")
		inst:AddComponent("drownable")

		inst:AddComponent("health")
		inst.components.health:SetMaxHealth(TUNING.KOCHOSEI_SLAVE_HP)

		inst:AddComponent("combat")
		inst.components.combat.hiteffectsymbol = "torso"
		inst.components.combat:SetRange(2)
		inst.components.combat:SetAttackPeriod(3)

		inst:AddComponent("follower")
		inst.components.follower:KeepLeaderOnAttacked()
		inst.components.follower.keepdeadleader = true
		inst.components.follower.keepleaderduringminigame = true

		inst:AddComponent("lootdropper")
		inst:AddComponent("talker")

		inst:SetBrain(brain)
		inst:SetStateGraph("SGkochosei_enemy")

		inst:ListenForEvent("attacked", OnAttacked)

		inst:ListenForEvent("death", m_killPet)

	--	inst:DoPeriodicTask(1, m_checkLeaderExisting)

		inst.LinkToPlayer = linktoplayer
		if master_postinit ~= nil then
			master_postinit(inst)
		end

		return inst
	end
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

return MakeMinion("kochosei_enemyb", nil, nil, balovali), MakeBuilder("kochosei_enemyb")
