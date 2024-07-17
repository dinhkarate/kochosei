local assets = {
	Asset("ANIM", "anim/kochosei_streetlight1_musicbox.zip"),
	Asset("SOUND", "sound/kochosei_streetlight1_musicbox.fsb"),
}

local SCALE = 1.25
--local music = TUNING.KOCHOSEI_TURNOFFMUSIC

local prefabs = { "collapse_small" }
local PLANT_TAGS = { "tendable_farmplant" }
local function TendToPlantsAOE(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	for _, v in pairs(TheSim:FindEntities(x, y, z, 30, nil, nil, PLANT_TAGS)) do
		if v.components.farmplanttendable ~= nil then
			v.components.farmplanttendable:TendTo(inst)
		end
	end
end

local function TurnOn(inst)
	local music = TUNING.KOCHOSEI_TURNOFFMUSIC

	inst.AnimState:PlayAnimation("idle_on", true)
	if music ~= nil then
		if music == 1 then
			inst.SoundEmitter:PlaySound(inst.songToPlay, "kochosei_streetlight1_musicbox/play")
		end
	end
	inst:PushEvent("turnedon")
	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL * 1.2
	inst.on = true
	inst.components.fueled:StartConsuming()
	inst.Light:Enable(true)
	inst.plantafeliz = inst:DoPeriodicTask(0.5, TendToPlantsAOE)
	inst:AddTag("daylight")
end

local function TurnOff(inst)
	inst.AnimState:PlayAnimation("idle_off", true)
	inst.SoundEmitter:KillSound("kochosei_streetlight1_musicbox/play")
	-- inst.SoundEmitter:PlaySound("kochosei_streetlight1_musicbox/end")
	inst:RemoveComponent("sanityaura")
	inst:PushEvent("turnedoff")
	inst.on = false
	inst.Light:Enable(false)
	inst.components.fueled:StopConsuming()
	if inst.plantafeliz then
		inst.plantafeliz:Cancel()
		inst.plantafeliz = nil
	end
end

local function CanInteract(inst)
	return not inst.components.fueled:IsEmpty()
end

local function OnFuelEmpty(inst)
	--TurnOff(inst)
	inst.components.machine:TurnOff()
end

local function OnAddFuel(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/machine_fuel")
	if inst.on == false and TheWorld.state.phase == "night" then
		--TurnOn(inst)
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

local function fn()
	local inst = CreateEntity()
	--local shadow = inst.entity:AddDynamicShadow()
	--local sound = inst.entity:AddSoundEmitter()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
	inst.DynamicShadow:SetSize(3.7, 3)
	inst.entity:AddMiniMapEntity()
	inst.entity:AddLight()
	inst.entity:AddNetwork()
	inst.songToPlay = "kochosei_streetlight1_musicbox/play"

	inst.Light:SetIntensity(0.9)
	inst.Light:SetColour(255 / 255, 200 / 255, 255 / 255)
	inst.Light:SetFalloff(0.9)
	inst.Light:SetRadius(16)
	inst.Light:Enable(false)

	-- MakeObstaclePhysics(inst, 1)

	--inst.MiniMapEntity:SetIcon("portal_dst.png")
	MakeObstaclePhysics(inst, 0.05)

	inst.AnimState:SetBank("kochosei_streetlight1_musicbox")
	inst.AnimState:SetBuild("kochosei_streetlight1_musicbox")
	inst.AnimState:PlayAnimation("idle_off", true)

	inst.Transform:SetScale(SCALE, SCALE, SCALE)

	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end

	inst.on = false

	inst:AddTag("kochosei_streetlight1_musicbox")
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

	return inst
end

STRINGS.NAMES[string.upper("kochosei_streetlight1_musicbox")] = "Kochosei streetlight musicbox"
STRINGS.RECIPE_DESC[string.upper("kochosei_streetlight1_musicbox")] = "A beautiful lantern to play music"

return Prefab("kochosei_streetlight1_musicbox", fn, assets),
	MakePlacer(
		"kochosei_streetlight1_musicbox_placer",
		"kochosei_streetlight1_musicbox",
		"kochosei_streetlight1_musicbox",
		"idle_on",
		nil,
		nil,
		nil,
		SCALE
	)
