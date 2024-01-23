local prefabs = {
	"spoiled_food",
}

local function MakePreparedFood(data)
	local realname = data.basename or data.name
	local assets = {
		Asset("ANIM", "anim/" .. realname .. ".zip"),
	}
	local spicename = data.spice ~= nil and string.lower(data.spice) or nil
	if spicename ~= nil then
		table.insert(assets, Asset("ANIM", "anim/spices.zip"))
		table.insert(assets, Asset("ANIM", "anim/plate_food.zip"))
		table.insert(assets, Asset("INV_IMAGE", spicename .. "_over"))
	end

	local assets = {
		Asset("ANIM", "anim/" .. realname .. ".zip"),
		Asset("ATLAS", "images/inventoryimages/kochofood.xml"),
	}

	local function onsave(inst, data)
		data.anim = inst.animname
	end

	local function onload(inst, data)
		if data and data.anim then
			inst.animname = data.anim
			inst.AnimState:PlayAnimation(inst.animname)
		end
	end

	local foodprefabs = prefabs
	if data.prefabs ~= nil then
		foodprefabs = shallowcopy(prefabs)
		for i, v in ipairs(data.prefabs) do
			if not table.contains(foodprefabs, v) then
				table.insert(foodprefabs, v)
			end
		end
	end

	local function DisplayNameFn(inst)
		return subfmt(STRINGS.NAMES[data.spice .. "_FOOD"], { food = STRINGS.NAMES[string.upper(data.basename)] })
	end

	local function fn()
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddNetwork()

		MakeInventoryPhysics(inst)

		if spicename ~= nil then
			inst.AnimState:SetBuild("plate_food")
			inst.AnimState:SetBank("plate_food")
			inst.AnimState:OverrideSymbol("swap_garnish", "spices", spicename)

			inst:AddTag("spicedfood")

			inst.inv_image_bg =
				{ atlas = "images/inventoryimages/kochofood.xml", image = (data.basename or data.name) .. ".tex" }
		else
			inst.AnimState:SetBuild(realname)
			inst.AnimState:SetBank(realname)
		end
		inst.AnimState:PlayAnimation("idle")
		inst.AnimState:OverrideSymbol("swap_food", realname, realname)

		if data.floater ~= nil then
			MakeInventoryFloatable(inst, data.floater[1], data.floater[2], data.floater[3])
		else
			MakeInventoryFloatable(inst)
		end

		inst:AddTag("preparedfood")
		inst:AddTag("icebox_valid")
		inst:AddTag("show_spoilage")

		if data.tags then
			for i, v in pairs(data.tags) do
				inst:AddTag(v)
			end
		end

		if data.basename ~= nil then
			inst:SetPrefabNameOverride(data.basename)
			if data.spice ~= nil then
				inst.displaynamefn = DisplayNameFn
			end
		end

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		inst:AddComponent("edible")
		inst.components.edible.foodtype = data.foodtype or FOODTYPE.GENERIC
		inst.components.edible.hungervalue = data.hunger or 0
		inst.components.edible.healthvalue = data.health or 0
		inst.components.edible.sanityvalue = data.sanity or 0
		inst.components.edible.temperaturedelta = data.temperature or 0
		inst.components.edible.temperatureduration = data.temperatureduration or 0
		inst.components.edible.nochill = data.nochill or nil
		inst.components.edible.spice = data.spice
		inst.components.edible:SetOnEatenFn(data.oneatenfn)
		inst.components.edible.secondaryfoodtype = FOODTYPE.GOODIES

		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

		inst:AddComponent("bait")

		inst:AddComponent("tradable")

		inst:AddComponent("inspectable")

		inst:AddComponent("perishable")
		inst.components.perishable:SetPerishTime(data.perishtime)
		inst.components.perishable:StartPerishing()
		inst.components.perishable.onperishreplacement = "spoiled_food"

		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.imagename = realname
		if spicename ~= nil then
			inst.components.inventoryitem:ChangeImageName(spicename .. "_over")
		elseif data.basename ~= nil then
			inst.components.inventoryitem:ChangeImageName(data.basename)
		else
			inst.components.inventoryitem.atlasname = "images/inventoryimages/kochofood.xml"
		end

		inst.OnSave = onsave
		inst.OnLoad = onload

		MakeSmallBurnable(inst)
		MakeSmallPropagator(inst)
		MakeHauntableLaunchAndPerish(inst)

		return inst
	end

	return Prefab(data.name, fn, assets, foodprefabs)
end

local prefs = {}

for k, v in pairs(require("prkochofood")) do
	table.insert(prefs, MakePreparedFood(v))
end
for k, v in pairs(require("kocho_spicedfoods")) do
	table.insert(prefs, MakePreparedFood(v))
end

return unpack(prefs)
