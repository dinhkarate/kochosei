local kochosei_thiensu_assets = {
	Asset("ANIM", "anim/swap_thiensu_xanh.zip"),
	Asset("ANIM", "anim/thiensu_xanh.zip"),
	Asset("ANIM", "anim/swap_thiensu_hong.zip"),
	Asset("ANIM", "anim/thiensu_hong.zip"),
	Asset("ANIM", "anim/swap_thiensu_cam.zip"),
	Asset("ANIM", "anim/thiensu_cam.zip"),
	Asset("ANIM", "anim/doro_xamchiemtraidat.zip"),
	Asset("ANIM", "anim/swap_doro_xamchiemtraidat.zip"),
}

local function onequip(inst, owner)
	if inst.prefab == "kochosei_thien_su_ban_phuc_xanh" then
		owner.AnimState:OverrideSymbol("swap_object", "swap_thiensu_xanh", "swap_thiensu_xanh")
	elseif inst.prefab == "kochosei_thien_su_ban_phuc_hong" then
		owner.AnimState:OverrideSymbol("swap_object", "swap_thiensu_hong", "swap_thiensu_hong")
	elseif inst.prefab == "kochosei_thien_su_ban_phuc_cam" then
		owner.AnimState:OverrideSymbol("swap_object", "swap_thiensu_cam", "swap_thiensu_cam")
	else
		owner.AnimState:OverrideSymbol("swap_object", "swap_doro_xamchiemtraidat", "swap_doro_xamchiemtraidat")
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
local TARGET_DIST = 16
local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "prey", "smallcreature", "INLIMBO" }
local function RetargetFn(inst)
	local range = inst:GetPhysicsRadius(0) + 8
	return FindEntity(inst, TARGET_DIST, function(guy)
		return inst.components.combat:CanTarget(guy)
			and (guy.components.combat:TargetIs(inst) or guy:IsNear(inst, range))
	end, RETARGET_MUST_TAGS, RETARGET_CANT_TAGS)
end

local function thiensu_hong(inst)
	SpawnPrefab("sporecloud").Transform:SetPosition(inst.Transform:GetWorldPosition())
	local dungnham = SpawnPrefab("lavae")
	dungnham.Transform:SetPosition(inst.Transform:GetWorldPosition())
	dungnham.components.combat:SetRetargetFunction(1, RetargetFn)
end
local function thiensu_cam(inst)
	SpawnPrefab("explode_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.components.explosive:OnBurnt()
end

local function doro_xamchiemtraidat(inst, attacker, target, pos)
	inst:AddTag("NOCLICK")
	inst:AddTag("NOBLOCK")
	pos = pos or Vector3(inst.Transform:GetWorldPosition())
	local center = Vector3(pos.x, 0, pos.z) -- Tọa độ trung tâm, bạn có thể thay đổi tùy ý
	local spacing = 1.3 -- Khoảng cách giữa các farm_soil
	for i = -1, 1 do
		for j = -1, 1 do
			local x = center.x + i * spacing
			local z = center.z + j * spacing
		--	if TheWorld.Map:CanTillSoilAtPoint(x, 0, z, true) then -- true để bỏ qua mọi địa hình
				-- Dọn sạch đất cũ nếu có
				TheWorld.Map:CollapseSoilAtPoint(x, 0, z)
				-- Tạo farm_soil mới tại vị trí
				SpawnPrefab("farm_soil").Transform:SetPosition(x, 0, z)
		--	end
		end
	end
	attacker.components.talker:Say("Điên à, ném ra đất làm gì?")
end


local function OnHitWater(inst, attacker, target, pos)
	if inst.prefab == "kochosei_thien_su_ban_phuc_xanh" then
		thiensu_xanh(inst)
	elseif inst.prefab == "kochosei_thien_su_ban_phuc_hong" then
		thiensu_hong(inst)
	elseif inst.prefab == "kochosei_thiensu_ban_phuc_cam" then
		thiensu_cam(inst)
	elseif inst.prefab == "doro_xamchiemtraidat" then
		doro_xamchiemtraidat(inst, attacker, target, pos)
	end
	inst:Remove()
end

local function common_fn(bank, build)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)
	inst:AddTag("weapon")

	--projectile (from complexprojectile component) added to pristine state for optimization
	inst:AddTag("projectile")
	-- From watersource component
	inst:AddTag("watersource")

	inst.AnimState:SetBank(bank)
	inst.AnimState:SetBuild(build)
	--inst.AnimState:SetScale(0.8, 0.8)

	inst.AnimState:PlayAnimation("idle", true)

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
	inst.components.weapon:SetRange(8, 14)

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
	local inst = common_fn("thiensu_xanh", "thiensu_xanh")
	return inst
end
local function thiensu_hong_fn()
	local inst = common_fn("thiensu_hong", "thiensu_hong")
	return inst
end
local function thiensu_camfn()
	local inst = common_fn("thiensu_cam", "thiensu_cam")
	if not TheWorld.ismastersim then
		return inst
	end
	inst:AddComponent("explosive")
	return inst
end
local function doro_xamchiemtraidat_fn()
	local inst = common_fn("doro_xamchiemtraidat", "doro_xamchiemtraidat")
	return inst
end

STRINGS.NAMES.KOCHOSEI_THIEN_SU_BAN_PHUC_XANH = "Thiên Sứ Ban Phúc"
STRINGS.NAMES.KOCHOSEI_THIEN_SU_BAN_PHUC_HONG = "Thiên Sứ Ban Lộc"
STRINGS.NAMES.KOCHOSEI_THIEN_SU_BAN_PHUC_CAM = "Thiên Sứ Ban Lửa"
STRINGS.NAMES.DORO_XAMCHIEMTRAIDAT = "Doro Xâm Chiếm Trái Đất"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_THIEN_SU_BAN_PHUC_XANH = "Hàng nhái kém chất lượng"
STRINGS.RECIPE_DESC.KOCHOSEI_THIEN_SU_BAN_PHUC_XANH =
	"Không phải chúng ta đã thề sẽ quét sạch mod và đám author ra khỏi dst sao?"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_THIEN_SU_BAN_PHUC_HONG = "Hàng nhái kém chất lượng"
STRINGS.RECIPE_DESC.KOCHOSEI_THIEN_SU_BAN_PHUC_HONG =
	"Không phải chúng ta đã thề sẽ quét sạch mod và đám author ra khỏi dst sao?"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_THIEN_SU_BAN_PHUC_CAM = "Hàng nhái kém chất lượng"
STRINGS.RECIPE_DESC.KOCHOSEI_THIEN_SU_BAN_PHUC_CAM =
	"Không phải chúng ta đã thề sẽ quét sạch mod và đám author ra khỏi dst sao?"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DORO_XAMCHIEMTRAIDAT = "Hàng nhái kém chất lượng"
STRINGS.RECIPE_DESC.DORO_XAMCHIEMTRAIDAT =
	"Chế xong rồi ném ra đất?"

return Prefab("kochosei_thien_su_ban_phuc_xanh", thiensu_xanh_fn, kochosei_thiensu_assets),
	Prefab("kochosei_thien_su_ban_phuc_hong", thiensu_hong_fn, kochosei_thiensu_assets),
	Prefab("kochosei_thien_su_ban_phuc_cam", thiensu_camfn, kochosei_thiensu_assets),
	Prefab("doro_xamchiemtraidat", doro_xamchiemtraidat_fn, kochosei_thiensu_assets)
