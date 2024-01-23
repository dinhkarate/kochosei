local brain = require("brains/kochodragonflybrain")

local assets = {
	Asset("ANIM", "anim/dragonfly_build.zip"),
	Asset("ANIM", "anim/dragonfly_fire_build.zip"),
	Asset("ANIM", "anim/dragonfly_basic.zip"),
	Asset("ANIM", "anim/dragonfly_actions.zip"),
	Asset("ANIM", "anim/dragonfly_yule_build.zip"),
	Asset("ANIM", "anim/dragonfly_fire_yule_build.zip"),
	Asset("SOUND", "sound/dragonfly.fsb"),
}

local prefabs = {
	"firesplash_fx",
	"tauntfire_fx",
	"attackfire_fx",
	"vomitfire_fx",
	"firering_fx", -- loot:
	"dragon_scales",
	"lavae_egg",
	"meat",
	"goldnugget",
	"redgem",
	"bluegem",
	"purplegem",
	"orangegem",
	"yellowgem",
	"greengem",
	"dragonflyfurnace_blueprint",
	"chesspiece_dragonfly_sketch",
}

local loot = { "dragon_scales" }

--------------------------------------------------------------------------

local function ForceDespawn(inst)
	inst:Reset()
	inst:DoDespawn()
end

local function ToggleDespawnOffscreen(inst)
	if inst:IsAsleep() then
		if inst.sleeptask == nil then
			inst.sleeptask = inst:DoTaskInTime(10, ForceDespawn)
		end
	elseif inst.sleeptask ~= nil then
		inst.sleeptask:Cancel()
		inst.sleeptask = nil
	end
end

--------------------------------------------------------------------------

--------------------------------------------------------------------------

local function TransformNormal(inst)
	inst.AnimState:SetBuild(
		IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "dragonfly_fire_yule_build" or "dragonfly_fire_build"
	)
	inst.enraged = false
	-- Set normal stats
	inst.components.locomotor.walkspeed = TUNING.DRAGONFLY_SPEED
	inst.components.combat:SetDefaultDamage(TUNING.DRAGONFLY_DAMAGE)
	inst.components.combat:SetAttackPeriod(1)
	inst.components.combat:SetRange(TUNING.DRAGONFLY_ATTACK_RANGE, TUNING.DRAGONFLY_HIT_RANGE)

	inst.components.freezable:SetResistance(TUNING.DRAGONFLY_FREEZE_THRESHOLD)

	inst.components.propagator:StopSpreading()
	inst.Light:Enable(true)
end

local function _OnRevert(inst)
	inst.reverttask = nil
	if inst.enraged then
		inst:PushEvent("transform", { transformstate = "normal" })
	end
end

local function TransformFire(inst)
	inst.AnimState:SetBuild(
		IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "dragonfly_fire_yule_build" or "dragonfly_fire_build"
	)
	inst.enraged = true
	inst.can_ground_pound = true
	-- Set fire stats
	inst.components.locomotor.walkspeed = TUNING.DRAGONFLY_FIRE_SPEED
	inst.components.combat:SetDefaultDamage(TUNING.DRAGONFLY_FIRE_DAMAGE)
	inst.components.combat:SetAttackPeriod(1)
	inst.components.combat:SetRange(TUNING.DRAGONFLY_ATTACK_RANGE, TUNING.DRAGONFLY_FIRE_HIT_RANGE)

	inst.Light:Enable(true)
	inst.components.propagator:StartSpreading()

	inst.components.moisture:DoDelta(-inst.components.moisture:GetMoisture())

	inst.components.freezable:SetResistance(TUNING.DRAGONFLY_ENRAGED_FREEZE_THRESHOLD)

	if inst.reverttask ~= nil then
		inst.reverttask:Cancel()
	end
	inst.reverttask = inst:DoTaskInTime(TUNING.DRAGONFLY_ENRAGE_DURATION, _OnRevert)
end

local function KeepTargetFn(inst, target)
	return inst.components.combat:CanTarget(target)
end

local function OnTimerDone(inst, data)
	if data.name == "groundpound_cd" then
		inst.can_ground_pound = true
	end
end

local function ondeath(inst)
	inst.components.lootdropper:DropLoot(inst:GetPosition())
end

local function onPeriodicTask(inst)
	local leader = inst.components.follower:GetLeader()
	local combat = inst.components.combat
	if leader and combat and not combat:HasTarget() then
		local target = FindEntity(inst, 20, function(i)
			if i.components.combat and i.components.combat:TargetIs(leader) then
				return true
			end
			return false
		end, { "_combat" })
		if target then
			combat:SetTarget(target)
		end
	end
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
		inst.components.health:Kill()
	end
end

local function OnAttacked(inst, data)
	if data.attacker ~= nil then
		if data.attacker:HasTag("kochoseipet") then
			return
		end
		if data.attacker.components.petleash ~= nil and data.attacker.components.petleash:IsPet(inst) then
			inst.components.health:Kill()
		elseif data.attacker.components.combat ~= nil then
			inst.components.combat:SuggestTarget(data.attacker)
		end
	end
end

