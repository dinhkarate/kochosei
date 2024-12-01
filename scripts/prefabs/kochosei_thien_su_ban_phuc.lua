local kochosei_thiensu_assets = {
	Asset("ANIM", "anim/swap_thiensu_xanh.zip"),
	Asset("ANIM", "anim/thiensu_xanh.zip"),
	Asset("ANIM", "anim/swap_thiensu_hong.zip"),
	Asset("ANIM", "anim/thiensu_hong.zip"),
	Asset("ANIM", "anim/swap_thiensu_cam.zip"),
	Asset("ANIM", "anim/thiensu_cam.zip"),
}

local function onequip(inst, owner)
	if inst.prefab == "kochosei_thien_su_ban_phuc_xanh" then
		owner.AnimState:OverrideSymbol("swap_object", "swap_thiensu_xanh", "swap_thiensu_xanh")
	elseif inst.prefab == "kochosei_thien_su_ban_phuc_hong" then
		owner.AnimState:OverrideSymbol("swap_object", "swap_thiensu_hong", "swap_thiensu_hong")
	else
		owner.AnimState:OverrideSymbol("swap_object", "swap_thiensu_cam", "swap_thiensu_cam")
	end

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
local Rn = 6 -- Phạm vi của khu vực hồi máu
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

local hstrongtay = STRINGS.NAMES.LYDOHOISINH_THIENSU

local function thiensu_xanh(inst, pos)
	-- Use inst's position if no pos provided
	pos = pos or Vector3(inst.Transform:GetWorldPosition())

	-- Spawn water splash effect
	SpawnPrefab("waterballoon_splash").Transform:SetPosition(inst.Transform:GetWorldPosition())

	-- Spread water protection
	inst.components.wateryprotection:SpreadProtection(inst)
	local playersheal = FindPlayersInRange(pos.x, pos.y, pos.z, Rn)
	for _, v in ipairs(playersheal) do
		if v.components.health:IsDead() or v:HasTag("playerghost") then
			v:PushEvent("respawnfromghost")
			v.rezsource = hstrongtay
		end
		v:AddDebuff("kocho_buff_heal", "kocho_buff_heal")
	end
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

local function thiensu_hong(inst)
	SpawnPrefab("sporecloud").Transform:SetPosition(inst.Transform:GetWorldPosition())
end
local function thiensu_cam(inst)
	SpawnPrefab("explode_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.components.explosive:OnBurnt()
end

local function OnHitWater(inst, attacker, target, pos)
	if inst.prefab == "kochosei_thien_su_ban_phuc_xanh" then
		thiensu_xanh(inst)
	elseif inst.prefab == "kochosei_thien_su_ban_phuc_hong" then
		thiensu_hong(inst)
	else
		thiensu_cam(inst)
	end
	inst:Remove()

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
	-- From watersource component
	inst:AddTag("watersource")

	inst.AnimState:SetBank(bank)
	inst.AnimState:SetBuild(build)
	--inst.AnimState:SetScale(0.8, 0.8)

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

	inst:AddComponent("reticule")
	inst.components.reticule.targetfn = ReticuleTargetFn
	inst.components.reticule.ease = true

	MakeInventoryFloatable(inst, "med", 0.05, 0.65)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("locomotor")

	inst:AddComponent("wateryprotection")

	inst:AddComponent("complexprojectile")
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
	inst.components.weapon:SetRange(12, 12)

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")

	inst:AddComponent("stackable")

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.equipstack = true

	inst:AddComponent("watersource")
	inst.components.watersource.onusefn = onuseaswatersource
	inst.components.watersource.override_fill_uses = 10

	MakeHauntableLaunch(inst)
	return inst
end

local function thiensu_xanh_fn()
	local inst = common_fn("thiensu_xanh", "thiensu_xanh", "idle", "weapon", true)
	return inst
end
local function thiensu_hong_fn()
	local inst = common_fn("thiensu_hong", "thiensu_hong", "idle", "weapon", true)
	return inst
end
local function thiensu_camfn()
	local inst = common_fn("thiensu_cam", "thiensu_cam", "idle", "weapon", true)
	inst:AddComponent("explosive")
	return inst
end

STRINGS.NAMES.KOCHOSEI_THIEN_SU_BAN_PHUC_XANH = "Thiên Sứ Ban Phúc"
STRINGS.NAMES.KOCHOSEI_THIEN_SU_BAN_PHUC_HONG = "Thiên Sứ Ban Lộc"
STRINGS.NAMES.KOCHOSEI_THIEN_SU_BAN_PHUC_CAM = "Thiên Sứ Ban Lửa"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOTAMBOURIN = "I want this!! :D"
STRINGS.RECIPE_DESC.KOCHOTAMBOURIN = "Healing teammate"

return Prefab("kochosei_thien_su_ban_phuc_xanh", thiensu_xanh_fn, kochosei_thiensu_assets),
	Prefab("kochosei_thien_su_ban_phuc_hong", thiensu_hong_fn, kochosei_thiensu_assets),
	Prefab("kochosei_thien_su_ban_phuc_cam", thiensu_camfn, kochosei_thiensu_assets)
