local assets = {
	Asset("ANIM", "anim/kocho_lotus.zip"),
	Asset("SOUND", "sound/common.fsb"),
}

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)
	MakeHauntableLaunch(inst)
	MakeInventoryFloatable(inst, "small", 0.1, 1.12)
	inst.AnimState:SetBank("kocho_lotus")
	inst.AnimState:SetBuild("kocho_lotus")
	inst.AnimState:PlayAnimation("idle")

	inst.entity:SetPristine()
	inst:AddTag("hoasen")
	if not TheWorld.ismastersim then
		return inst
	end
	inst:AddTag("hoasen")
	-----------------
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	---------------------

	inst:AddComponent("edible")
	inst.components.edible.healthvalue = TUNING.HEALING_TINY
	inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
	inst.components.edible.sanityvalue = TUNING.SANITY_TINY or 0
	inst.components.edible.foodtype = FOODTYPE.VEGGIE

	---------------------

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	---------------------

	inst:AddComponent("cookable")
	inst.components.cookable.product = "kocho_lotus_flower_cooked"

	inst:AddComponent("bait")

	inst:AddComponent("inspectable")
	----------------------

	inst:AddComponent("inventoryitem")

	inst:AddComponent("tradable")

	return inst
end

local function fncooked()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)
	MakeHauntableLaunch(inst)

	inst.AnimState:SetBank("kocho_lotus")
	inst.AnimState:SetBuild("kocho_lotus")
	inst.AnimState:PlayAnimation("cooked")

	inst:AddTag("cattoy")
	inst:AddTag("billfood")

	inst:AddTag("smalloceancreature") -- Này để bỏ vào thùng, chứ t cũng không muốn add đâu

	inst:AddTag("hoasen") -- Này để bỏ vào thùng, chứ t cũng không muốn add đâu

	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end

	-----------------
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	---------------------

	inst:AddComponent("edible")
	inst.components.edible.healthvalue = TUNING.HEALING_TINY
	inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
	inst.components.edible.sanityvalue = TUNING.SANITY_MED or 0
	inst.components.edible.foodtype = FOODTYPE.VEGGIE

	---------------------

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	---------------------

	inst:AddComponent("inspectable")
	----------------------

	inst:AddComponent("bait")

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)

	inst:AddComponent("inventoryitem")

	inst:AddComponent("tradable")

	return inst
end
STRINGS.NAMES.KOCHO_LOTUS_FLOWER_COOKED = "Bông Sen Nướng"
STRINGS.NAMES.KOCHO_LOTUS_FLOWER = "Bông Sen"
return Prefab("kocho_lotus_flower", fn, assets), Prefab("kocho_lotus_flower_cooked", fncooked, assets)
