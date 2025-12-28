local assets = {
	Asset("ANIM", "anim/triple_kocho.zip"),
	Asset("ANIM", "anim/triple_kocho_UI.zip"),
}

local function onopen(inst)
	-- Không có animation open, chỉ có idle nhà nghèo nên chỉ có thế
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

local function onclose(inst)
	-- Không có animation close, chỉ có idle nhà nghèo nên chỉ có thế
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end

local function onworked(inst, worker, workleft)
	if workleft > 0 and not inst:HasTag("burnt") then
		-- Không có animation hit

		if inst.workTask ~= nil then
			inst.workTask:Cancel()
		end

		inst.workTask = inst:DoTaskInTime(15, function()
			inst.components.workable:SetWorkLeft(6)
			inst.workTask = nil
		end)
	end

	if inst.components.container and workleft == 3 then
		inst.components.container:DropEverything()
	end
end

local function onhammered(inst, worker)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
		inst.components.burnable:Extinguish()
	end
	if inst.components.container then
		inst.components.container:DropEverything()
	end
	inst.components.lootdropper:DropLoot()
	local fx = SpawnPrefab("collapse_small")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	fx:SetMaterial("metal")
	inst:Remove()
end

local function onbuilt(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/chest_craft")
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	MakeSnowCoveredPristine(inst)

	inst:AddTag("NOBLOCK") -- Cho phép player đi qua
	
	inst.AnimState:SetBank("triple_kocho_5x5")
	inst.AnimState:SetBuild("triple_kocho")
	inst.AnimState:PlayAnimation("idle", true) -- Loop idle animation
	inst.AnimState:SetScale(1.2, 1.2)

	inst._chestupgrade_stacksize = true
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		inst.OnEntityReplicated = function(inst)
			inst.replica.container:WidgetSetup("triple_kocho")
		end
		return inst
	end

	MakeSnowCovered(inst)
	inst:AddTag("meteor_protection")
	inst:AddTag("nosteal")
	inst:AddTag("structure")

	inst:AddComponent("inspectable")

	inst:AddComponent("container")
	inst.components.container:WidgetSetup("triple_kocho")
	inst.components.container.skipclosesnd = true
	inst.components.container.skipopensnd = true
	inst.components.container.onopenfn = onopen
	inst.components.container.onclosefn = onclose
	inst.components.container:EnableInfiniteStackSize(true)

	inst:AddComponent("lootdropper")

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(6)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onworked)

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

	if TUNING.SMART_SIGN_DRAW_ENABLE then
		SMART_SIGN_DRAW(inst)
	end

	inst:ListenForEvent("onbuilt", onbuilt)

	return inst
end

-- STRINGS
STRINGS.NAMES.TRIPLE_KOCHO = "Triple Kocho"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TRIPLE_KOCHO = "Ba Kocho cùng bảo vệ kho báu của bạn~"
STRINGS.RECIPE_DESC.TRIPLE_KOCHO = "Một nơi lưu trữ rộng rãi được ba Kocho bảo vệ"

return Prefab("triple_kocho", fn, assets),
	MakePlacer("triple_kocho_placer", "triple_kocho_5x5", "triple_kocho", "idle")
