local assets = {
	Asset("ANIM", "anim/kochosei_hat1.zip"),
	Asset("ANIM", "anim/kochosei_hat2.zip"),
	Asset("ANIM", "anim/kochosei_hat3.zip"),
	Asset("ANIM", "anim/kochosei_hatfl.zip"),
	Asset("ANIM", "anim/ms_kochosei_hat2.zip"),
	Asset("ANIM", "anim/ms_kochosei_hat3.zip"),
	Asset("ANIM", "anim/kochosei_hatfl_skin.zip"),
	--   Asset("ANIM", "anim/kochosei_hatfl_skin_drop.zip")
}
--[[
local function Onequip(inst, owner)
    if inst.prefab == "kochosei_hat1" then
        owner.AnimState:OverrideSymbol("swap_hat", inst.skinname or "kochosei_hat1", "swap_hat")
    end
    if inst.prefab == "kochosei_hat2" then
        owner.AnimState:OverrideSymbol("swap_hat", inst.skinname or "kochosei_hat2", "swap_hat")
    end
    if inst.prefab == "kochosei_hat3" then
        owner.AnimState:OverrideSymbol("swap_hat", inst.skinname or "kochosei_hat3", "swap_hat")
    end
    if inst.prefab == "kochosei_hatfl" then
        owner.AnimState:OverrideSymbol("swap_hat", inst.skinname or "kochosei_hatfl", "swap_hat")
    end
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")
end
--]]

local hatMappings = {
	kochosei_hat1 = "kochosei_hat1",
	kochosei_hat2 = "kochosei_hat2",
	kochosei_hat3 = "kochosei_hat3",
	kochosei_hatfl = "kochosei_hatfl",
}

local function OnEquip(inst, owner)
	local hatName = hatMappings[inst.prefab]
	if hatName and not (inst.prefab == "kochosei_hat1" or inst.prefab == "kochosei_hat3") then -- T không còn muốn thấy những thứ này nữa
		owner.AnimState:OverrideSymbol("swap_hat", inst.skinname or hatName, "swap_hat")
	end

	if hatName == "kochosei_hatfl" and owner and owner.components.sanity then
		owner.components.sanity.neg_aura_absorb = TUNING.ARMOR_HIVEHAT_SANITY_ABSORPTION
		if owner.components.sanity.mode == SANITY_MODE_INSANITY then
			owner.components.sanity:EnableLunacy(true, "hatfl")
		end
		owner.tangst = true
	end

	owner.AnimState:Show("HAT")
	owner.AnimState:Show("HAIR_HAT")
end

local function OnUnequip(inst, owner)
	local hatName = hatMappings[inst.prefab]
	if hatName == "kochosei_hatfl" then
		if owner ~= nil and owner.components.sanity ~= nil then
			owner.components.sanity.neg_aura_absorb = 0
			if owner.components.sanity.mode == SANITY_MODE_LUNACY then
				owner.components.sanity:EnableLunacy(false, "hatfl")
			end
		end
	end
	owner.tangst = false
	owner.AnimState:ClearOverrideSymbol("swap_hat")
	owner.AnimState:Hide("HAT")
	owner.AnimState:Hide("HAIR_HAT")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR")
end

local function commonfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()

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
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable:SetOnEquip(OnEquip)
	inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.equippable.dapperness = 0.15

	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(0.3)

	MakeHauntableLaunch(inst)

	return inst
end

local function kochosei_hat1()
	local inst = commonfn()
	inst.AnimState:SetBank("kochosei_hat1")
	inst.AnimState:SetBuild("kochosei_hat1")
	return inst
end

local function kochosei_hat2()
	local inst = commonfn()
	inst.AnimState:SetBank("kochosei_hat2")
	inst.AnimState:SetBuild("kochosei_hat2")
	return inst
end

local function kochosei_hat3()
	local inst = commonfn()
	inst.AnimState:SetBank("kochosei_hat3")
	inst.AnimState:SetBuild("kochosei_hat3")
	return inst
end

local function kochosei_hatfl()
	local inst = commonfn()
	inst:AddTag("gestaltprotection")
	inst.AnimState:SetBank("kochosei_hatfl")
	inst.AnimState:SetBuild("kochosei_hatfl")
	return inst
end
--[[
Kochoseiapi.MakeItemSkin("kochosei_hatfl", "kochosei_hatfl_skin", {
    name="kochosei_hatfl_skin",
    atlas="images/inventoryimages/kochosei_inv.xml",
    image="kochosei_hatfl_skin",
    build="kochosei_hatfl_skin",
    bank="kochosei_hatfl_skin",
    basebuild="kochosei_hatfl",
    basebank="kochosei_hatfl"
})
--]]

STRINGS.NAMES.KOCHOSEI_HAT1 = "Kochosei Hat"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_HAT1 = "Its butterfly right? :>"
STRINGS.RECIPE_DESC.KOCHOSEI_HAT1 = "Armor hat"
STRINGS.NAMES.KOCHOSEI_HAT2 = "Kochosei Hat"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_HAT2 = "Its butterfly right? :>"
STRINGS.RECIPE_DESC.KOCHOSEI_HAT2 = "Armor hat"
STRINGS.NAMES.KOCHOSEI_HAT3 = "Kochosei Hat"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_HAT3 = "Its butterfly right? :>"
STRINGS.RECIPE_DESC.KOCHOSEI_HAT3 = "Armor hat"

STRINGS.NAMES.KOCHOSEI_HATFL = "Kochosei Hat"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_HATFL = "No more worrying about headaches, but something else is coming :>"
STRINGS.RECIPE_DESC.KOCHOSEI_HATFL = "No more worrying about headaches, but something else is coming :>"
return Prefab("kochosei_hat1", kochosei_hat1, assets),
	Prefab("kochosei_hat2", kochosei_hat2, assets),
	Prefab("kochosei_hat3", kochosei_hat3, assets),
	Prefab("kochosei_hatfl", kochosei_hatfl, assets)
