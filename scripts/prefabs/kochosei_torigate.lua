local assets = {
	Asset("ANIM", "anim/kochosei_torigate.zip"),
}
local SCALE = 2

local prefabs = {
	"collapse_small",
}

local function onhammered(inst, worker)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	local fx = SpawnPrefab("collapse_small")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	fx:SetMaterial("wood")
	inst:Remove()
end

local function onhit(inst, worker) end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("kochosei_torigate")
	inst.AnimState:SetBuild("kochosei_torigate")
	inst.AnimState:PlayAnimation("idle", true)
	inst.Transform:SetScale(SCALE, SCALE, SCALE)
	MakeSnowCoveredPristine(inst)

	inst:AddTag("structure")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("lootdropper")

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
	MakeSnowCovered(inst)

	MakeSmallBurnable(inst, nil, nil, true)
	MakeSmallPropagator(inst)
	---------------------

	return inst
end
STRINGS.NAMES.KOCHOSEI_TORIGATE = "Torii"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_TORIGATE = "Woah! It looks nice"
STRINGS.RECIPE_DESC.KOCHOSEI_TORIGATE = "Torii gates"

return Prefab("kochosei_torigate", fn, assets, prefabs),
	MakePlacer("kochosei_torigate_placer", "kochosei_torigate", "kochosei_torigate", "idle", nil, nil, nil, SCALE)
