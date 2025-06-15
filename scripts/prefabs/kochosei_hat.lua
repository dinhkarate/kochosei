local assets = {
	Asset("ANIM", "anim/kochosei_hat1.zip"),
	Asset("ANIM", "anim/kochosei_hat2.zip"),
	Asset("ANIM", "anim/kochosei_hat3.zip"),
	Asset("ANIM", "anim/kochosei_hatfl.zip"),
	Asset("ANIM", "anim/ms_kochosei_hat2.zip"),
	Asset("ANIM", "anim/ms_kochosei_hat3.zip"),
	Asset("ANIM", "anim/kochosei_hatfl_skin.zip"),
	Asset("ANIM", "anim/kochosei_ribbon.zip"), --   Asset("ANIM", "anim/kochosei_hatfl_skin_drop.zip")
}
local dobenvohan = true

local function Themgiap(inst)
	if type(TUNING.KOCHO_HAT1_DURABILITY) == "number" then
		dobenvohan = false
	end
	if dobenvohan then
		inst.components.armor:InitIndestructible(TUNING.KOCHO_HAT1_ABSORPTION)
		inst.components.armor.condition = 100
		inst:AddTag("hide_percentage")
	else
		inst.components.armor:InitCondition(
			TUNING.KOCHO_HAT1_DURABILITY + (TUNING.KOCHOSEI_CHECKWIFI * 2),
			TUNING.KOCHO_HAT1_ABSORPTION
		)
	end

end

local hatMappings = {
	kochosei_hatfl = "kochosei_hatfl",
	kochosei_hat2 = "kochosei_hat2",
}

local function OnEquip(inst, owner)
	local hatName = hatMappings[inst.prefab]
	if hatName then
		local checkbuild = inst.AnimState:GetBuild()
		local checkskin = checkbuild == "kochosei_hat1"
			or checkbuild == "kochosei_hat3"
			or checkbuild == "kochosei_ribbon"
		if not checkskin then
			owner.AnimState:OverrideSymbol("swap_hat", inst.skinname or hatName, "swap_hat")
		end

		if hatName == "kochosei_hatfl" and owner.components.sanity then
			owner.components.sanity.neg_aura_absorb = TUNING.ARMOR_HIVEHAT_SANITY_ABSORPTION
			if owner.components.sanity.mode == SANITY_MODE_INSANITY then
				owner.components.sanity:EnableLunacy(true, "hatfl")
			end
			owner.tangst = true
		end

		if owner.AnimState:GetBuild() == "kochosei_snowmiku_skin1" and checkbuild == "kochosei_ribbon" then
			owner.AnimState:OverrideSymbol("swap_hat", inst.skinname or hatName, "swap_hat")
		end
		owner.AnimState:Show("HAT")
		owner.AnimState:Show("HAIR_HAT")
	end
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
	Themgiap(inst)

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

local function commonfn_ribbon()
	local inst = commonfn()
	inst.AnimState:SetBank("kochosei_hat2")
	inst.AnimState:SetBuild("kochosei_hat2")

	return inst
end

local function kochosei_hatfl()
	local inst = commonfn()
	inst:AddTag("gestaltprotection")
	inst.AnimState:SetBank("kochosei_hatfl")
	inst.AnimState:SetBuild("kochosei_hatfl")
		if not TheWorld.ismastersim then
		return inst
	end
	inst:AddComponent("planardefense")
	inst.components.planardefense:SetBaseDefense(TUNING.ARMOR_LUNARPLANT_PLANAR_DEF)
	return inst
end

if TUNING.KOCHOSEI_CHECKMOD ~= 1 and Kochoseiapi.MakeItemSkin ~= nil then
	Kochoseiapi.MakeItemSkin("kochosei_hat2", "kochosei_hat1", {
		name = "ごめんなさい、アマナイさん。",
		atlas = "images/inventoryimages/kochosei_inv.xml",
		image = "kochosei_hat1",
		imagename = "kochosei_hat1.tex",
		build = "kochosei_hat1",
		bank = "kochosei_hat1",
		basebuild = "kochosei_hat2",
		basebank = "kochosei_hat2",
	})

	Kochoseiapi.MakeItemSkin("kochosei_hat2", "kochosei_hat3", {
		name = "空想 技:紫",
		atlas = "images/inventoryimages/kochosei_inv.xml",
		image = "kochosei_hat3",
		build = "kochosei_hat3",
		bank = "kochosei_hat3",
		basebuild = "kochosei_hat2",
		basebank = "kochosei_hat2",
	})
	Kochoseiapi.MakeItemSkin("kochosei_hat2", "kochosei_ribbon", {
		name = "Kyoshiki, Murasaki",
		atlas = "images/inventoryimages/kochosei_inv.xml",
		image = "kochosei_ribbon",
		imagename = "kochosei_ribbon.tex",
		build = "kochosei_ribbon",
		bank = "kochosei_ribbon",
		basebuild = "kochosei_hat2",
		basebank = "kochosei_hat2",
	})
end

-- Không có anim. không dùng

STRINGS.NAMES.KOCHOSEI_HAT1 = "Kochosei Hat"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_HAT1 = "Its butterfly right? :>"
STRINGS.RECIPE_DESC.KOCHOSEI_HAT1 = "Armor hat"
STRINGS.NAMES.KOCHOSEI_HAT2 = "Kochosei Hat"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_HAT2 = "Its butterfly right? :>"
STRINGS.RECIPE_DESC.KOCHOSEI_HAT2 = "Armor hat"
STRINGS.NAMES.KOCHOSEI_HAT3 = "Kochosei Hat"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_HAT3 = "Its butterfly right? :>"
STRINGS.RECIPE_DESC.KOCHOSEI_HAT3 = "Armor hat"
STRINGS.NAMES.KOCHOSEI_RIBBON = "Kochosei Ribbon"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_RIBBON = "ごめんなさい、アマナイさん。🫸🔵🔴🫷🤌。 空想 技:紫 🫴🟣"
STRINGS.RECIPE_DESC.KOCHOSEI_RIBBON = "ごめんなさい、アマナイさん。"

--]]
STRINGS.NAMES.KOCHOSEI_HAT2 = "Kochosei Ribbon"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_HAT2 =
	"ごめんなさい、アマナイさん。🫸🔵🔴🫷🤌。 空想 技:紫 🫴🟣"
STRINGS.RECIPE_DESC.KOCHOSEI_HAT2 = "ごめんなさい、アマナイさん。"

STRINGS.NAMES.KOCHOSEI_HATFL = "Kochosei Hat"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_HATFL = "No more worrying about headaches, but something else is coming :>"
STRINGS.RECIPE_DESC.KOCHOSEI_HATFL = "No more worrying about headaches, but something else is coming :>"

return Prefab("kochosei_hatfl", kochosei_hatfl, assets), Prefab("kochosei_hat2", commonfn_ribbon, assets)

-- Con cò này, làm tới đây r thì Lua Beautify cái cho ngta dễ dòm
