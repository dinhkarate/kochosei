local easing = require("easing")

local assets = {
	Asset("ANIM", "anim/kochosei_tigershark_shadow.zip"),
}

local function OnRemove(inst)
	if inst.sizeTask then
		inst.sizeTask:Cancel()
		inst.sizeTask = nil
	end
end

local function SetUpScale(inst, start_scale, end_scale, scale_time, fade_type, ease_type)
	ease_type = ease_type or easing.inExpo
	local start_time = GetTime()
	inst.Transform:SetScale(start_scale, start_scale, start_scale)

	if inst.sizeTask then
		inst.sizeTask:Cancel()
		inst.sizeTask = nil
	end

	inst.sizeTask = inst:DoPeriodicTask(FRAMES, function(inst)
		local scale = ease_type(GetTime() - start_time, start_scale, end_scale - start_scale, scale_time)
		inst.Transform:SetScale(scale, scale, scale)
	end)

	if fade_type == "OUT" then
		inst.AnimState:SetMultColour(0, 0, 0, 0.6)
		inst.components.colourtweener:StartTween({ 0, 0, 0, 0 }, scale_time)
	else
		inst.AnimState:SetMultColour(0, 0, 0, 0)
		inst.components.colourtweener:StartTween({ 0, 0, 0, 0.6 }, scale_time)
	end
end
local MAX_SCALE = 1.5
local MIN_SCALE = 0.5
local function Ground_Fall(inst)
	--Big -> Small
	SetUpScale(inst, MAX_SCALE, MIN_SCALE, 1.8, "IN")
	inst:DoTaskInTime(1.8, inst.Remove)
end

local function Water_Jump(inst)
	--Small -> Big
	SetUpScale(inst, MIN_SCALE, MAX_SCALE, 91 * FRAMES)
	--Big -> Small
	inst:DoTaskInTime(91 * FRAMES, function()
		SetUpScale(inst, MAX_SCALE, MIN_SCALE, FRAMES * 15, "OUT", easing.outExpo)
	end)
	inst:DoTaskInTime(106 * FRAMES, inst.Remove)
end

local function Water_Fall(inst)
	--Big -> Small
	SetUpScale(inst, MAX_SCALE, MIN_SCALE, 1.8, "IN")
	inst:DoTaskInTime(1.8, inst.Remove)
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("tigershark_shadow")
	inst.AnimState:SetBuild("tigershark_shadow")
	inst.AnimState:PlayAnimation("air", true)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("colourtweener")

	inst.Ground_Fall = Ground_Fall
	inst.Water_Jump = Water_Jump
	inst.Water_Fall = Water_Fall
	inst.OnRemoveEntity = OnRemove
	inst.persists = false

	return inst
end

return Prefab("kochosei_tigershark_duke_shadow", fn, assets, prefabs)
