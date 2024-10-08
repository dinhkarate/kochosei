local assets = {
	Asset("ANIM", "anim/kochosei_wishlamp.zip"),
	Asset("ANIM", "anim/kochosei_building_redlantern.zip"),
}

local SCALE = 1.25

local function TurnOn(inst)
	inst.on = true
	inst.Light:Enable(true)
	inst.components.fueled:StartConsuming()
	if inst.prefab == "kochosei_building_redlantern" then
		inst.AnimState:PlayAnimation("idle_on", true)
	end
	if inst.prefab == "kochosei_wishlamp" then
		inst.AnimState:PlayAnimation("idle_on", true)
	end
end

local function TurnOff(inst)
	inst.on = false
	inst.Light:Enable(false)
	inst.components.fueled:StopConsuming()
	--	 inst.AnimState:PlayAnimation("idle_off", true)
	if inst.prefab == "kochosei_building_redlantern" then
		inst.AnimState:PlayAnimation("idle_off", true)
	end
	if inst.prefab == "kochosei_wishlamp" then
		inst.AnimState:PlayAnimation("idle_off", true)
	end
end

local function CanInteract(inst)
	return not inst.components.fueled:IsEmpty()
end

local function OnChange(inst)
	local day = TheWorld.state.phase
	if day == "night" and not inst.components.fueled:IsEmpty() then
		inst.components.machine:TurnOn()
	else
		inst.components.machine:TurnOff()
	end
end

local function OnFuelEmpty(inst)
	-- TurnOff(inst)
	inst.components.machine:TurnOff()
end

local function OnAddFuel(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/machine_fuel")
	if inst.on == false and TheWorld.state.phase == "night" then
		-- TurnOn(inst)
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

local function keepTwoDecimalPlaces(decimal) -----------------------四舍五入保留两位小数的代码
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

	inst.entity:AddNetwork()

	inst.entity:AddLight()
	inst.Light:SetIntensity(0.9)
	inst.Light:SetColour(255 / 255, 241 / 255, 141 / 255)
	inst.Light:SetFalloff(0.4)
	inst.Light:SetRadius(3)
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

local function cottreolongden()
	local inst = commonfn()
	inst.AnimState:SetBank("kochosei_wishlamp")
	inst.AnimState:SetBuild("kochosei_wishlamp")
	inst.AnimState:PlayAnimation("idle_off", true)
	return inst
end

local function cotden()
	local inst = commonfn()
	inst.AnimState:SetBank("kochosei_building_redlantern")
	inst.AnimState:SetBuild("kochosei_building_redlantern")
	inst.AnimState:PlayAnimation("idle_off", true)
	return inst
end

STRINGS.NAMES[string.upper("kochosei_wishlamp")] = "Wish lamp"
STRINGS.RECIPE_DESC[string.upper("kochosei_wishlamp")] = "A beautiful Japan lantern to decorate"
STRINGS.NAMES[string.upper("kochosei_building_redlantern")] = "Wish lamp"
STRINGS.RECIPE_DESC[string.upper("kochosei_building_redlantern")] = "A beautiful Japan lantern to decorate"

return Prefab("kochosei_wishlamp", cottreolongden, assets),
	Prefab("kochosei_building_redlantern", cotden, assets),
	MakePlacer("kochosei_wishlamp_placer", "kochosei_wishlamp", "kochosei_wishlamp", "idle_on", nil, nil, nil, SCALE),
	MakePlacer(
		"kochosei_building_redlantern_placer",
		"kochosei_building_redlantern",
		"kochosei_building_redlantern",
		"idle_on",
		nil,
		nil,
		nil,
		SCALE
	)
