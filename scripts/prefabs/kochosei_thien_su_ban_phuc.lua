local waterballoon_assets = {
	Asset("ANIM", "anim/swap_thiensu_xanh.zip"),
	Asset("ANIM", "anim/thiensu_xanh.zip"),
	Asset("ANIM", "anim/swap_thiensu_hong.zip"),
	Asset("ANIM", "anim/swap_thiensu_cam.zip"),
}

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_thiensu_xanh", "swap_thiensu_xanh")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end

local function onthrown(inst)
	inst:AddTag("NOCLICK")
	inst.persists = false

	inst.AnimState:PlayAnimation("spin_loop", true)

	inst.Physics:SetMass(1)
	inst.Physics:SetCapsule(0.2, 0.2)
	inst.Physics:SetFriction(0)
	inst.Physics:SetDamping(0)
	inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
	inst.Physics:ClearCollisionMask()
	inst.Physics:CollidesWith(COLLISION.GROUND)
	inst.Physics:CollidesWith(COLLISION.OBSTACLES)
	inst.Physics:CollidesWith(COLLISION.ITEMS)
end

local function ReticuleTargetFn()
	local player = ThePlayer
	local ground = TheWorld.Map
	local pos = Vector3()
	--Attack range is 8, leave room for error
	--Min range was chosen to not hit yourself (2 is the hit range)
	for r = 6.5, 3.5, -0.25 do
		pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
		if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
			return pos
		end
	end
	return pos
end

local function onuseaswatersource(inst)
	if inst.components.stackable:IsStack() then
		inst.components.stackable:Get():Remove()
	else
		inst:Remove()
	end
end

local PI = math.pi
local Rn = 6
local Zn = 5

-- Precompute the points to avoid repeated calculations
local function GenerateCircularPoints()
	local hua = { Point() } -- Start with origin point

	for i = 2, Rn, 2 do
		local z = 2 * PI * i
		local jg = 2 + (z % 2) / (z / 2)

		for j = jg, z, jg do
			local hu = j / i
			local po = Vector3(math.cos(hu) * i, 0, math.sin(hu) * i)
			table.insert(hua, po)
		end
	end

	return hua
end

-- Precompute points to avoid regenerating each time
local PRE_COMPUTED_POINTS = GenerateCircularPoints()

local function OnHitWater(inst, attacker, target, pos)
	-- Use inst's position if no pos provided
	pos = pos or Vector3(inst.Transform:GetWorldPosition())

	-- Spawn water splash effect
	SpawnPrefab("waterballoon_splash").Transform:SetPosition(inst.Transform:GetWorldPosition())

	-- Spread water protection
	inst.components.wateryprotection:SpreadProtection(inst)
	inst:Remove()

	-- Create effect entity
	local xu = CreateEntity()
	xu.entity:AddTransform()
	xu.Transform:SetPosition(pos.x, 0, pos.z)

	-- Optimize effect spawning
	for _, v in ipairs(PRE_COMPUTED_POINTS) do
		xu:DoTaskInTime(math.random() * 0.2, function()
			local fx = SpawnPrefab("lavaarena_bloom_kocho" .. math.random(6))
			local final_position = pos + v
			fx.Transform:SetPosition(final_position:Get())
			fx:chixu(Zn + math.random())
		end)
	end
end

local function common_fn(bank, build, anim, tag, isinventoryitem)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	if isinventoryitem then
		MakeInventoryPhysics(inst)
	else
		inst.entity:AddPhysics()
		inst.Physics:SetMass(1)
		inst.Physics:SetFriction(0)
		inst.Physics:SetDamping(0)
		inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
		inst.Physics:ClearCollisionMask()
		inst.Physics:CollidesWith(COLLISION.GROUND)
		inst.Physics:SetCapsule(0.2, 0.2)
		inst.Physics:SetDontRemoveOnSleep(true) -- so the object can land and put out the fire, also an optimization due to how this moves through the world
	end

	if tag ~= nil then
		inst:AddTag(tag)
	end

	--projectile (from complexprojectile component) added to pristine state for optimization
	inst:AddTag("projectile")

	inst.AnimState:SetBank(bank)
	inst.AnimState:SetBuild(build)

	if type(anim) ~= "table" then
		inst.AnimState:PlayAnimation(anim, true)
	elseif #anim == 1 then
		inst.AnimState:PlayAnimation(anim[1], true)
	else
		for i, a in ipairs(anim) do
			if i == 1 then
				inst.AnimState:PlayAnimation(a, false)
			elseif i ~= #anim then
				inst.AnimState:PushAnimation(a, false)
			else
				inst.AnimState:PushAnimation(a, true)
			end
		end
	end

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("locomotor")

	inst:AddComponent("wateryprotection")

	inst:AddComponent("complexprojectile")

	return inst
end

local function waterballoon_fn()
	--weapon (from weapon component) added to pristine state for optimization
	local inst = common_fn("thiensu_xanh", "thiensu_xanh", "idle", "weapon", true)

	inst:AddComponent("reticule")
	inst.components.reticule.targetfn = ReticuleTargetFn
	inst.components.reticule.ease = true

	MakeInventoryFloatable(inst, "med", 0.05, 0.65)

	-- From watersource component
	inst:AddTag("watersource")

	if not TheWorld.ismastersim then
		return inst
	end

	inst.components.complexprojectile:SetHorizontalSpeed(15)
	inst.components.complexprojectile:SetGravity(-35)
	inst.components.complexprojectile:SetLaunchOffset(Vector3(0.25, 1, 0))
	inst.components.complexprojectile:SetOnLaunch(onthrown)
	inst.components.complexprojectile:SetOnHit(OnHitWater)

	inst.components.wateryprotection.extinguishheatpercent = TUNING.WATERBALLOON_EXTINGUISH_HEAT_PERCENT
	inst.components.wateryprotection.temperaturereduction = TUNING.WATERBALLOON_TEMP_REDUCTION
	inst.components.wateryprotection.witherprotectiontime = TUNING.WATERBALLOON_PROTECTION_TIME
	inst.components.wateryprotection.addwetness = TUNING.WATERBALLOON_ADD_WETNESS

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(0)
	inst.components.weapon:SetRange(8, 10)

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")

	inst:AddComponent("stackable")

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.equipstack = true

	inst:AddComponent("watersource")
	inst.components.watersource.onusefn = onuseaswatersource
	inst.components.watersource.override_fill_uses = 1

	MakeHauntableLaunch(inst)

	return inst
end
return Prefab("kochosei_thien_su_ban_phuc_xanh", waterballoon_fn, waterballoon_assets)
