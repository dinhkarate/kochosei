local assets_atrium = {
	Asset("ANIM", "anim/stalker_basic.zip"),
	Asset("ANIM", "anim/stalker_action.zip"),
	Asset("ANIM", "anim/stalker_atrium.zip"),
	Asset("ANIM", "anim/stalker_shadow_build.zip"),
	Asset("ANIM", "anim/stalker_atrium_build.zip"),
}

local brain = require("brains/stalkbr")

SetSharedLootTable("dinhcutenhathematroi", {
	{ "fossil_piece", 1.00 },
})

local STALK_CAN_TAGS = { "epic", "_combat", "monster" }
local STALK_CANT_TAGS = { "DECOR", "FX", "INLIMBO", "NOCLICK", "playerghost", "player" }

local function findEnemies(x, y, z)
	local ents = TheSim:FindEntities(x, y, z, 10, STALK_CAN_TAGS, STALK_CANT_TAGS)
end
--------------------------------------------------------------------------

local function OnDoneTalking(inst)
	if inst.talktask ~= nil then
		inst.talktask:Cancel()
		inst.talktask = nil
	end
	inst.SoundEmitter:KillSound("talk")
end

local function OnTalk(inst)
	OnDoneTalking(inst)
	inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/talk_LP", "talk")
	inst.talktask = inst:DoTaskInTime(1.5 + math.random() * 0.5, OnDoneTalking)
end

--------------------------------------------------------------------------

local function OnFocusCamera(inst)
	local player = TheFocalPoint.entity:GetParent()
	if player ~= nil then
		--Also push a priority 5 focus to block the gate (priority 4)
		--from grabbing focus in case we are out of range of stalker.
		TheFocalPoint.components.focalpoint:StartFocusSource(inst, "blockgatefocus", player, math.huge, math.huge, 5)
	else
		TheFocalPoint.components.focalpoint:StopFocusSource(inst, "blockgatefocus")
	end
end

local function OnCameraFocusDirty(inst)
	if inst._camerafocus:value() then
		TheFocalPoint.components.focalpoint:StartFocusSource(inst, nil, nil, 6, 22, 6)
		if inst._camerafocustask == nil then
			inst._camerafocustask = inst:DoPeriodicTask(0, OnFocusCamera)
			OnFocusCamera(inst)
		end
	else
		if inst._camerafocustask ~= nil then
			inst._camerafocustask:Cancel()
			inst._camerafocustask = nil
		end
		TheFocalPoint.components.focalpoint:StopFocusSource(inst)
	end
end

--------------------------------------------------------------------------

--------------------------------------------------------------------------

local function IsNearShadowLure(target)
	return GetClosestInstWithTag("shadowlure", target, TUNING.THURIBLE_AOE_RANGE) ~= nil
end

local function UpdatePlayerTargets(inst, ignorelure)
	local toadd = {}
	local toremove = {}
	local x, y, z = (
		inst.components.entitytracker ~= nil and inst.components.entitytracker:GetEntity("stargate") or inst
	).Transform:GetWorldPosition()
	local inatrium = inst.atriumstalker and inst:IsNearAtrium()

	for k, v in pairs(inst.components.grouptargeter:GetTargets()) do
		toremove[k] = true
	end
	--    for i, v in ipairs(FindPlayersInRange(x, y, z, TUNING.STALKER_DEAGGRO_DIST, true)) do
	--	local v01 = TheSim:FindEntities(x, y, z, TUNING.STALKER_DEAGGRO_DIST, nil, {"character", "structure"}, {"hostile", "epic", "berrythief", "mossling"})
	local v01 = findEnemies(x, y, z, TUNING.STALKER_DEAGGRO_DIST)
	if v01 then
		for i, v in ipairs(v01) do
			if (ignorelure or not IsNearShadowLure(v)) and (not inatrium or inst:IsNearAtrium(v)) then
				if toremove[v] then
					toremove[v] = nil
				else
					table.insert(toadd, v)
				end
			end
		end

		for k, v in pairs(toremove) do
			inst.components.grouptargeter:RemoveTarget(k)
		end
		for i, v in ipairs(toadd) do
			inst.components.grouptargeter:AddTarget(v)
		end
	end
end

