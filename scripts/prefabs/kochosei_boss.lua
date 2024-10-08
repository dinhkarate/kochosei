local function make(code, description, check_des_boolean, alter_description, fileanim)
	local name = (description or STRINGS.NAMES[string.upper(code)] or STRINGS.SKIN_NAMES[string.lower(code)] or "???")
	STRINGS.NAMES[string.upper(code)] = name
	STRINGS.RECIPE_DESC[string.upper(code)] = check_des_boolean or alter_description
	STRINGS.CHARACTERS.GENERIC.DESCRIBE[string.upper(code)] = alter_description
		or STRINGS.SKIN_DESCRIPTIONS[code]
		or (
			(description or STRINGS.NAMES[string.upper(code)] or STRINGS.SKIN_NAMES[string.lower(code)] or "???") .. "。"
		)

	return Prefab(code, function()
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddNetwork()
		MakeInventoryPhysics(inst)
		MakeInventoryFloatable(inst)
		inst.entity:AddDynamicShadow()
		inst.DynamicShadow:SetSize(1, 0.6)
		inst.entity:AddLight()
		inst.Light:Enable(true)
		inst.Light:SetRadius(0.5)
		inst.Light:SetFalloff(0.7)
		inst.Light:SetIntensity(0.5)
		inst.Light:SetColour(238 / 255, 155 / 255, 143 / 255)
		inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
		inst.AnimState:SetBank(fileanim)
		inst.AnimState:SetBuild(fileanim)
		inst.AnimState:PlayAnimation(fileanim, true)
		inst.Transform:SetScale(1.5, 1.5, 1.5)

		inst.entity:SetPristine()
		--Cđmm TheWorld.ismastersim phải đặt trước các components
		if not TheWorld.ismastersim then
			return inst
		end
		inst:AddComponent("inspectable")
		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.keepondeath = true
		inst.components.inventoryitem.atlasname = "images/inventoryimages/kochosei_duke_crown.xml"
		inst.components.inventoryitem.imagename = "kochosei_duke_crown"

		inst:AddComponent("equippable")
		inst.components.equippable.equipslot = EQUIPSLOTS.MEDAL or EQUIPSLOTS.NECK or EQUIPSLOTS.BODY

		return inst
	end, {
		Asset("ANIM", "anim/" .. fileanim .. ".zip"),
		Asset("ATLAS", "images/inventoryimages/" .. fileanim .. ".xml"),
	})
end

return make(
	"kochosei_duke_crown",
	"Vương Miện Công Tước",
	nil,
	"Vương Miện của Kẻ Quyền Quý",
	"kochosei_duke_crown"
) -- Con cò dinh sai chính tả
