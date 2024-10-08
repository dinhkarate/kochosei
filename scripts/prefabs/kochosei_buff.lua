local buff_prefabs = {
	"wolfgang_coach_buff_fx",
	"cane_rose_fx",
}

local function StopBuff(inst)
	inst.components.debuff:Stop()
end

local function OnDeathEvent(inst, target)
	inst:ListenForEvent("death", function()
		StopBuff(inst)
	end, target)
end

local function ExtendBuff(inst)
	local buffTaskKey = (inst.prefab == "elysia_3_buff" and "bufftask_3")
		or (inst.prefab == "elysia_4_buff" and "bufftask_4")
		or (inst.prefab == "elysia_5_buff" and "bufftask_5")
		or (inst.prefab == "kocho_buff_heal" and "bufftask_heal")
		or "bufftask"

	if inst[buffTaskKey] then
		inst[buffTaskKey]:Cancel()
		local duration = inst.prefab == "elysia_5_buff" and 120 or 60
		inst[buffTaskKey] = inst:DoTaskInTime(duration, StopBuff)
	end
end

local function AttachCommon(inst, target)
	inst.entity:SetParent(target.entity)
	inst.Transform:SetPosition(0, 0, 0)
	OnDeathEvent(inst, target)
end

local function OnAttached(inst, target)
	AttachCommon(inst, target)
	inst.bufftask = inst:DoTaskInTime(60, StopBuff)

	if target and target:IsValid() and target.components.combat then
		local mult = TUNING.WOLFGANG_COACH_BUFF
		target.components.combat.externaldamagemultipliers:SetModifier(inst, mult, "buff_atk_kochosei")
		local fx = SpawnPrefab("wolfgang_coach_buff_fx")
		inst.bufffx = fx
		fx.entity:SetParent(target.entity)
	end
end

local PLANTS_RANGE = 1
local MAX_PLANTS = 18
local PLANTFX_TAGS = {
	"wormwood_plant_fx",
}
local plantpool = {
	1,
	2,
	3,
	4,
}
for i = #plantpool, 1, -1 do
	table.insert(plantpool, table.remove(plantpool, math.random(i)))
