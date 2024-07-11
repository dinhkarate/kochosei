local assets = {
	Asset("ANIM", "anim/kocho_lotus.zip"),
	Asset("SOUND", "sound/common.fsb"),
	--Asset("MINIMAP_IMAGE", "lotus"),
}

local function onpickedfn(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds")
	inst.AnimState:PlayAnimation("picking")
	inst.AnimState:PushAnimation("picked")
end

local function onregenfn(inst)
	inst.AnimState:PlayAnimation("grow")
	inst.AnimState:PushAnimation("idle_plant", true)
end

local function makeemptyfn(inst)
	inst.AnimState:PlayAnimation("picked", true)
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()
	MakeObstaclePhysics(inst, 0.25)
	MakeInventoryPhysics(inst, nil, 0.7)

	inst.AnimState:SetBank("kocho_lotus")
	inst.AnimState:SetBuild("kocho_lotus")
	inst.AnimState:PlayAnimation("idle_plant", true)
	inst.AnimState:SetFinalOffset(1)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("pickable")
	inst.components.pickable.picksound = "turnoftides/common/together/water/harvest_plant"
	inst.components.pickable:SetUp("kocho_lotus_flower", TUNING.BULLKELP_REGROW_TIME)
	inst.components.pickable.onregenfn = onregenfn
	inst.components.pickable.onpickedfn = onpickedfn
	inst.components.pickable.makeemptyfn = makeemptyfn
	inst.components.pickable.product = "kocho_lotus_flower"
	inst:AddComponent("inspectable")

	---------------------
	MakeSmallBurnable(inst, TUNING.SMALL_FUEL)
	MakeSmallPropagator(inst)
	MakeHauntableIgnite(inst)
	---------------------

	return inst
end

STRINGS.NAMES.KOCHO_LOTUS2 = "Hoa Sen"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHO_LOTUS2 = "Trong đầm gì đẹp bằng sen?"

return Prefab("kocho_lotus2", fn, assets, prefabs)
