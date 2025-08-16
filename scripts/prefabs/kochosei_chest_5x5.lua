local assets = {
	Asset("ANIM", "anim/kochosei_chest_5x5.zip"),
	Asset("ANIM", "anim/ui_kochosei_chest_5x5.zip"),
	Asset("ANIM", "anim/kochosei_fridge_5x5.zip"),
	Asset("ANIM", "anim/ui_kochosei_fridge_5x5.zip"),
}

local function onopen(inst)
	inst.AnimState:PlayAnimation("open")
	if inst.prefab == "kochosei_fridge_5x5" then
		inst.SoundEmitter:PlaySound("dontstarve/common/icebox_open")
	else
		inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
	end
end

local function onclose(inst)
	inst.AnimState:PlayAnimation("close")
	if inst.prefab == "kochosei_fridge_5x5" then
		inst.SoundEmitter:PlaySound("dontstarve/common/icebox_close")
	else
		inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
	end
end
local function onworked(inst, worker, workleft)
	if workleft > 0 and not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("hit")

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
	if inst.prefab == "kochosei_fridge_5x5" then
		inst.SoundEmitter:PlaySound("dontstarve/common/icebox_craft")
	else
		inst.SoundEmitter:PlaySound("dontstarve/common/chest_craft")
	end
end
local function commonchest(name, anim)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	MakeSnowCoveredPristine(inst)

	local SCALE = 0.8
	inst.AnimState:SetBank(name)
	inst.AnimState:SetBuild(name)
	inst.AnimState:PlayAnimation("close")
	inst.AnimState:SetScale(SCALE, SCALE, SCALE)

	inst._chestupgrade_stacksize = true
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		inst.OnEntityReplicated = function(inst)
			inst.replica.container:WidgetSetup(name)
		end
		return inst
	end

	MakeSnowCovered(inst)
	inst:AddTag("meteor_protection")
	inst:AddTag("nosteal")
	inst:AddTag("structure")

	inst:AddComponent("inspectable")

	inst:AddComponent("container")
	inst.components.container:WidgetSetup(name)
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

local function fn()
	local inst = commonchest("kochosei_chest_5x5", "kochosei_chest_5x5")
	return inst
end

local function fnfr()
	local inst = commonchest("kochosei_fridge_5x5", "kochosei_fridge_5x5")

    inst:AddTag("frozen")
	inst:AddTag("fridge")
	inst.SoundEmitter:PlaySound("dontstarve/common/ice_box_LP", "idlesound")
	if not TheWorld.ismastersim then
		return inst
	end
	inst:AddComponent("preserver")
	inst.components.preserver:SetPerishRateMultiplier(TUNING.MIKU_USAGI_BACKPACK)
	return inst
end
STRINGS.NAMES.KOCHOSEI_CHEST_5X5 = "Rương Đ Gì Sida V~"
STRINGS.NAMES.KOCHOSEI_FRIDGE_5X5 = "Tủ Lạnh 1* Tiết Kiệm Năng Lượng"

STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_FRIDGE_5X5 = "Tủ Lạnh 1* Tiết Kiệm Năng Lượng"
STRINGS.RECIPE_DESC.KOCHOSEI_FRIDGE_5X5 = "Tủ lạnh promã"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_CHEST_5X5 = "Rương Đ Gì Sida V~"
STRINGS.RECIPE_DESC.KOCHOSEI_CHEST_5X5 =
	"Chứa được nhiều đồ hơn rương 3x3, còn lại không có gì đặc biệt"
return Prefab("kochosei_chest_5x5", fn, assets),
	Prefab("kochosei_fridge_5x5", fnfr, assets),
	MakePlacer("kochosei_chest_5x5_placer", "kochosei_chest_5x5", "kochosei_chest_5x5", "close"),
	MakePlacer("kochosei_fridge_5x5_placer", "kochosei_fridge_5x5", "kochosei_fridge_5x5", "close")
