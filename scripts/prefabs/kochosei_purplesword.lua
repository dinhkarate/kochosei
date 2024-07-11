local assets = {
	Asset("ANIM", "anim/kocho_purplesword.zip"),
	Asset("ANIM", "anim/swap_kocho_purplesword.zip"),
}

local function OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_kocho_purplesword", "swap_purplesword")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)
	MakeHauntableLaunch(inst)

	inst.AnimState:SetBank("kocho_purplesword")
	inst.AnimState:SetBuild("kocho_purplesword")
	inst.AnimState:PlayAnimation("anim")

	inst:AddTag("kochoseiweapon")
	inst:AddTag("purplesword")
	
	if not TheWorld.ismastersim then
		return inst
	end
	inst:AddTag("kochoseiweapon")
	
	inst.entity:SetPristine()

	inst:AddComponent("tool")
	inst.components.tool:SetAction(ACTIONS.CHOP, 4)

	if type(TUNING.KOCHO_SWORD_DURABILITY) == "number" then
		inst:AddComponent("finiteuses")
		inst.components.finiteuses:SetMaxUses(TUNING.KOCHO_SWORD_DURABILITY)
		inst.components.finiteuses:SetUses(TUNING.KOCHO_SWORD_DURABILITY)
		inst.components.finiteuses:SetOnFinished(inst.Remove)
	end
	
	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.KOCHO_SWORD_DAMAGE)

	inst:AddComponent("inspectable")
	inst:AddComponent("tradable")

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(OnEquip)
	inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.equippable.walkspeedmult = 1.25
	inst.components.equippable.dapperness = 0.033

	inst:AddComponent("inventoryitem")

	inst:AddComponent("cuocdoiquabatcongdi")
    inst.components.cuocdoiquabatcongdi:Vukhi()


	MakeHauntableLaunch(inst)

	return inst
end

STRINGS.NAMES.KOCHO_PURPLESWORD = "Kocho Purple Sword"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHO_PURPLESWORD = "I want this!! :D"
STRINGS.RECIPE_DESC.KOCHO_PURPLESWORD = "ヾ(•ω•`)o"

return Prefab("common/inventory/kocho_purplesword", fn, assets, prefabs)
