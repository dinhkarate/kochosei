require("prefabutil")

local function make_plantable(data)
	local assets = {
		Asset("ANIM", "anim/kochosei_apple_fruit.zip"),
		Asset("ANIM", "anim/kochosei_apple_tree.zip"),
	}

	local function OnDeploy(inst, pt, deployer)
		local tree = SpawnPrefab(data.name)
		if tree ~= nil then
			tree.Transform:SetPosition(pt:Get())
			inst.components.stackable:Get():Remove()
			if tree.components.pickable ~= nil then
				tree.components.pickable:OnTransplant()
			end
			if deployer ~= nil and deployer.SoundEmitter ~= nil then
				deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
			end
		end
	end

	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddNetwork()

		MakeInventoryPhysics(inst)

		inst:AddTag("deployedplant")

		inst.AnimState:SetBank(data.name)
		inst.AnimState:SetBuild(data.name)
		inst.AnimState:PlayAnimation("sapling")

		if data.floater ~= nil then
			MakeInventoryFloatable(inst, data.floater[1], data.floater[2], data.floater[3])
		else
			MakeInventoryFloatable(inst)
		end

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

		inst:AddComponent("inspectable")
		inst.components.inspectable.getstatus = GetStatus
		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.imagename = "" .. data.name .. ""
		inst.components.inventoryitem.atlasname = "" .. data.name .. ".xml"

		inst:AddComponent("fuel")
		inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

		MakeMediumBurnable(inst, TUNING.LARGE_BURNTIME)
		MakeSmallPropagator(inst)

		MakeHauntableLaunchAndIgnite(inst)

		inst:AddComponent("deployable")
		inst.components.deployable.ondeploy = OnDeploy
		inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)

		return inst
	end

	return Prefab(data.name .. "_sapling", fn, assets)
end

local plantables = {
	{
		name = "kochosei_apple_tree_sapling",
		floater = { "med", 0.2, 0.65 },
	},
	--	{
	--		name = "cherry_rosebush",
	--		floater = {"large", 0.2, 0.85},
	--	},
}

local prefabs = {}

for i, v in ipairs(plantables) do
	table.insert(prefabs, make_plantable(v))
	table.insert(
		prefabs,
		MakePlacer("kochosei_apple_sapling_placer", v.name, v.name, v.anim or "idle" or "idle_planted")
	)
end

STRINGS.NAMES.KOCHOSEI_APPLE_TREE_SAPLING = "Kochosei's apple tree sapling"
STRINGS.RECIPE_DESC.KOCHOSEI_APPLE_TREE_SAPLING = "Gorgeous!"

return unpack(prefabs)