end
local function PlantTick(inst)
	if not inst.entity:IsVisible() then
		return
	end
	local x, y, z = inst.Transform:GetWorldPosition()
	if #TheSim:FindEntities(x, y, z, PLANTS_RANGE, PLANTFX_TAGS) < MAX_PLANTS then
		local map = TheWorld.Map
		local pt = Vector3(0, 0, 0)
		local offset = FindValidPositionByFan(math.random() * 2 * PI, math.random() * PLANTS_RANGE, 3, function(offset)
			pt.x = x + offset.x
			pt.z = z + offset.z
			local tile = map:GetTileAtPoint(pt:Get())
			return tile ~= GROUND.ROCKY
				and tile ~= GROUND.ROAD
				and tile ~= GROUND.WOODFLOOR
				and tile ~= GROUND.CARPET
				and tile ~= GROUND.IMPASSABLE
				and tile ~= GROUND.INVALID
				and #TheSim:FindEntities(pt.x, 0, pt.z, 0.5, PLANTFX_TAGS) < 3
				and map:IsDeployPointClear(pt, nil, 0.5)
				and not map:IsPointNearHole(pt, 0.4)
		end)
		if offset ~= nil then
			local plant = SpawnPrefab("wormwood_plant_fx")
			plant.Transform:SetPosition(x + offset.x, 0, z + offset.z)
			-- randomize, favoring ones that haven't been used recently
			local rnd = math.random()
			rnd = table.remove(plantpool, math.clamp(math.ceil(rnd * rnd * #plantpool), 1, #plantpool))
			table.insert(plantpool, rnd)
			plant:SetVariation(rnd)
		end
	end
end

local function OnDetached(inst, target)
	if target and target:IsValid() and target.components.combat then
		target.components.combat.externaldamagemultipliers:RemoveModifier(inst, "buff_atk_kochosei")
	end
	if inst.bufffx and inst.bufffx:IsValid() then
		inst.bufffx:Remove()
	end
	inst.bufffx = nil
	inst:Remove()
end

local function OnAttached_3(inst, target)
	AttachCommon(inst, target)
	inst.bufftask_3 = inst:DoTaskInTime(60, StopBuff)

	if target and target:IsValid() and target.components.combat then
		target:AddDebuff("sweettea_buff", "sweettea_buff")
		target.no_hoa_di = target:DoPeriodicTask(0.25, PlantTick)
		target.components.locomotor:SetExternalSpeedMultiplier(target, "kochosei_speed_mod_ancient", 1.25)
	end
end

local function OnDetached_3(inst, target)
	if target and target:IsValid() and target.components.combat then
		if target.no_hoa_di ~= nil then
			target.no_hoa_di:Cancel()
			target.no_hoa_di = nil
		end
		target.components.locomotor:RemoveExternalSpeedMultiplier(target, "kochosei_speed_mod_ancient")
	end
	inst:Remove()
end

local function OnAttached_4(inst, target)
	AttachCommon(inst, target)
	target.tangst = true
	inst.bufftask_4 = inst:DoTaskInTime(60, StopBuff)
end

local function OnDetached_4(inst, target)
	if target and target:IsValid() then
		local hat = target.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
		if hat and hat.prefab == "kochosei_hatfl" then
			target.tangst = false
		end
	end
	inst:Remove()
end

local function OnAttached_5(inst, target)
	AttachCommon(inst, target)
	inst.bufftask_5 = inst:DoTaskInTime(120, StopBuff)
	target.AnimState:SetScale(2.5, 2.5)
	target.components.health.externalabsorbmodifiers:SetModifier(target, 0.35, "kocho_def_buff_food")
	target.components.hunger:SetMax(999)
	target.components.health:SetMaxHealth(999)
	target.components.sanity:SetMax(999)
	if not target.components.planarentity then
		target:AddComponent("planarentity")
	end
end

local function OnDetached_5(inst, target)
	if target and target:IsValid() then
		target.AnimState:SetScale(1, 1)
		target.components.health:SetMaxHealth(TUNING.KOCHOSEI_HEALTH)
		target.components.hunger:SetMax(TUNING.KOCHOSEI_HUNGER)
		target.components.sanity:SetMax(TUNING.KOCHOSEI_SANITY)
		target.components.health.externalabsorbmodifiers:RemoveModifier(target, "kocho_def_buff_food")
		if target.components.planarentity then
			target:RemoveComponent("planarentity")
		end
	end
	inst:Remove()
end

local function OnAttached_heal(inst, target)
	AttachCommon(inst, target)
	inst.bufftask_heal = inst:DoTaskInTime(5, StopBuff)
	if target.components.health then
		target.components.health:AddRegenSource(target, TUNING.KOCHO_TAMBOURIN_HEAL, 0.5, "heal_from_kochosei")
	end
end

local function OnDetached_heal(inst, target)
	if target and target:IsValid() then
		target.components.health:RemoveRegenSource(target, "heal_from_kochosei")
	end
	inst:Remove()
end

local function common()
	local inst = CreateEntity()

	if not TheWorld.ismastersim then
		inst:DoTaskInTime(0, inst.Remove)
		return inst
	end

	inst.entity:AddTransform()
	inst.persists = false
	inst:AddTag("CLASSIFIED")
	inst:AddComponent("debuff")
	return inst
end

local function create_elysia_buff(onAttached, onDetached)
	local inst = common()
	inst.components.debuff:SetAttachedFn(onAttached)
	inst.components.debuff:SetDetachedFn(onDetached)
	inst.components.debuff:SetExtendedFn(ExtendBuff)
	inst.components.debuff.keepondespawn = true
	return inst
end

return Prefab("elysia_2_buff", function()
	return create_elysia_buff(OnAttached, OnDetached)
end, nil, buff_prefabs),
	Prefab("elysia_3_buff", function()
		return create_elysia_buff(OnAttached_3, OnDetached_3)
	end, nil, buff_prefabs),
	Prefab("elysia_4_buff", function()
		return create_elysia_buff(OnAttached_4, OnDetached_4)
	end, nil, buff_prefabs),
	Prefab("elysia_5_buff", function()
		return create_elysia_buff(OnAttached_5, OnDetached_5)
	end, nil, buff_prefabs),
	Prefab("kocho_buff_heal", function()
		return create_elysia_buff(OnAttached_heal, OnDetached_heal)
	end, nil, buff_prefabs)