local function OnHitOther(inst, other)
	if other and other:HasTag("Kochoseipet") then 
		inst.components.combat:GiveUp()
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
	inst.entity:AddLight()
	inst.entity:AddNetwork()

	inst.DynamicShadow:SetSize(6, 3.5)
	inst.Transform:SetSixFaced()
	inst.Transform:SetScale(1.3, 1.3, 1.3)

	MakeFlyingGiantCharacterPhysics(inst, 500, 1.4)

	inst.AnimState:SetBank("dragonfly")
	inst.AnimState:SetBuild("dragonfly_fire_build")
	inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:SetScale(0.6, 0.6)

	inst:AddTag("scarytoprey")
	inst:AddTag("largecreature")
	inst:AddTag("flying")
	inst:AddTag("ignorewalkableplatformdrowning")
	
	inst:AddTag("kochoseipet")

	inst.Light:Enable(true)
	inst.Light:SetRadius(2)
	inst.Light:SetFalloff(0.5)
	inst.Light:SetIntensity(0.75)
	inst.Light:SetColour(235 / 255, 121 / 255, 12 / 255)

	inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	-- Component Definitions

	inst:AddComponent("health")
	inst:AddComponent("groundpounder")
	inst:AddComponent("combat")
	inst:AddComponent("explosiveresist")
	inst:AddComponent("inspectable")
	inst:AddComponent("locomotor")
	inst:AddComponent("knownlocations")
	inst:AddComponent("inventory")
	inst:AddComponent("timer")
	inst:AddComponent("grouptargeter")
	inst:AddComponent("damagetracker")
	inst:AddComponent("stunnable")
	inst:AddComponent("healthtrigger")
	inst:SetStateGraph("SGdragonfly")
	inst:AddComponent("follower")

	inst:AddComponent("heater")
    inst.components.heater.heat = 115

	inst.components.follower:KeepLeaderOnAttacked()
	inst.components.follower.keepdeadleader = true
	inst.components.follower.keepleaderduringminigame = true

	inst:DoPeriodicTask(1, onPeriodicTask)
	inst:DoPeriodicTask(1, m_checkLeaderExisting)
	inst:ListenForEvent("attacked", OnAttacked)

	--inst:ListenForEvent("stopfollowing", function(inst) inst.components.health:Kill() end)

	inst:SetBrain(brain)

	-- Component Init
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot(loot)

	inst.components.stunnable.stun_threshold = TUNING.DRAGONFLY_STUN
	inst.components.stunnable.stun_period = TUNING.DRAGONFLY_STUN_PERIOD
	inst.components.stunnable.stun_duration = TUNING.DRAGONFLY_STUN_DURATION
	inst.components.stunnable.stun_resist = TUNING.DRAGONFLY_STUN_RESIST
	inst.components.stunnable.stun_cooldown = TUNING.DRAGONFLY_STUN_COOLDOWN

	inst.components.health:SetMaxHealth(TUNING.DRAGONFLY_SLAVE_HEALTH + (TUNING.KOCHOSEI_CHECKWIFI * 2))
	inst.components.health.nofadeout = true -- Handled in death state instead
	inst.components.health.fire_damage_scale = 0 -- Take no damage from fire

	inst.components.groundpounder.numRings = 2
	inst.components.groundpounder.burner = true
	inst.components.groundpounder.groundpoundfx = "firesplash_fx"
	inst.components.groundpounder.groundpounddamagemult = 0.5
	inst.components.groundpounder.groundpoundringfx = "firering_fx"

	inst.components.combat:SetDefaultDamage(TUNING.DRAGONFLY_SLAVE_DAMAGE + TUNING.KOCHOSEI_CHECKWIFI)
	inst.components.combat:SetAttackPeriod(1)
		inst.components.combat:SetRange(TUNING.DRAGONFLY_ATTACK_RANGE, TUNING.DRAGONFLY_HIT_RANGE)
	inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
	inst.components.combat.battlecryenabled = false
	inst.components.combat.hiteffectsymbol = "dragonfly_body"
	inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/dragonfly/hurt")

	inst.components.inspectable:RecordViews()

	inst.components.locomotor:EnableGroundSpeedMultiplier(false)
	inst.components.locomotor:SetTriggersCreep(false)
	inst.components.locomotor.pathcaps = { ignorewalls = true, allowocean = true }
	inst.components.locomotor.walkspeed = TUNING.DRAGONFLY_SPEED

	inst:ListenForEvent("timerdone", OnTimerDone)
	inst:ListenForEvent("death", ondeath)
    inst.components.combat.onhitotherfn = OnHitOther
	inst.TransformFire = TransformFire
	inst.TransformNormal = TransformNormal
	inst.can_ground_pound = false
	inst.hit_recovery = TUNING.DRAGONFLY_HIT_RECOVERY

	MakeHugeFreezableCharacter(inst)
	inst.components.freezable:SetResistance(TUNING.DRAGONFLY_FREEZE_THRESHOLD)
	inst.components.freezable.damagetobreak = TUNING.DRAGONFLY_FREEZE_RESIST
	inst.components.freezable.diminishingreturns = true

	MakeLargePropagator(inst)
	inst.components.propagator.decayrate = 0

	return inst
end
STRINGS.NAMES.KOCHODRAGONFLY = "Dragonfly Skeleton"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHODRAGONFLY = "Dinh..."

return Prefab("kochodragonfly", fn, assets, prefabs)
