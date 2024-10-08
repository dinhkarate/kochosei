local assets = {
	Asset("ANIM", "anim/tornado.zip"),
	Asset("ANIM", "anim/tornado_stick.zip"),
	Asset("ANIM", "anim/swap_tornado_stick.zip"),
}

local brain = require("brains/kochoseitornadobrain")

local function ontornadolifetime(inst)
	inst.task = nil
	inst.sg:GoToState("despawn")
end

local function SetDuration(inst, duration)
	if inst.task ~= nil then
		inst.task:Cancel()
	end
	inst.task = inst:DoTaskInTime(duration, ontornadolifetime)
end

local function RetargetFn(inst)
	local player, distsq = inst:GetNearestPlayer()
	return (player and not player.components.health:IsDead()) and player
		or FindEntity(inst, 25, function(guy)
			return inst.components.combat:CanTarget(guy) and not guy.components.health:IsDead()
		end, nil, { "tadalin", "LA_mob", "battlestandard", "monster" })
end

local function KeepTargetFn(inst, target)
	return inst.components.combat:CanTarget(target)
end

local function tornado_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.AnimState:SetFinalOffset(2)
	inst.AnimState:SetBank("tornado")
	inst.AnimState:SetBuild("tornado")
	inst.AnimState:PlayAnimation("tornado_pre")
	inst.AnimState:PushAnimation("tornado_loop")

	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tornado", "spinLoop")

	MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("knownlocations")

	inst:AddComponent("combat")
	inst.components.combat:SetRange(20)
	inst.components.combat:SetAttackPeriod(0.33)
	inst.components.combat:SetRetargetFunction(1, RetargetFn)
	inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = TUNING.TORNADO_WALK_SPEED * 0.33
	inst.components.locomotor.runspeed = TUNING.TORNADO_WALK_SPEED

	inst:SetStateGraph("SGkochosei_tornado")
	inst:SetBrain(brain)

	inst.WINDSTAFF_CASTER = nil
	inst.persists = false

	inst.SetDuration = SetDuration
	inst:SetDuration(TUNING.TORNADO_LIFETIME)

	inst:DoTaskInTime(0, function()
		inst.components.knownlocations:RememberLocation("spawnpos")
	end)

	return inst
end

return Prefab("kochosei_tornado", tornado_fn, assets)
