local assets = {
	Asset("ANIM", "anim/kochosei.zip"),
	Asset("ANIM", "anim/kochosei_snowmiku_skin1.zip"),
	Asset("SOUND", "sound/maxwell.fsb"),
}

local brain = require("brains/kochosei_enemy_brain_d")
local prefabs = { "shadow_despawn", "statue_transition_2" }

local RETARGET_MUST_TAGS = { "player", "_combat" }
local RETARGET_CANT_TAGS = {
	"DECOR",
	"eyeofterror",
	"FX",
	"INLIMBO",
	"NOCLICK",
	"notarget",
	"playerghost",
	"wall",
}
local function RetargetFn(inst)
	return FindEntity(inst, inst.range or TUNING.DECID_MONSTER_TARGET_DIST * 3.5, function(guy)
		return inst.components.combat:CanTarget(guy)
	end, RETARGET_MUST_TAGS, RETARGET_CANT_TAGS) or nil
end

local function KeepTargetFn(inst, target)
	return target ~= nil
		and not target.components.health:IsDead()
		and inst.components.combat:CanTarget(target)
		and inst:IsNear(target, 20)
end
local function IsList(item)
	return item.prefab == "ruinshat"
end
local function IsList2(item)
	return item.prefab == "blowdart_sleep"
end
local function IsList3(item)
	return item.prefab == "armorruins"
end
local function IsList4(item)
	return item.prefab == "ruins_bat"
end

local function OnAttacked(inst, data)
	if data.attacker ~= nil then
		if data.attacker.components.combat and data.attacker.userid ~= nil then
			inst.components.combat:SetTarget(data.attacker)
		end
		if data.attacker.components.combat and data.attacker:HasTag("epic") then
			inst.components.combat:SuggestTarget(data.attacker)
		end
	end
end

local function DoRipple(inst)
	if inst.components.drownable ~= nil and inst.components.drownable:IsOverWater() then
		SpawnPrefab("weregoose_ripple" .. tostring(math.random(2))).entity:SetParent(inst.entity)
	end
end
local function ondeath(inst)
	inst.components.inventory:DisableDropOnDeath()

	--inst.components.inventory:DropEverythingWithTag("weapon")
end

local function OnHitOther(inst, data)
	local target = data.target
	if target ~= nil then
		local sleeper = target.components.sleeper
		local grogginess = target.components.grogginess
		if sleeper ~= nil then
			sleeper:AddSleepiness(1, 10)
		elseif grogginess ~= nil then
			grogginess:AddGrogginess(1, 10)
		end

		local health = target.components.health
		if health and health:IsDead() then
			local coin2 = SpawnPrefab("blowdart_sleep")
			inst.components.inventory:GiveItem(coin2)
			local lists2 = inst.components.inventory:FindItems(IsList2)
			if lists2[1] then
				inst.components.inventory:Equip(lists2[1])
			end
			inst.sg:GoToState("chicken")
		end
	end
end

local function common()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
	inst.entity:AddNetwork()

	inst.Transform:SetFourFaced()
	MakeCharacterPhysics(inst, 1, 0.25)
	inst.AnimState:SetScale(0.8, 0.8)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	inst.Physics:ClearCollisionMask()
	inst.Physics:CollidesWith(COLLISION.GROUND)
	inst.Physics:CollidesWith(COLLISION.OBSTACLES)
	inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
	inst.Physics:CollidesWith(COLLISION.CHARACTERS)
	inst.Physics:CollidesWith(COLLISION.GIANTS)
	inst.Physics:Teleport(inst.Transform:GetWorldPosition())

	inst:AddComponent("inspectable")

	inst:AddComponent("locomotor")
	inst.components.locomotor.runspeed = 8
	inst.components.locomotor.pathcaps = { allowocean = true, ignorecreep = true }

	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(1000)
	inst.components.combat:SetRange(3)
	inst.components.combat:SetAttackPeriod(1)
	inst.components.combat:SetRetargetFunction(1, RetargetFn)
	inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

	inst.components.combat.externaldamagemultipliers:SetModifier(inst, 18, "kocho_enemy_damage_config") -- Damage multiplier (optional)

	inst:AddComponent("health")
	inst:AddComponent("named")
	inst.components.named:SetName("Kochosei Enemy")

	inst.components.health:SetMaxHealth(1000)

	inst:AddComponent("knownlocations")

	inst:AddComponent("inventory")
	inst.components.inventory:DisableDropOnDeath()

	local coin = SpawnPrefab("ruinshat")
	local coin2 = SpawnPrefab("blowdart_sleep")
	local coin3 = SpawnPrefab("armorruins")

	local items = { coin, coin2, coin3 }
	for _, item in ipairs(items) do
		if item then
			inst.components.inventory:GiveItem(item)
			if IsList(item) or IsList2(item) or IsList3(item) then
				inst.components.inventory:Equip(item)
			end
		end
	end

	inst:SetBrain(brain)
	inst:SetStateGraph("SGkochosei_enemy")

	inst:DoPeriodicTask(0.2, DoRipple, FRAMES)
	inst:ListenForEvent("death", ondeath)
	inst:ListenForEvent("attacked", OnAttacked)
	inst:ListenForEvent("onhitother", OnHitOther)
	return inst
end

local function canhit(inst, owner, target)
	return target
		and target:IsValid()
		and target.components.combat
		and target.components.health
		and target ~= owner
		and not target:HasTag("tadalin")
		and (target:HasTag("player") or target.components.combat.target == owner)
end

local function onthrown(inst)
	local speed = inst.components.ly_projectile.speed

	if speed > 15 then
		inst.AnimState:PlayAnimation("run_loop")
		inst.AnimState:PushAnimation("run_loop", true)
	else
		inst.AnimState:PlayAnimation("run_loop")
		inst.AnimState:PushAnimation("run_loop", true)
	end

	inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/attack")
end

local function onhit(inst, owner, target)
	inst.components.health:Kill()

	local fx = SpawnPrefab("impact")
	fx.Transform:SetPosition(inst:GetPosition():Get())
	--fx:FacePoint(owner.Transform:GetWorldPosition())
end

local function onmiss(inst)
	inst.components.health:Kill()
end

local function fnd()
	local inst = common()
	inst.AnimState:SetBank("wilson")
	inst.AnimState:SetBuild("kochosei")
	inst.AnimState:PlayAnimation("idle")

	return inst
end

local function fn_shadow()
	local inst = common()
	inst.AnimState:SetBank("wilson")
	inst.AnimState:SetBuild("kochosei")
	inst.AnimState:PlayAnimation("idle")

	inst:AddComponent("ly_projectile")
	inst.components.ly_projectile.damage = 20
	inst.components.ly_projectile:SetRange(math.ra + ndom() * 10 + 20)
	inst.components.ly_projectile:SetSpeed(15)
	inst.components.ly_projectile:SetCanHit(canhit)
	inst.components.ly_projectile:SetOnThrownFn(onthrown)
	inst.components.ly_projectile:SetOnHitFn(onhit)
	inst.components.ly_projectile:SetOnMissFn(onmiss)

	return inst
end

local function fnc()
	local inst = common()
	inst.AnimState:SetBank("wilson")
	inst.AnimState:SetBuild("kochosei_snowmiku_skin1")
	inst.AnimState:PlayAnimation("idle")
	return inst
end

return Prefab("kochosei_enemy_d", fnd, assets, prefabs), Prefab("kochosei_enemy_c", fnc, assets, prefabs)
