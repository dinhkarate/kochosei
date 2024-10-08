local assets = {
	Asset("ANIM", "anim/kochosei_armor_2.zip"),
	Asset("ANIM", "anim/kochosei_armor_1.zip"),
}

local prefabs = {}

local SHIELD_DURATION = 10 * FRAMES
local SHIELD_VARIATIONS = 3
local MAIN_SHIELD_CD = 1.2

local RESISTANCES = {
	"_combat",
	"explosive",
	"quakedebris",
	"lunarhaildebris",
	"caveindebris",
	"trapdamage",
}

for j = 0, 3, 3 do
	for i = 1, SHIELD_VARIATIONS do
		table.insert(prefabs, "shadow_shield" .. tostring(j + i))
	end
end

local function PickShield(inst)
	local t = GetTime()
	local flipoffset = math.random() < 0.5 and SHIELD_VARIATIONS or 0

	-- variation 3 is the main shield
	local dt = t - inst.lastmainshield
	if dt >= MAIN_SHIELD_CD then
		inst.lastmainshield = t
		return flipoffset + 3
	end

	local rnd = math.random()
	if rnd < dt / MAIN_SHIELD_CD then
		inst.lastmainshield = t
		return flipoffset + 3
	end

	return flipoffset + (rnd < dt / (MAIN_SHIELD_CD * 2) + 0.5 and 2 or 1)
end

local function OnShieldOver(inst, OnResistDamage)
	inst.task = nil
	for i, v in ipairs(RESISTANCES) do
		inst.components.resistance:RemoveResistance(v)
	end
	inst.components.resistance:SetOnResistDamageFn(OnResistDamage)
end

local function OnResistDamage(inst) -- , damage)
	local owner = inst.components.inventoryitem:GetGrandOwner() or inst
	local fx = SpawnPrefab("shadow_shield" .. tostring(PickShield(inst)))
	fx.entity:SetParent(owner.entity)

	if inst.task ~= nil then
		inst.task:Cancel()
	end
	inst.task = inst:DoTaskInTime(SHIELD_DURATION, OnShieldOver, OnResistDamage)
	inst.components.resistance:SetOnResistDamageFn(nil)
	if inst.components.cooldown.onchargedfn ~= nil then
		inst.components.cooldown:StartCharging()
	end
end

local function ShouldResistFn(inst)
	if not inst.components.equippable:IsEquipped() then
		return false
	end
	local owner = inst.components.inventoryitem.owner
	return owner ~= nil
		and not (owner.components.inventory ~= nil and owner.components.inventory:EquipHasTag("forcefield"))
end

local function OnChargedFn(inst)
	if inst.task ~= nil then
		inst.task:Cancel()
		inst.task = nil
		inst.components.resistance:SetOnResistDamageFn(OnResistDamage)
	end
	for i, v in ipairs(RESISTANCES) do
		inst.components.resistance:AddResistance(v)
	end
end

local function OnEquip(inst, owner)
	owner.tangst = true
	inst.lastmainshield = 0
	inst.components.cooldown.onchargedfn = OnChargedFn
	inst.components.cooldown:StartCharging(
		math.max(TUNING.ARMOR_SKELETON_FIRST_COOLDOWN, inst.components.cooldown:GetTimeToCharged())
	)
end

local function onequiptomodel(inst, owner, from_ground)
	inst.components.cooldown.onchargedfn = nil

	if inst.task ~= nil then
		inst.task:Cancel()
		inst.task = nil
		inst.components.resistance:SetOnResistDamageFn(OnResistDamage)
	end

	for i, v in ipairs(RESISTANCES) do
		inst.components.resistance:RemoveResistance(v)
	end
end

local function OnUnequip(inst, owner)
	inst.components.cooldown.onchargedfn = nil
	if inst.task ~= nil then
		inst.task:Cancel()
		inst.task = nil
		inst.components.resistance:SetOnResistDamageFn(OnResistDamage)
	end
	for i, v in ipairs(RESISTANCES) do
		inst.components.resistance:RemoveResistance(v)
	end
	owner.tangst = false
end

local function commonfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)
	inst.AnimState:PlayAnimation("anim")
	inst:AddTag("waterproofer")
	inst:AddTag("kochosei_hat")
	inst:AddTag("bramble_resistant")

	MakeInventoryFloatable(inst, "small", 0.1, 1.12)
	inst:AddTag("bramble_resistant")
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	inst:AddTag("bramble_resistant")
	inst:AddComponent("inspectable")

	inst:AddComponent("armor")

	inst.components.armor:InitIndestructible(TUNING.KOCHO_HAT1_ABSORPTION)
	inst.components.armor.condition = 100

	inst:AddComponent("tradable")

	inst:AddComponent("inventoryitem")

	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
	inst.components.equippable:SetOnEquip(OnEquip)
	inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.equippable:SetOnEquipToModel(onequiptomodel)
	inst.components.equippable.dapperness = 0.15

	inst:AddComponent("resistance")
	inst.components.resistance:SetShouldResistFn(ShouldResistFn)
	inst.components.resistance:SetOnResistDamageFn(OnResistDamage)

	inst:AddComponent("cooldown")
	inst.components.cooldown.cooldown_duration = TUNING.ARMOR_SKELETON_COOLDOWN

	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(0.3)

	MakeHauntableLaunch(inst)

	return inst
end
local function kochosei_armor_1()
	local inst = commonfn()
	inst.AnimState:SetBank("kochosei_armor_1")
	inst.AnimState:SetBuild("kochosei_armor_1")
	return inst
end

if TUNING.KOCHOSEI_CHECKMOD ~= 1 and Kochoseiapi.MakeItemSkin ~= nil then
	Kochoseiapi.MakeItemSkin("kochosei_armor_1", "kochosei_armor_2", {
		name = "Áo giáp của lông xanh",
		atlas = "images/inventoryimages/kochosei_inv.xml",
		image = "kochosei_armor_2",
		build = "kochosei_armor_2",
		bank = "kochosei_armor_2",
		basebuild = "kochosei_armor_1",
		basebank = "kochosei_armor_1",
	})
end

STRINGS.NAMES.KOCHOSEI_ARMOR_1 = "Giáp của ai đó"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_ARMOR_1 = "10$ cho bộ giáp này, bạn nghĩ nó đắt hay rẻ?" -- Rẻ
STRINGS.RECIPE_DESC.KOCHOSEI_ARMOR_1 =
	"Ai đó đã bỏ cả tháng lương của mình để thuê họa sĩ ngoài vẽ, chỉ vì con cò nào đó lười biếng"

return Prefab("kochosei_armor_1", kochosei_armor_1, assets, prefabs)