--Cave Stalker switches aggro off players easily
local function RetargetFn(inst)
	UpdatePlayerTargets(inst, false)

	local target = inst.components.combat.target
	local targetdistsq, x, y, z
	local hasplayer = false
	local inrange = false
	if target ~= nil then
		local range = TUNING.STALKER_ATTACK_RANGE + target:GetPhysicsRadius(0)
		x, y, z = inst.Transform:GetWorldPosition()
		targetdistsq = target:GetDistanceSqToPoint(x, y, z)
		inrange = targetdistsq < range * range
		--        hasplayer = target:HasTag("player")
		hasplayer = target:HasTag("hostile")
			or target:HasTag("epic")
			or target:HasTag("berrythief")
			or target:HasTag("mossling")
		if hasplayer then
			local newplayer = inst.components.grouptargeter:TryGetNewTarget()
			if
				newplayer ~= nil
				and newplayer:IsNear(
					inst,
					inrange and TUNING.STALKER_ATTACK_RANGE + newplayer:GetPhysicsRadius(0)
						or TUNING.STALKER_KEEP_AGGRO_DIST
				)
			then
				return newplayer, true
			elseif inrange or targetdistsq < TUNING.STALKER_KEEP_AGGRO_DIST * TUNING.STALKER_KEEP_AGGRO_DIST then
				return
			end
		end
	end

	if not hasplayer then
		local nearplayers = {}
		for k, v in pairs(inst.components.grouptargeter:GetTargets()) do
			if
				inst:IsNear(
					k,
					inrange and TUNING.STALKER_ATTACK_RANGE + k:GetPhysicsRadius(0) or TUNING.STALKER_AGGRO_DIST
				)
			then
				table.insert(nearplayers, k)
			end
		end
		if #nearplayers > 0 then
			return nearplayers[math.random(#nearplayers)], true
		end
	end

	--Also needs to deal with other creatures in the world
	local creature = FindEntity(
		inst,
		TUNING.STALKER_AGGRO_DIST,
		function(guy)
			return inst.components.combat:CanTarget(guy)
				and (guy.components.combat:TargetIs(inst) or guy:IsNear(inst, TUNING.STALKER_KEEP_AGGRO_DIST))
		end,
		{ "_combat", "locomotor" }, --see entityreplica.lua -- masttags
		--        { "INLIMBO", "prey", "companion", "player" } -- canttags
		{ "INLIMBO", "prey", "companion", "player", "character" } -- canttags
	)

	return creature ~= nil and (target == nil or creature:GetDistanceSqToPoint(x, y, z) < targetdistsq) and creature
		or nil,
		true
end

local GATE_RANGE = 7 --prefer targets within this range from gate
local function AtriumRetargetFn(inst)
	UpdatePlayerTargets(inst, true)

	local stargate = inst.components.entitytracker:GetEntity("stargate")
	local target = inst.components.combat.target
	local inrange = target ~= nil and inst:IsNear(target, TUNING.STALKER_ATTACK_RANGE + target:GetPhysicsRadius(0))
	local neargate = stargate ~= nil and target ~= nil and stargate:IsNear(target, GATE_RANGE)

	--    if target ~= nil and target:HasTag("player") then
	if
		target ~= nil
		and (
			target:HasTag("hostile")
			or target:HasTag("epic")
			or target:HasTag("berrythief")
			or target:HasTag("mossling")
		)
	then
		local newplayer = inst.components.grouptargeter:TryGetNewTarget()
		return newplayer ~= nil and (not neargate or newplayer:IsNear(stargate, GATE_RANGE)) and newplayer:IsNear(
			inst,
			inrange and TUNING.STALKER_ATTACK_RANGE + newplayer:GetPhysicsRadius(0) or TUNING.STALKER_KEEP_AGGRO_DIST
		) and newplayer or nil,
			true
	end

	local nearplayers = {}
	for k, v in pairs(inst.components.grouptargeter:GetTargets()) do
		if
			(not neargate or k:IsNear(stargate, GATE_RANGE))
			and inst:IsNear(
				k,
				inrange and TUNING.STALKER_ATTACK_RANGE + k:GetPhysicsRadius(0) or TUNING.STALKER_AGGRO_DIST
			)
		then
			table.insert(nearplayers, k)
		end
	end
	return #nearplayers > 0 and nearplayers[math.random(#nearplayers)] or nil, true
end

local function KeepTargetFn(inst, target)
	return inst.components.combat:CanTarget(target)
		and inst:IsNear(target, TUNING.STALKER_DEAGGRO_DIST)
		and not (
			inst._recentattackers[target] == nil
			--                    target:HasTag("player") and
			and (
				target:HasTag("hostile")
				or target:HasTag("epic")
				or target:HasTag("berrythief")
				or target:HasTag("mossling")
			)
			and IsNearShadowLure(target)
		)
end

local function AtriumKeepTargetFn(inst, target)
	return inst.components.combat:CanTarget(target) and (inst:IsNearAtrium(target) or not inst:IsNearAtrium())
end

local function DoNotKeepTargetFn()
	return false
end

--------------------------------------------------------------------------

local CAVE_PHASE2_HEALTH = 0.1

--------------------------------------------------------------------------

local function OnNewTarget(inst, data)
	if data.target ~= nil then
		inst:SetEngaged(true)
		if inst.atriumstalker then
			inst:PushEvent("roar")
		end
	end
end

local function SetEngaged(inst, engaged)
	--NOTE: inst.engaged is nil at instantiation, and engaged must not be nil
	if inst.engaged ~= engaged then
		inst.engaged = engaged
		inst.components.timer:StopTimer("snare_cd")
		if engaged then
			if inst.components.health:GetPercent() > CAVE_PHASE2_HEALTH then
				inst.components.timer:StartTimer("snare_cd", FRAMES, true)
			else
				inst.components.timer:StartTimer("snare_cd", TUNING.STALKER_FIRST_SNARE_CD)
			end
			inst:RemoveEventCallback("newcombattarget", OnNewTarget)
		else
			inst:ListenForEvent("newcombattarget", OnNewTarget)
		end
	end
end

local function AtriumSetEngaged(inst, engaged)
	--NOTE: inst.engaged is nil at instantiation, and engaged must not be nil
	if inst.engaged ~= engaged then
		inst.engaged = engaged
		inst.components.timer:StopTimer("snare_cd")
		inst.components.timer:StopTimer("spikes_cd")
		inst.components.timer:StopTimer("channelers_cd")
		inst.components.timer:StopTimer("minions_cd")
		inst.components.timer:StopTimer("mindcontrol_cd")
		if engaged then
			inst.components.timer:StartTimer("snare_cd", TUNING.STALKER_FIRST_SNARE_CD)
			inst.components.timer:StartTimer("spikes_cd", TUNING.STALKER_FIRST_SPIKES_CD)
			inst.components.timer:StartTimer("channelers_cd", TUNING.STALKER_FIRST_CHANNELERS_CD)
			inst.components.timer:StartTimer("minions_cd", TUNING.STALKER_FIRST_MINIONS_CD)
			inst.components.timer:StartTimer("mindcontrol_cd", TUNING.STALKER_FIRST_MINDCONTROL_CD)
			inst:RemoveEventCallback("newcombattarget", OnNewTarget)
		else
			inst:ListenForEvent("newcombattarget", OnNewTarget)
		end
	end
end

--------------------------------------------------------------------------

local function BattleCry(combat, target)
	local strtbl = target ~= nil
			--        target:HasTag("player") and
			and (
				target:HasTag("hostile")
				or target:HasTag("epic")
				or target:HasTag("berrythief")
				or target:HasTag("mossling")
			)
			and "STALKER_PLAYER_BATTLECRY"
		or "STALKER_BATTLECRY"
	return strtbl, math.random(#STRINGS[strtbl])
end

local function AtriumBattleCry(combat, target)
	local strtbl = target ~= nil
			--        target:HasTag("player") and
			and (
				target:HasTag("hostile")
				or target:HasTag("epic")
				or target:HasTag("berrythief")
				or target:HasTag("mossling")
			)
			and "STALKER_ATRIUM_PLAYER_BATTLECRY"
		or "STALKER_ATRIUM_BATTLECRY"
	return strtbl, math.random(#STRINGS[strtbl])
end

--For searching:
-- STRINGS.STALKER_ATRIUM_SUMMON_MINIONS
-- STRINGS.STALKER_ATRIUM_SUMMON_CHANNELERS
-- STRINGS.STALKER_ATRIUM_USEGATE
-- STRINGS.STALKER_ATRIUM_DECAYCRY
-- STRINGS.STALKER_ATRIUM_DEATHCRY
local function AtriumBattleChatter(inst, id, forcetext)
	local strtbl = "STALKER_ATRIUM_" .. string.upper(id)
	inst.components.talker:Chatter(strtbl, math.random(#STRINGS[strtbl]), 2, forcetext)
end

local function StartAbility(inst, ability)
	inst.components.timer:StartTimer(ability .. "_cd", TUNING.STALKER_ABILITY_RETRY_CD)
end

--For searching:
-- "snare_cd", "spikes_cd", "channelers_cd", "minions_cd"
-- TUNING.STALKER_SNARE_CD
-- TUNING.STALKER_SPIKES_CD
-- TUNING.STALKER_CHANNELERS_CD
-- TUNING.STALKER_MINIONS_CD
local function ResetAbilityCooldown(inst, ability)
	local id = ability .. "_cd"
	local remaining = TUNING["STALKER_" .. string.upper(id)]
		- (inst.components.timer:GetTimeElapsed(id) or TUNING.STALKER_ABILITY_RETRY_CD)
	inst.components.timer:StopTimer(id)
	if remaining > 0 then
		inst.components.timer:StartTimer(id, remaining)
	end
end

local SHARED_COOLDOWNS = {
	"snare",
	"spikes",
	"mindcontrol",
}
local function DelaySharedAbilityCooldown(inst, ability)
	local todelay = {}
	local maxdt = 0
	for i, v in ipairs(SHARED_COOLDOWNS) do
		if v ~= ability then
			local id = v .. "_cd"
			local remaining = inst.components.timer:GetTimeLeft(id) or 0
			maxdt = math.max(maxdt, TUNING["STALKER_" .. string.upper(id)] * 0.5 - remaining)
			todelay[id] = remaining
		end
	end
	for id, remaining in pairs(todelay) do
		inst.components.timer:StopTimer(id)
		inst.components.timer:StartTimer(id, remaining + maxdt)
	end
end

--------------------------------------------------------------------------

local SNARE_OVERLAP_MIN = 1
local SNARE_OVERLAP_MAX = 3
local function NoSnareOverlap(x, z, r)
	return #TheSim:FindEntities(x, 0, z, r or SNARE_OVERLAP_MIN, { "fossilspike", "groundspike" }) <= 0
end

--Hard limit target list size since casting does multiple passes it
local SNARE_MAX_TARGETS = 20
local SNARE_TAGS = { "_combat", "locomotor", "monster" }
local SNARE_NO_TAGS = { "flying", "ghost", "playerghost", "tallbird", "fossil", "shadow", "shadowminion", "INLIMBO" }
local function FindSnareTargets(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local targets = {}
	local priorityindex = 1
	local priorityindex2 = 1
	local inatrium = inst.atriumstalker and inst:IsNearAtrium()
	local ents = TheSim:FindEntities(x, y, z, TUNING.STALKER_SNARE_RANGE + 10, SNARE_TAGS, SNARE_NO_TAGS)
	for i, v in ipairs(ents) do
		if
			not (v.components.health ~= nil and v.components.health:IsDead())
			and (not inatrium or inst:IsNearAtrium(v))
		then
			if
				v:HasTag("hostile")
				or v:HasTag("epic")
				or v:HasTag("berrythief")
				or v:HasTag("monster")
				or v:HasTag("mossling")
			then
				if not IsNearShadowLure(v) then
					table.insert(targets, priorityindex, v)
					priorityindex = priorityindex + 1
					priorityindex2 = priorityindex2 + 1
				end
			elseif v.components.combat:TargetIs(inst) then
				table.insert(targets, priorityindex2, v)
				priorityindex2 = priorityindex2 + 1
			else
				table.insert(targets, v)
			end
			if #targets >= SNARE_MAX_TARGETS then
				return targets
			end
		end
	end
	return #targets > 0 and targets or nil
end

local function SpawnSnare(inst, x, z, r, num, target)
	local vars = { 1, 2, 3, 4, 5, 6, 7 }
	local used = {}
	local queued = {}
	local count = 0
	local dtheta = PI * 2 / num
	local thetaoffset = math.random() * PI * 2
	local delaytoggle = 0
	local map = TheWorld.Map
	for theta = math.random() * dtheta, PI * 2, dtheta do
		local x1 = x + r * math.cos(theta)
		local z1 = z + r * math.sin(theta)
		if map:IsPassableAtPoint(x1, 0, z1) and not map:IsPointNearHole(Vector3(x1, 0, z1)) then
			local spike = SpawnPrefab("fossilspike")
			spike.Transform:SetPosition(x1, 0, z1)

			local delay = delaytoggle == 0 and 0 or 0.2 + delaytoggle * math.random() * 0.2
			delaytoggle = delaytoggle == 1 and -1 or 1

			local duration = GetRandomWithVariance(TUNING.STALKER_SNARE_TIME, TUNING.STALKER_SNARE_TIME_VARIANCE)

			local variation = table.remove(vars, math.random(#vars))
			table.insert(used, variation)
			if #used > 3 then
				table.insert(queued, table.remove(used, 1))
			end
			if #vars <= 0 then
				local swap = vars
				vars = queued
				queued = swap
			end

			spike:RestartSpike(delay, duration, variation)
			count = count + 1
		end
	end
	if count <= 0 then
		return false
	elseif target:IsValid() then
		target:PushEvent("snared", { attacker = inst })
	end
	return true
end

local function SpawnSnares(inst, targets)
	ResetAbilityCooldown(inst, "snare")

	local count = 0
	local nextpass = {}
	local inatrium = inst.atriumstalker and inst:IsNearAtrium()
	for i, v in ipairs(targets) do
		if
			v:IsValid()
			and v:IsNear(inst, TUNING.STALKER_SNARE_MAX_RANGE)
			and (not inatrium or inst:IsNearAtrium(v))
		then
			local x, y, z = v.Transform:GetWorldPosition()
			local islarge = v:HasTag("largecreature")
			local r = v:GetPhysicsRadius(0) + (islarge and 1.5 or 0.5)
			local num = islarge and 12 or 6
			if NoSnareOverlap(x, z, r + SNARE_OVERLAP_MAX) then
				if SpawnSnare(inst, x, z, r, num, v) then
					count = count + 1
					if count >= TUNING.STALKER_MAX_SNARES then
						DelaySharedAbilityCooldown(inst, "snare")
						return
					end
				end
			else
				table.insert(nextpass, { x = x, z = z, r = r, n = num, inst = v })
			end
		end
	end

	if #nextpass > 0 then
		for range = SNARE_OVERLAP_MAX - 1, SNARE_OVERLAP_MIN, -1 do
			local i = 1
			while i <= #nextpass do
				local v = nextpass[i]
				if NoSnareOverlap(v.x, v.z, v.r + range) then
					if SpawnSnare(inst, v.x, v.z, v.r, v.n, v.inst) then
						count = count + 1
						if count >= TUNING.STALKER_MAX_SNARES or #nextpass <= 1 then
							DelaySharedAbilityCooldown(inst, "snare")
							return
						end
					end
					table.remove(nextpass, i)
				else
					i = i + 1
				end
			end
		end
	end

	if count > 0 then
		DelaySharedAbilityCooldown(inst, "snare")
	end
end

--------------------------------------------------------------------------

local CHANNELER_SPAWN_RADIUS = 8.7
local CHANNELER_SPAWN_PERIOD = 1

local function DoSpawnChanneler(inst)
	if inst.components.health:IsDead() then
		inst.channelertask = nil
		inst.channelerparams = nil
		return
	end

	local x = inst.channelerparams.x + CHANNELER_SPAWN_RADIUS * math.cos(inst.channelerparams.angle)
	local z = inst.channelerparams.z + CHANNELER_SPAWN_RADIUS * math.sin(inst.channelerparams.angle)
	if TheWorld.Map:IsAboveGroundAtPoint(x, 0, z) then
		local channeler = SpawnPrefab("kochoshadowchanneler")
		channeler.Transform:SetPosition(x, 0, z)
		channeler:ForceFacePoint(Vector3(inst.channelerparams.x, 0, inst.channelerparams.z))
		inst.components.commander:AddSoldier(channeler)
	end

	if inst.channelerparams.count > 1 then
		inst.channelerparams.angle = inst.channelerparams.angle + inst.channelerparams.delta
		inst.channelerparams.count = inst.channelerparams.count - 1
		inst.channelertask = inst:DoTaskInTime(CHANNELER_SPAWN_PERIOD, DoSpawnChanneler)
	else
		inst.channelertask = nil
		inst.channelerparams = nil
	end
end

local function SpawnChannelers(inst)
	ResetAbilityCooldown(inst, "channelers")

	local count = TUNING.STALKER_CHANNELERS_COUNT
	if count <= 0 or inst.channelertask ~= nil then
		return
	end

	local x, y, z = (inst.components.entitytracker:GetEntity("stargate") or inst).Transform:GetWorldPosition()
	inst.channelerparams = {
		x = x,
		z = z,
		angle = math.random() * 2 * PI,
		delta = -2 * PI / count,
		count = count,
	}
	DoSpawnChanneler(inst)
end

local function DespawnChannelers(inst)
	if inst.channelertask ~= nil then
		inst.channelertask:Cancel()
		inst.channelertask = nil
		inst.channelerparams = nil
	end
	for i, v in ipairs(inst.components.commander:GetAllSoldiers()) do
		if not v.components.health:IsDead() then
			v.components.health:Kill()
		end
	end
end
--------------------------------------------------------------------------

local MINION_RADIUS = 0.3
local MINION_SPAWN_PERIOD = 0.75
local NUM_RINGS = 3
local RING_SIZE = 7.5 / NUM_RINGS
local RING_TOTAL = 1
for i = 2, NUM_RINGS do
	RING_TOTAL = RING_TOTAL + i * i
end

local function DoSpawnMinion(inst)
	local pt = table.remove(inst.minionpoints, math.random(#inst.minionpoints))
	local minion = SpawnPrefab("stalker_minion")
	minion.Transform:SetPosition(pt:Get())
	minion:ForceFacePoint(pt)
	minion:OnSpawnedBy(inst)
	if #inst.minionpoints <= 0 then
		inst.miniontask:Cancel()
		inst.miniontask = nil
		inst.minionpoints = nil
	end
end

--count is specified on load only
local function SpawnMinions(inst, count)
	if count == nil then
		ResetAbilityCooldown(inst, "minions")
		count = TUNING.STALKER_MINIONS_COUNT
	end

	if count <= 0 or inst.miniontask ~= nil then
		return
	end

	--SetMusicLevel(inst, 2)

	local stargate = inst.components.entitytracker:GetEntity("stargate")
	local x, y, z = (stargate or inst).Transform:GetWorldPosition()
	local map = TheWorld.Map
	inst.minionpoints = {}
	for ring = 1, NUM_RINGS do
		local ringweight = ring * ring / RING_TOTAL
		local ringcount = math.floor(count * ringweight + 0.5)
		if ringcount > 0 then
			local delta = 2 * PI / ringcount
			local radius = ring * RING_SIZE
			for i = 1, ringcount do
				local angle = delta * i
				local x1 = x + radius * math.cos(angle) + math.random() - 0.5
				local z1 = z + radius * math.sin(angle) + math.random() - 0.5
				if map:IsAboveGroundAtPoint(x1, 0, z1) then
					table.insert(inst.minionpoints, Vector3(x1, 0, z1))
				end
			end
		end
	end
	if #inst.minionpoints > 0 then
		inst.miniontask = inst:DoPeriodicTask(MINION_SPAWN_PERIOD, DoSpawnMinion, 0)
	else
		inst.minionpoints = nil
	end
end

local function FindMinions(inst, proximity)
	local x, y, z = inst.Transform:GetWorldPosition()
	return TheSim:FindEntities(
		x,
		y,
		z,
		MINION_RADIUS + inst:GetPhysicsRadius(0) + (proximity or 0.5),
		{ "stalkerminion" },
		{ "NOCLICK" }
	)
end

local function EatMinions(inst)
	local minions = FindMinions(inst)
	local num = math.min(3, #minions)
	for i = 1, num do
		minions[i]:PushEvent("stalkerconsumed")
	end
	if not inst.components.health:IsDead() then
		inst.components.health:DoDelta(TUNING.STALKER_FEAST_HEALING * num)
	end
	return num
end

local function OnMinionDeath(inst)
	inst.components.timer:StopTimer("minions_cd")
	inst.components.timer:StartTimer("minions_cd", TUNING.STALKER_MINIONS_CD)
end

--------------------------------------------------------------------------

local function DoSpawnSpikes(inst, pts, level, cache)
	if not inst.components.health:IsDead() then
		for i, v in ipairs(pts) do
			local variation = table.remove(cache.vars, math.random(#cache.vars))
			table.insert(cache.used, variation)
			if #cache.used > 3 then
				table.insert(cache.queued, table.remove(cache.used, 1))
			end
			if #cache.vars <= 0 then
				local swap = cache.vars
				cache.vars = cache.queued
				cache.queued = swap
			end

			local spike = SpawnPrefab("fossilspike2")
			spike.Transform:SetPosition(v:Get())
			spike:RestartSpike(0, variation, level)
		end
	end
end

local function GenerateSpiralSpikes(inst)
	local spawnpoints = {}
	local source = inst.components.entitytracker:GetEntity("stargate") or inst
	local x, y, z = source.Transform:GetWorldPosition()
	local spacing = 1.7
	local radius = 2
	local deltaradius = 0.2
	local angle = 2 * PI * math.random()
	local deltaanglemult = (inst.reversespikes and -2 or 2) * PI * spacing
	inst.reversespikes = not inst.reversespikes
	local delay = 0
	local deltadelay = 2 * FRAMES
	local num = 30
	local map = TheWorld.Map
	for i = 1, num do
		local oldradius = radius
		radius = radius + deltaradius
		local circ = PI * (oldradius + radius)
		local deltaangle = deltaanglemult / circ
		angle = angle + deltaangle
		local x1 = x + radius * math.cos(angle)
		local z1 = z + radius * math.sin(angle)
		if map:IsPassableAtPoint(x1, 0, z1) then
			table.insert(spawnpoints, {
				t = delay,
				level = i / num,
				pts = { Vector3(x1, 0, z1) },
			})
			delay = delay + deltadelay
		end
	end
	return spawnpoints, source
end

local function PlayFlameSound(inst, source)
	source.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/flame")
end

local function SpawnSpikes(inst)
	ResetAbilityCooldown(inst, "spikes")

	local spikes, source = GenerateSpiralSpikes(inst)
	if #spikes > 0 then
		local cache = {
			vars = { 1, 2, 3, 4, 5, 6, 7 },
			used = {},
			queued = {},
		}
		local flames = {}
		local flameperiod = 0.8
		for i, v in ipairs(spikes) do
			flames[math.floor(v.t / flameperiod)] = true
			inst:DoTaskInTime(v.t, DoSpawnSpikes, v.pts, v.level, cache)
		end
		if source ~= nil and source.SoundEmitter ~= nil then
			for k, v in pairs(flames) do
				inst:DoTaskInTime(k, PlayFlameSound, source)
			end
		end

		DelaySharedAbilityCooldown(inst, "spikes")
	end
end

--------------------------------------------------------------------------

local function IsValidMindControlTarget(inst, guy, inatrium)
	if inatrium then
		if not inst:IsNearAtrium(guy) then
			return false
		end
	elseif not inst:IsNear(guy, TUNING.STALKER_MINDCONTROL_RANGE) then
		return false
	end
	return not (guy.components.health:IsDead() or guy:HasTag("playerghost"))
		and guy.components.debuffable:IsEnabled()
		and guy.entity:IsVisible()
end

local function IsCrazyGuy(guy)
	local sanity = guy ~= nil and guy.replica.sanity or nil
	return sanity ~= nil
		and sanity:GetPercentNetworked()
			<= (guy:HasTag("dappereffects") and TUNING.DAPPER_BEARDLING_SANITY or TUNING.BEARDLING_SANITY)
end

--------------------------------------------------------------------------

local function IsNearAtrium(inst, other)
	local stargate = inst.components.entitytracker:GetEntity("stargate")
	return stargate ~= nil and stargate:IsObjectInAtriumArena(other or inst) and stargate:HasTag("intense")
end

local function OnLostAtrium(inst)
	if not inst.components.health:IsDead() then
		inst.atriumdecay = true
		inst.components.health:Kill()
	end
end

local function AtriumLootFn(lootdropper)
	lootdropper:SetLoot(nil)
	if lootdropper.inst.atriumdecay then
		lootdropper:AddChanceLoot("nightmarefuel", 1)
	else
		lootdropper:AddChanceLoot("nightmarefuel", 1)
	end
end

local function AtriumOnEntityWake(inst)
	if inst.sleeptask ~= nil then
		inst.sleeptask:Cancel()
		inst.sleeptask = nil
	end
end

local function OnAtriumDecay(inst)
	inst.sleeptask = nil
	inst:OnLostAtrium()
end

local function OnAtriumOffscreenDeath(inst)
	inst.sleeptask = nil
	if inst.persists then
		inst.persists = false
		local pos = inst:GetPosition()
		if not inst.atriumdecay then
			local flower = SpawnPrefab("flower_rose")
			flower.Transform:SetPosition(pos:Get())
			flower.planted = true
		end
		inst.components.lootdropper:DropLoot(pos)
	end
	inst:Remove()
end

local function CheckAtriumDecay(inst)
	if inst.atriumdecay == nil and inst.components.health:IsDead() then
		inst.atriumdecay = not inst:IsNearAtrium()
	end
	return inst.atriumdecay
end

local function delete()
	stuff = "ancient_altar"
	stuff:Remove()
end

local function AtriumOnDeath2(inst)
	if inst.miniontask ~= nil then
		inst.miniontask:Cancel()
		inst.miniontask = nil
		inst.minionpoints = nil
	end
	if inst.sleeptask ~= nil then
		inst.sleeptask:Cancel()
	end
	inst.sleeptask = inst:IsAsleep() and inst:DoTaskInTime(1, OnAtriumOffscreenDeath) or nil
	SpawnPrefab("ancient_altar").Transform:GetWorldPosition()
	SpawnPrefab("collapse_small").Transform:GetWorldPosition()
	SpawnPrefab("kocho_annoyingstuff_fx").Transform:GetWorldPosition()
	--    DoPeriodicTask(780, delete(), 780)
end

local function AtriumOnDeath(inst)
	if inst.miniontask ~= nil then
		inst.miniontask:Cancel()
		inst.miniontask = nil
		inst.minionpoints = nil
	end
	if inst.sleeptask ~= nil then
		inst.sleeptask:Cancel()
	end
	inst.sleeptask = inst:IsAsleep() and inst:DoTaskInTime(1, OnAtriumOffscreenDeath) or nil
end

local function AtriumOnSave(inst, data)
	data.decay = inst.atriumdecay or nil
	data.channelers = inst.channelerparams
	data.minions = inst.minionpoints ~= nil and #inst.minionpoints or nil
end

local function AtriumOnLoad(inst, data)
	--overwrite atriumdecay if there's any data, otherwise leave it
	if data ~= nil then
		if inst.components.health:IsDead() then
			inst.atriumdecay = data.decay == true
		else
			inst.atriumdecay = nil

			if
				inst.channelertask == nil
				and data.channelers ~= nil
				and data.channelers.x ~= nil
				and data.channelers.z ~= nil
				and data.channelers.angle ~= nil
				and data.channelers.delta ~= nil
				and (data.channelers.count or 0) > 0
			then
				inst.channelerparams = {
					x = data.channelers.x,
					z = data.channelers.z,
					angle = data.channelers.angle,
					delta = data.channelers.delta,
					count = data.channelers.count,
				}
				inst.channelertask = inst:DoTaskInTime(0, DoSpawnChanneler)
			end
		end
	end
end

local function AtriumOnLoadPostPass(inst, ents, data)
	if data ~= nil and not inst.components.health:IsDead() and inst.miniontask == nil and (data.minions or 0) > 0 then
		SpawnMinions(inst, data.minions)
	end
end

--------------------------------------------------------------------------

local function onPeriodicTask(inst)
	local leader = inst.components.follower:GetLeader()
	local combat = inst.components.combat
	if leader and combat and not combat:HasTarget() then
		local target = FindEntity(inst, 20, function(i)
			if i.components.combat and i.components.combat:TargetIs(leader) then
				return true
			end
			return false
		end, { "_combat" })
		if target then
			combat:SetTarget(target)
		end
	end
end

local function m_checkLeaderExisting(inst)
	local leader = inst.components.follower:GetLeader()
	if
		leader ~= nil
		and leader.components.health ~= nil
		and not (leader.components.health:IsDead() or leader:HasTag("playerghost"))
	then
		return
	else
		inst.components.health:Kill()
	end
end

local function OnAttacked(inst, data)
	if data.attacker ~= nil then
		if data.attacker:HasTag("kochoseipet") then
			return
		end
		if data.attacker.components.petleash ~= nil and data.attacker.components.petleash:IsPet(inst) then
			inst.components.health:Kill()
		elseif data.attacker.components.combat ~= nil then
			inst.components.combat:SuggestTarget(data.attacker)
		end
	end
end

local function OnHitOther(inst, other)
	if other and other:HasTag("Kochoseipet") then 
		inst.components.combat:GiveUp()
	end
end
--------------------------------------------------------------------------

local function common_fn(bank, build, shadowsize, canfight, atriumstalker)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddDynamicShadow()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.Transform:SetFourFaced()

	inst.DynamicShadow:SetSize(unpack(shadowsize))

	MakeGiantCharacterPhysics(inst, 1000, 0.75)

	inst.AnimState:SetBank(bank)
	inst.AnimState:SetBuild("stalker_shadow_build")
	inst.AnimState:AddOverrideBuild(build)
	inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:SetScale(0.6, 0.6)

	inst.entity:AddLight()
	inst.Light:SetIntensity(0.6)
	inst.Light:SetRadius(8)
	inst.Light:SetFalloff(3)
	inst.Light:SetColour(200 / 255, 100 / 255, 200 / 255)

	inst:AddTag("epic")
	inst:AddTag("monster")

	inst:AddTag("scarytoprey")

	inst:AddTag("kochoseipet")

	inst:AddTag("fossil")


	if canfight then
		inst:AddComponent("talker")
		inst.components.talker.fontsize = 40
		inst.components.talker.font = TALKINGFONT
		inst.components.talker.colour = Vector3(238 / 255, 69 / 255, 105 / 255)
		inst.components.talker.offset = Vector3(0, -700, 0)
		inst.components.talker.symbol = "fossil_chest"
		inst.components.talker:MakeChatter()
	end

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		if atriumstalker then
			inst:ListenForEvent("camerafocusdirty", OnCameraFocusDirty)
		end

		return inst
	end

	inst.recentlycharged = {}
	--    inst.Physics:SetCollisionCallback(OnCollide)

	inst:AddComponent("inspectable")
	inst.components.inspectable:RecordViews()

	inst:AddComponent("lootdropper")
	--inst.components.lootdropper:SetChanceLootTable("stalker")

	inst:AddComponent("locomotor")
	inst.components.locomotor.pathcaps = { ignorewalls = true }
	inst.components.locomotor.walkspeed = TUNING.STALKER_SPEED

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.STALKER_ALTRIUM_SLAVE_HEALTH)
	inst.components.health.nofadeout = true

	inst:AddComponent("sanityaura")
	--    inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE
	inst.components.sanityaura.aura = -TUNING.SANITYAURA_LARGE

	inst:AddComponent("combat")
	inst.components.combat.hiteffectsymbol = "torso"
	if canfight then
		inst.canfight = true --Need this b4 setting brain

		inst.components.combat:SetDefaultDamage(TUNING.STALKER_ALTRIUM_SLAVE_DAMAGE + TUNING.KOCHOSEI_CHECKWIFI)
		inst.components.combat:SetAttackPeriod(atriumstalker and TUNING.STALKER_ATRIUM_ATTACK_PERIOD or 3)
		inst.components.combat.playerdamagepercent = 0.5
		inst.components.combat:SetRange(TUNING.STALKER_ATTACK_RANGE + 1, TUNING.STALKER_HIT_RANGE + 1)
		inst.components.combat:SetAreaDamage(TUNING.STALKER_AOE_RANGE, TUNING.STALKER_AOE_SCALE)
		inst.components.combat:SetRetargetFunction(3, atriumstalker and AtriumRetargetFn or RetargetFn)
		inst.components.combat:SetKeepTargetFunction(atriumstalker and AtriumKeepTargetFn or KeepTargetFn)
		inst.components.combat.battlecryinterval = 10
		inst.components.combat.GetBattleCryString = atriumstalker and AtriumBattleCry or BattleCry

		inst:AddComponent("grouptargeter")

		inst:AddComponent("timer")

		inst:AddComponent("epicscare")
		inst.components.epicscare:SetRange(TUNING.STALKER_EPICSCARE_RANGE)

		inst._recentattackers = not atriumstalker and {} or nil
		inst.StartAbility = StartAbility
		inst.FindSnareTargets = FindSnareTargets
		inst.SpawnSnares = SpawnSnares
		inst.SetEngaged = atriumstalker and AtriumSetEngaged or SetEngaged
		inst:SetEngaged(false)
	else
		inst.components.combat:SetKeepTargetFunction(DoNotKeepTargetFn)
	end

	inst:AddComponent("explosiveresist")

	if atriumstalker then
		inst.atriumstalker = true --Need this b4 setting brain

		inst:AddComponent("entitytracker")
	end

	inst:SetStateGraph("SGkochosei_stalker")
	inst:SetBrain(brain)

	inst:ListenForEvent("ontalk", OnTalk)
	inst:ListenForEvent("donetalking", OnDoneTalking)

	-- inst.auratest = auratest -- added (Jul/26/2022)

	return inst
end

local function atrium_fn()
	local inst = common_fn("stalker", "stalker_atrium_build", { 4, 2 }, true, true)

	if not TheWorld.ismastersim then
		return inst
	end

	inst.components.lootdropper:SetLootSetupFn(AtriumLootFn)

	inst:AddComponent("commander")

	inst:AddComponent("follower")
	inst.components.follower:KeepLeaderOnAttacked()
	inst.components.follower.keepdeadleader = true
	inst.components.follower.keepleaderduringminigame = true

	inst:DoPeriodicTask(0.5, onPeriodicTask)
	inst:DoPeriodicTask(1, m_checkLeaderExisting)
	inst:ListenForEvent("attacked", OnAttacked)
    inst.components.combat.onhitotherfn = OnHitOther

	--inst:ListenForEvent("stopfollowing", function(inst) inst.components.health:Kill()  end)

	inst.BattleChatter = AtriumBattleChatter
	inst.IsNearAtrium = IsNearAtrium
	inst.IsAtriumDecay = CheckAtriumDecay
	inst.SpawnChannelers = SpawnChannelers
	inst.DespawnChannelers = DespawnChannelers
	inst.SpawnMinions = SpawnMinions
	inst.FindMinions = FindMinions
	inst.EatMinions = EatMinions
	inst.SpawnSpikes = SpawnSpikes
	inst.OnRemoveEntity = DespawnChannelers
	inst.OnEntityWake = AtriumOnEntityWake
	inst.OnSave = AtriumOnSave
	inst.OnLoad = AtriumOnLoad
	inst.OnLoadPostPass = AtriumOnLoadPostPass

	inst:ListenForEvent("miniondeath", OnMinionDeath)
	inst:ListenForEvent("death", AtriumOnDeath)

	return inst
end

STRINGS.NAMES.DINHCUTENHATHEMATROI = "Slave Skeleton"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DINHCUTENHATHEMATROI =
	"Làm ơn đừng crash server anh ơi, đi bộ như bình thường đi, đúng rồi, nó đó..."

return Prefab("dinhcutenhathematroi", atrium_fn, assets_atrium)
