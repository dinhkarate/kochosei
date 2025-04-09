require("prefabutil")

local function onopen(inst)
	inst.AnimState:PlayAnimation("teleport", true)
	--inst.SoundEmitter:PlaySound('dontstarve/wilson/chest_open')
end

local function onclose(inst)
	inst.AnimState:PlayAnimation("ending")
	inst.AnimState:PushAnimation("ending_loop", true)
	--inst.SoundEmitter:PlaySound('dontstarve/wilson/chest_close')
end

local function onhammered(inst, worker)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	if inst.components.container ~= nil then
		inst.components.container:DropEverything()
	end
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("ending")
	inst.AnimState:PushAnimation("ending_loop", true)

	if inst.components.container ~= nil then
		inst.components.container:DropEverything()
		inst.components.container:Close()
	end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("ending")
	inst.AnimState:PushAnimation("ending_loop", true)
	--inst.SoundEmitter:PlaySound('dontstarve/common/chest_craft')
end

local function onsave(inst, data)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
		data.burnt = true
	end
end

local function onload(inst, data)
	if data ~= nil and data.burnt and inst.components.burnable ~= nil then
		inst.components.burnable.onburnt(inst)
	end
end

local assets = {
	Asset("ANIM", "anim/quagmire_altar.zip"),
	Asset("ATLAS", "images/inventoryimages/kochosei_inv.xml"),
	Asset("IMAGE", "images/inventoryimages/kochosei_inv.tex"),
}

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	--inst.MiniMapEntity:SetIcon('treasurechest.png')

	inst:AddTag("structure")
	inst:AddTag("chest")

	inst.AnimState:SetBank("quagmire_altar")
	inst.AnimState:SetBuild("quagmire_altar")
	inst.AnimState:PlayAnimation("ending_loop", true)

	MakeSnowCoveredPristine(inst)

	MakeObstaclePhysics(inst, 0.5)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	-- inst:AddComponent("prototyper")
	-- inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.KOCHOSEI_ALTAR

	inst:AddComponent("inspectable")

	inst:AddComponent("container")
	inst.components.container:WidgetSetup("kochosei_altar")
	inst.components.container.onopenfn = onopen
	inst.components.container.onclosefn = onclose

	inst:AddComponent("lootdropper")
	--inst:AddComponent('workable')
	--inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	--inst.components.workable:SetWorkLeft(9999)
	--inst.components.workable:SetOnWorkCallback(onhit)
	--inst.components.workable:SetOnFinishCallback(onhammered)

	MakeMediumPropagator(inst)
	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

	inst:ListenForEvent("onbuilt", onbuilt)
	MakeSnowCovered(inst)

	-- Save / load is extended by some prefab variants
	inst.OnSave = onsave
	inst.OnLoad = onload

	return inst
end

STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_ALTAR = "Tế Đàn"
--STRINGS.RECIPE_DESC.KOCHOSEI_ALTAR = "Tế Đàn"
STRINGS.NAMES.KOCHOSEI_ALTAR = "Tế Đàn"

return Prefab("kochosei_altar", fn, assets), MakePlacer("kochosei_altar_placer")
