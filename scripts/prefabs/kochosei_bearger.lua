local assets = {
	Asset("ANIM", "anim/bearger_build.zip"),
	Asset("ANIM", "anim/bearger_basic.zip"),
	Asset("ANIM", "anim/bearger_actions.zip"),
	Asset("ANIM", "anim/bearger_yule.zip"),
	Asset("SOUND", "sound/bearger.fsb"),
}

local prefabs = {
	"groundpound_fx",
	"groundpoundring_fx",
	"bearger_fur",
	"furtuft",
	"meat",
	"chesspiece_bearger_sketch",
	"collapse_small",
}

local brain = require("brains/kochobeargerbrain")
local RETARGET_MUST_TAGS = { "monster" }
local RETARGET_CANT_TAGS = {
	"prey",
	"smallcreature",
	"INLIMBO",
	"player",
	"structure",
	"kochoseipet",
}
local TARGET_DIST = 16
local function RetargetFn(inst)
	local range = inst:GetPhysicsRadius(0) + 8
	return FindEntity(inst, TARGET_DIST, function(guy)
		return inst.components.combat:CanTarget(guy)
			and (guy.components.combat:TargetIs(inst) or guy:IsNear(inst, range))
	end, RETARGET_MUST_TAGS, RETARGET_CANT_TAGS)
end

local function KeepTargetFn(inst, target)
	return inst.components.combat:CanTarget(target)
end

local function OnAttacked(inst, data)
	if data.attacker ~= nil then
	if data.attacker:HasTag("kochoseipet") then return end
		if data.attacker.components.petleash ~= nil and data.attacker.components.petleash:IsPet(inst) then
			inst.components.health:Kill()
		elseif data.attacker.components.combat ~= nil then
			inst.components.combat:SuggestTarget(data.attacker)
		end
	end
end

local WORKABLES_CANT_TAGS = { "insect", "INLIMBO" }
local WORKABLES_ONEOF_TAGS = {
	"CHOP_workable",
	"DIG_workable",
	"HAMMER_workable",
	"MINE_workable",
}
local function WorkEntities(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local heading_angle = inst.Transform:GetRotation() * DEGREES
	local x1, z1 = math.cos(heading_angle), -math.sin(heading_angle)
	for i, v in ipairs(TheSim:FindEntities(x, 0, z, 5, nil, WORKABLES_CANT_TAGS, WORKABLES_ONEOF_TAGS)) do
		local x2, y2, z2 = v.Transform:GetWorldPosition()
		local dx, dz = x2 - x, z2 - z
		local len = math.sqrt(dx * dx + dz * dz)
		-- Normalized, then Dot product
		if len <= 0 or x1 * dx / len + z1 * dz / len > 0.3 then
			v.components.workable:Destroy(inst)
		end
	end
end

local function ontimerdone(inst, data)
	if data.name == "GroundPound" then
		inst.cangroundpound = true
	elseif data.name == "Yawn" and inst:HasTag("hibernation") then
		inst.canyawn = true
	end
end

local function SetStandState(inst, state)
	-- "quad" or "bi" state
	inst.StandState = string.lower(state)
end

local function IsStandState(inst, state)
	return inst.StandState == string.lower(state)
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
	inst.entity:AddNetwork()

	inst.Transform:SetFourFaced()
	inst.DynamicShadow:SetSize(6, 3.5)

	MakeGiantCharacterPhysics(inst, 1000, 1.5)

	inst.AnimState:SetBank("bearger")
	inst.AnimState:SetBuild(IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "bearger_yule" or "bearger_build")
	inst.AnimState:PlayAnimation("idle_loop", true)
	inst.AnimState:SetScale(0.6, 0.6)

	-- inst:AddTag("hostile")
	inst:AddTag("bearger")
	inst:AddTag("scarytoprey")
	inst:AddTag("largecreature")
	inst:AddTag("kochoseipet")
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.recentlycharged = {}

	------------------------------------------
	------------------

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.BEARGER_SLAVE_HEALTH + TUNING.KOCHOSEI_CHECKWIFI)
	inst.components.health.destroytime = 5

	------------------

	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(TUNING.BEARGER_SLAVE_DAMAGE)
	inst.components.combat.playerdamagepercent = 0.5
	inst.components.combat:SetRange(TUNING.BEARGER_ATTACK_RANGE, TUNING.BEARGER_MELEE_RANGE)
	inst.components.combat:SetAreaDamage(6, 0.8)
	inst.components.combat.hiteffectsymbol = "bearger_body"
	inst.components.combat:SetAttackPeriod(TUNING.BEARGER_ATTACK_PERIOD - 3)
	inst.components.combat:SetRetargetFunction(3, RetargetFn)
	inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
	inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/bearger/hurt")

	------------------------------------------

	inst:AddComponent("explosiveresist")

	inst:AddComponent("inspectable")
	inst.components.inspectable:RecordViews()

	inst:AddComponent("groundpounder")
	inst.components.groundpounder.destroyer = true
	inst.components.groundpounder.damageRings = 2
	inst.components.groundpounder.destructionRings = 999
	inst.components.groundpounder.platformPushingRings = 0
	inst.components.groundpounder.numRings = 3
	inst.components.groundpounder.noTags = {
		"FX",
		"NOCLICK",
		"DECOR",
		"INLIMBO",
		"structure",
	}

	inst:AddComponent("timer")

	inst:ListenForEvent("timerdone", ontimerdone)

	------------------------------------------

	MakeLargeBurnableCharacter(inst, "swap_fire")
	MakeHugeFreezableCharacter(inst, "bearger_body")

	SetStandState(inst, "quad") -- SetStandState(inst, "BI")
	inst.SetStandState = SetStandState
	inst.IsStandState = IsStandState
	inst.seenbase = false
	inst.WorkEntities = WorkEntities
	inst.cangroundpound = false

	--  inst:DoTaskInTime(0, OnWakeUp)

	-- inst:ListenForEvent("newcombattarget", OnCombatTarget)
	-- inst:ListenForEvent("droppedtarget", OnDroppedTarget)

	------------------------------------------

	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = TUNING.BEARGER_CALM_WALK_SPEED
	inst.components.locomotor.runspeed = TUNING.BEARGER_RUN_SPEED
	inst.components.locomotor:SetShouldRun(true)

	inst:SetStateGraph("SGkochosei_bearger")
	inst:SetBrain(brain)

	inst:AddComponent("lootdropper")
	-- inst.components.lootdropper:SetChanceLootTable("kocho_bearger")
	inst.components.lootdropper:AddChanceLoot("bearger_fur", 1)

	inst:AddComponent("follower")

	inst.components.follower:KeepLeaderOnAttacked()
	inst.components.follower.keepdeadleader = true
	inst.components.follower.keepleaderduringminigame = true

	inst:DoPeriodicTask(1, onPeriodicTask)
	inst:DoPeriodicTask(1, m_checkLeaderExisting)
	inst:ListenForEvent("attacked", OnAttacked)
	inst.components.combat.onhitotherfn = OnHitOther

	-- inst:ListenForEvent("stopfollowing",                        function(inst) inst.components.health:Kill() end)

	return inst
end
STRINGS.NAMES.KOCHO_BEARGER = "Slave Bearger"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHO_BEARGER = "Dinh..."

return Prefab("kocho_bearger", fn, assets, prefabs)
