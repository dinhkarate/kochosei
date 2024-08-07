local assets = {
	Asset("ANIM", "anim/kochosei_armor_2.zip"),
	Asset("ANIM", "anim/kochosei_armor_1.zip"),
	
}


local hatMappings = {
	kochosei_armor_2 = "kochosei_armor_2",
}

local function OnEquip(inst, owner)

end

local function OnUnequip(inst, owner)
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
	if type(TUNING.KOCHO_HAT1_DURABILITY) == "number" then
		inst.components.armor:InitCondition(
			TUNING.KOCHO_HAT1_DURABILITY + (TUNING.KOCHOSEI_CHECKWIFI * 2),
			TUNING.KOCHO_HAT1_ABSORPTION
		)
	else
		inst.components.armor:InitIndestructible(TUNING.KOCHO_HAT1_ABSORPTION)
		inst.components.armor.condition = 999
	end
	inst:AddComponent("cuocdoiquabatcongdi")
	inst.components.cuocdoiquabatcongdi:Hatitem()

	inst:AddComponent("tradable")

	inst:AddComponent("inventoryitem")

	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
	inst.components.equippable:SetOnEquip(OnEquip)
	inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.equippable.dapperness = 0.15

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
local function kochosei_armor_2()
	local inst = commonfn()
	inst.AnimState:SetBank("kochosei_armor_2")
	inst.AnimState:SetBuild("kochosei_armor_2")
	return inst
end

return Prefab("kochosei_armor_2", kochosei_armor_2, assets),
	Prefab("kochosei_armor_1", kochosei_armor_1, assets)
