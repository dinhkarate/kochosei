require("prefabutil")

local kochosei_house_assets = {
	Asset("ANIM", "anim/kochosei_house.zip"),
	Asset("SOUND", "sound/kochosei_streetlight1_musicbox.fsb"),
}
-----------------------------------------------------------------------
--For regular tents
local SCALE = 1.5
local music = TUNING.KOCHOSEI_TURNOFFMUSIC

local function TurnOn(inst)
	if inst:HasTag("burnt") then
		inst.components.lootdropper:DropLoot()
		local fx = SpawnPrefab("collapse_big")
		fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
		fx:SetMaterial("wood")
		inst:Remove()
	else
		inst.AnimState:PlayAnimation("idle", true)

		if music ~= nil then
			if music == 1 then
				inst.SoundEmitter:PlaySound(inst.songToPlay, "kochosei_streetlight1_musicbox/play")
			end
		end
		--if not inst:HasTag("burnt") then
		inst:PushEvent("turnedon")

		inst:AddComponent("sanityaura")
		inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL * 1.2
		inst.on = true
		inst.Light:Enable(true)
		inst:AddTag("daylight")
	end
end

local function TurnOff(inst)
	if inst:HasTag("burnt") then
		inst.components.lootdropper:DropLoot()
		local fx = SpawnPrefab("collapse_big")
		fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
		fx:SetMaterial("wood")
		inst:Remove()
	else
		inst.AnimState:PlayAnimation("sleep_loop", true)
		inst.SoundEmitter:KillSound("kochosei_streetlight1_musicbox/play")
		--   inst.SoundEmitter:PlaySound("kochosei_streetlight1_musicbox/end")
		inst:RemoveComponent("sanityaura")
		inst:PushEvent("turnedoff")
		inst.on = false
		inst.Light:Enable(false)
	end
end

local function PlaySleepLoopSoundTask(inst, stopfn)
	inst.SoundEmitter:PlaySound("dontstarve/common/tent_sleep")
	inst.on = true
	inst.Light:Enable(true)
end

local function stopsleepsound(inst)
	if inst.sleep_tasks ~= nil then
		for i, v in ipairs(inst.sleep_tasks) do
			v:Cancel()
		end
		inst.sleep_tasks = nil
	end
end

local function startsleepsound(inst, len)
	stopsleepsound(inst)
	inst.sleep_tasks = {
		inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 33 * FRAMES),
		inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 47 * FRAMES),
	}
end

-----------------------------------------------------------------------

local function onhammered(inst, worker)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
		inst.components.burnable:Extinguish()
		TurnOn(inst)
	end
	inst.components.lootdropper:DropLoot()
	local fx = SpawnPrefab("collapse_big")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	fx:SetMaterial("wood")
	inst:Remove()
end

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
		stopsleepsound(inst)
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("idle", true)
	end
	if inst.components.sleepingbag ~= nil and inst.components.sleepingbag.sleeper ~= nil then
		inst.components.sleepingbag:DoWakeUp()
	end
end

