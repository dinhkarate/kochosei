local assets = {
	Asset("ANIM", "anim/kochosei_streetlight1_left.zip"),
	Asset("ANIM", "anim/kochosei_streetlight1_right.zip"),
}

local SCALE = 1.25

local function TurnOn(inst)
	inst.on = true
	inst.Light:Enable(true)
	inst.components.fueled:StartConsuming()
	if inst.prefab == "kochosei_streetlight1_left" then
		inst.AnimState:PlayAnimation("idle_on", true)
	end
	if inst.prefab == "kochosei_streetlight1_right" then
		inst.AnimState:PlayAnimation("idle_on", true)
	end
	--inst.AnimState:PlayAnimation("idle_on", true)
end

local function TurnOff(inst)
	inst.on = false
	inst.Light:Enable(false)
	inst.components.fueled:StopConsuming()
	if inst.prefab == "kochosei_streetlight1_left" then
		inst.AnimState:PlayAnimation("idle_off", true)
	end
	if inst.prefab == "kochosei_streetlight1_right" then
		inst.AnimState:PlayAnimation("idle_off", true)
	end
	--inst.AnimState:PlayAnimation("idle_off", true)
end

local function CanInteract(inst)
	return not inst.components.fueled:IsEmpty()
end

local function OnFuelEmpty(inst)
	inst.components.machine:TurnOff()
end

local function OnAddFuel(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/machine_fuel")
	if inst.on == false and TheWorld.state.phase == "night" then
		inst.components.machine:TurnOn()
	end
	local fuel_value = TUNING.CAMPFIRE_FUEL_MAX * 7
	inst.components.fueled:DoDelta(fuel_value)
end

local function fuelupdate(inst)
	if inst.components.fueled:IsEmpty() then
		OnFuelEmpty(inst)
	end
end

local function onhammered(inst, worker)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	local fx = SpawnPrefab("collapse_big")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	fx:SetMaterial("wood")
	inst:Remove()
end

local function onhit(inst, worker) end

local function keepTwoDecimalPlaces(decimal)
	decimal = math.floor((decimal * 100) + 0.5) * 0.01
	return decimal
end

local function descriptionfn(inst, viewer)
	return "Fuel: " .. tostring(keepTwoDecimalPlaces(inst.components.fueled:GetPercent() * 100)) .. "%"
end

local function OnChange(inst)
	local day = TheWorld.state.phase
	if day == "night" then
		inst.components.machine:TurnOn()
	else
		inst.components.machine:TurnOff()
	end
end

local function commonfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
	inst.DynamicShadow:SetSize(3.7, 3)
	inst.entity:AddMiniMapEntity()
	inst.entity:AddLight()
	inst.entity:AddNetwork()

	inst.Light:SetIntensity(0.9)
	inst.Light:SetColour(255 / 255, 200 / 255, 255 / 255)
	inst.Light:SetFalloff(0.6)
	inst.Light:SetRadius(6)
	inst.Light:Enable(false)

	MakeObstaclePhysics(inst, 0.05)

	inst.Transform:SetScale(SCALE, SCALE, SCALE)

	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end

	inst.on = false

	inst:AddComponent("inspectable")
	inst.components.inspectable.descriptionfn = descriptionfn

	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	inst:AddComponent("machine")
	inst.components.machine.turnonfn = TurnOn
	inst.components.machine.turnofffn = TurnOff
	inst.components.machine.caninteractfn = CanInteract
	inst.components.machine.cooldowntime = 0

	inst:AddComponent("fueled")
	inst.components.fueled:SetDepletedFn(OnFuelEmpty)
	inst.components.fueled:SetUpdateFn(fuelupdate)
	inst.components.fueled:SetTakeFuelFn(OnAddFuel)
	inst.components.fueled.accepting = true
	inst.components.fueled:SetSections(10)
	inst.components.fueled:InitializeFuelLevel(TUNING.CAMPFIRE_FUEL_MAX * 50)

	inst:ListenForEvent("onbuilt", OnChange)

	return inst
end

local function right()
	local inst = commonfn()
	inst.AnimState:SetBank("kochosei_streetlight1_right")
	inst.AnimState:SetBuild("kochosei_streetlight1_right")
	inst.AnimState:PlayAnimation("idle_on", true)
	return inst
end
local function left()
	local inst = commonfn()
	inst.AnimState:SetBank("kochosei_streetlight1_left")
	inst.AnimState:SetBuild("kochosei_streetlight1_left")
	inst.AnimState:PlayAnimation("idle_on", true)
	return inst
end

STRINGS.NAMES[string.upper("kochosei_streetlight1_right")] = "Kochosei streetlight right"
STRINGS.RECIPE_DESC[string.upper("kochosei_streetlight1_right")] = "A beautiful lantern to decorate"
STRINGS.NAMES[string.upper("kochosei_streetlight1_left")] = "Kochosei streetlight left"
STRINGS.RECIPE_DESC[string.upper("kochosei_streetlight1_left")] = "A beautiful lantern to decorate"

return Prefab("kochosei_streetlight1_left", left, assets),
	MakePlacer(
		"kochosei_streetlight1_left_placer",
		"kochosei_streetlight1_left",
		"kochosei_streetlight1_left",
		"idle_on",
		nil,
		nil,
		nil,
		SCALE
	),
	Prefab("kochosei_streetlight1_right", right, assets),
	MakePlacer(
		"kochosei_streetlight1_right_placer",
		"kochosei_streetlight1_right",
		"kochosei_streetlight1_right",
		"idle_on",
		nil,
		nil,
		nil,
		SCALE
	)