local function onfinishedsound(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/tent_dis_twirl")
end

local function onfinished(inst)
	if not inst:HasTag("burnt") then
		stopsleepsound(inst)
		inst.AnimState:PlayAnimation("destroy")
		inst:ListenForEvent("animover", inst.Remove)
		inst.SoundEmitter:PlaySound("dontstarve/common/tent_dis_pre")
		inst.persists = false
		inst:DoTaskInTime(16 * FRAMES, onfinishedsound)
	end
end

local function onbuilt_kochosei_house(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle", true)
	inst.SoundEmitter:PlaySound("dontstarve/common/tent_craft")
end

local function onignite(inst)
	inst.components.sleepingbag:DoWakeUp()
	inst.components.machine:TurnOff()
end

local function wakeuptest(inst, phase)
	if phase ~= inst.sleep_phase then
		inst.components.sleepingbag:DoWakeUp()
	end
end

local function onwake(inst, sleeper, nostatechange)
	if inst.sleeptask ~= nil then
		inst.sleeptask:Cancel()
		inst.sleeptask = nil
	end

	inst:StopWatchingWorldState("phase", wakeuptest)
	sleeper:RemoveEventCallback("onignite", onignite, inst)

	if not nostatechange then
		if sleeper.sg:HasStateTag("tent") then
			sleeper.sg.statemem.iswaking = true
		end
		sleeper.sg:GoToState("wakeup")
	end

	if inst.sleep_anim ~= nil then
		inst.AnimState:PushAnimation("idle", true)
		stopsleepsound(inst)
	end

	inst.components.finiteuses:Use()
end

local function onsleeptick(inst, sleeper)
	local isstarving = sleeper.components.beaverness ~= nil and sleeper.components.beaverness:IsStarving()

	if sleeper.components.hunger ~= nil then
		sleeper.components.hunger:DoDelta(inst.hunger_tick, true, true)
		isstarving = sleeper.components.hunger:IsStarving()
	end

	if sleeper.components.sanity ~= nil and sleeper.components.sanity:GetPercentWithPenalty() < 1 then
		sleeper.components.sanity:DoDelta(inst.sanity_tick, true)
	end

	if not isstarving and sleeper.components.health ~= nil then
		sleeper.components.health:DoDelta(inst.health_tick * 2, true, inst.prefab, true)
		sleeper.components.health:DeltaPenalty(-0.01)
	end

	if sleeper.components.temperature ~= nil then
		if inst.is_cooling then
			if sleeper.components.temperature:GetCurrent() > TUNING.SLEEP_TARGET_TEMP_TENT then
				sleeper.components.temperature:SetTemperature(
					sleeper.components.temperature:GetCurrent() - TUNING.SLEEP_TEMP_PER_TICK
				)
			end
		elseif sleeper.components.temperature:GetCurrent() < TUNING.SLEEP_TARGET_TEMP_TENT then
			sleeper.components.temperature:SetTemperature(
				sleeper.components.temperature:GetCurrent() + TUNING.SLEEP_TEMP_PER_TICK
			)
		end
	end

	if isstarving then
		inst.components.sleepingbag:DoWakeUp()
	end
end

local function onsleep(inst, sleeper)
	inst:WatchWorldState("phase", wakeuptest)
	sleeper:ListenForEvent("onignite", onignite, inst)

	if inst.sleep_anim ~= nil then
		inst.AnimState:PlayAnimation(inst.sleep_anim, true)
		startsleepsound(inst, inst.AnimState:GetCurrentAnimationLength())
	end

	if inst.sleeptask ~= nil then
		inst.sleeptask:Cancel()
	end
	inst.sleeptask = inst:DoPeriodicTask(TUNING.SLEEP_TICK_PERIOD, onsleeptick, nil, sleeper)
end

local function onsave(inst, data)
	if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
		data.burnt = true
	end
end

local function onload(inst, data)
	if data ~= nil and data.burnt then
		inst.components.burnable.onburnt(inst)
	end
end
local function onburnt(inst)
    inst.SoundEmitter:KillSound("kochosei_streetlight1_musicbox/play")
	inst.AnimState:PlayAnimation("burnt")
    inst:AddTag("burnt")
	inst:RemoveComponent("machine")
	inst:RemoveComponent("sleepingbag")
	inst:RemoveComponent("sanityaura")

end
local function common_fn(bank, build, icon, tag, onbuiltfn)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	inst.entity:AddLight()
	inst.Light:SetIntensity(0.9)
	inst.Light:SetColour(255 / 255, 200 / 255, 255 / 255)
	inst.Light:SetFalloff(0.5)
	inst.Light:SetRadius(7)
	inst.Light:Enable(true) --mac dinh la bat den

	inst.songToPlay = "kochosei_streetlight1_musicbox/play"

	MakeObstaclePhysics(inst, 1)

	inst:AddTag("tent")
	inst:AddTag("structure")
	if tag ~= nil then
		inst:AddTag(tag)
	end

	inst.AnimState:SetBank("kochosei_house")
	inst.AnimState:SetBuild("kochosei_house")
	inst.AnimState:PlayAnimation("idle", true)

	inst.Transform:SetScale(SCALE, SCALE, SCALE)

	inst.MiniMapEntity:SetIcon(icon)

	MakeSnowCoveredPristine(inst)

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

	inst:AddComponent("machine")
	inst.components.machine.turnonfn = TurnOn
	inst.components.machine.turnofffn = TurnOff
	inst.components.machine.cooldowntime = 0

	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetOnFinished(onfinished)

	inst:AddComponent("sleepingbag")
	inst.components.sleepingbag.onsleep = onsleep
	inst.components.sleepingbag.onwake = onwake

	MakeSnowCovered(inst)
	inst:ListenForEvent("onbuilt", onbuiltfn)
    inst:ListenForEvent("onburnt", onburnt)
	MakeLargeBurnable(inst, nil, nil, true)
	inst.components.burnable:SetOnIgniteFn(onignite)
	inst.components.burnable:SetOnBurntFn(onburnt)

	MakeMediumPropagator(inst)

	inst.OnSave = onsave
	inst.OnLoad = onload

	MakeHauntableWork(inst)

	return inst
end

local function kochosei_house()
	local inst = common_fn("kochosei_house", "kochosei_house", "kochosei_house.tex", nil, onbuilt_kochosei_house)

	if not TheWorld.ismastersim then
		return inst
	end

	inst.sleep_phase = "night"
	inst.sleep_anim = "sleep_loop"

	inst.hunger_tick = TUNING.SLEEP_HUNGER_PER_TICK
	inst.sanity_tick = TUNING.SLEEP_SANITY_PER_TICK
	inst.health_tick = TUNING.SLEEP_HEALTH_PER_TICK

	inst.components.finiteuses:SetMaxUses(20)
	inst.components.finiteuses:SetUses(20)

	inst.components.sleepingbag.dryingrate = math.max(0, -TUNING.SLEEP_WETNESS_PER_TICK / TUNING.SLEEP_TICK_PERIOD)

	inst.sanity_tick = 2
	inst.hunger_tick = -2
	inst.health_tick = 2

	return inst
end

STRINGS.NAMES.KOCHOSEI_HOUSE = "Kochosei House"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_HOUSE = "Woahh! My cutest house ( ^ _ ^ )"
STRINGS.RECIPE_DESC.KOCHOSEI_HOUSE = "A cute house of Kochosei, let build it! :3"

return Prefab("kochosei_house", kochosei_house, kochosei_house_assets),
	MakePlacer("kochosei_house_placer", "kochosei_house", "kochosei_house", "anim", nil, nil, nil, SCALE)
