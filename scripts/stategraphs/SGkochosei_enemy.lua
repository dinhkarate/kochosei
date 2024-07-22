require("stategraphs/commonstates")
local function DetachFX(fx)
	fx.Transform:SetPosition(fx.Transform:GetWorldPosition())
	fx.entity:SetParent(nil)
end

local function DoDespawnFX(inst)
	--shadow_despawn is in the air => detaches from sinking boats
	--shadow_glob_fx is on ground => dies with sinking boats
	local x, y, z = inst.Transform:GetWorldPosition()
	local fx1 = SpawnPrefab("shadow_despawn")
	local fx2 = SpawnPrefab("shadow_glob_fx")
	fx2.AnimState:SetScale(math.random() < 0.5 and -1.3 or 1.3, 1.3, 1.3)
	local platform = inst:GetCurrentPlatform()
	if platform ~= nil then
		fx1.entity:SetParent(platform.entity)
		fx2.entity:SetParent(platform.entity)
		fx1:ListenForEvent("onremove", function()
			DetachFX(fx1)
		end, platform)
		x, y, z = platform.entity:WorldToLocalSpace(x, y, z)
	end
	fx1.Transform:SetPosition(x, y, z)
	fx2.Transform:SetPosition(x, y, z)
end

local function TrySplashFX(inst, size)
	local x, y, z = inst.Transform:GetWorldPosition()
	if TheWorld.Map:IsOceanAtPoint(x, 0, z) then
		SpawnPrefab("ocean_splash_" .. (size or "med") .. tostring(math.random(2))).Transform:SetPosition(x, 0, z)
		return true
	end
end

local function TryStepSplash(inst)
	local t = GetTime()
	if (inst.sg.mem.laststepsplash == nil or inst.sg.mem.laststepsplash + 0.1 < t) and TrySplashFX(inst) then
		inst.sg.mem.laststepsplash = t
	end
end

local function DoSound(inst, sound)
	inst.SoundEmitter:PlaySound(sound)
end

local function NotBlocked(pt)
	return not TheWorld.Map:IsGroundTargetBlocked(pt)
end

local function IsNearTarget(inst, target, range)
	return inst:IsNear(target, range + target:GetPhysicsRadius(0))
end

local function IsLeaderNear(inst, leader, target, range)
	--leader is in range of us or our target
	return inst:IsNear(leader, range) or (target ~= nil and IsNearTarget(leader, target, range))
end

local actionhandlers = {
	ActionHandler(ACTIONS.PICKUP, "pickup"),
	ActionHandler(ACTIONS.CHOP, function(inst)
		if not inst.sg:HasStateTag("prechop") then
			return inst.sg:HasStateTag("chopping") and "chop" or "chop_start"
		end
	end),
	ActionHandler(ACTIONS.MINE, function(inst)
		if not inst.sg:HasStateTag("premine") then
			return inst.sg:HasStateTag("mining") and "mine" or "mine_start"
		end
	end),
	ActionHandler(ACTIONS.DIG, function(inst)
		if not inst.sg:HasStateTag("predig") then
			return inst.sg:HasStateTag("digging") and "dig" or "dig_start"
		end
	end),
	ActionHandler(ACTIONS.ATTACK, function(inst, action)
		inst.sg.mem.localchainattack = not action.forced or nil
		local playercontroller = inst.components.playercontroller
		local attack_tag = playercontroller ~= nil
				and playercontroller.remote_authority
				and playercontroller.remote_predicting
				and "abouttoattack"
			or "attack"
		if
			not (
				inst.sg:HasStateTag(attack_tag) and action.target == inst.sg.statemem.attacktarget
				or inst.components.health:IsDead()
			)
		then
			local weapon = inst.components.combat ~= nil and inst.components.combat:GetWeapon() or nil
			return (weapon == nil and "attack")
				or (weapon:HasTag("blowdart") and "blowdart")
				or (weapon:HasTag("slingshot") and "slingshot_shoot")
				or (weapon:HasTag("thrown") and "throw")
				or (weapon:HasTag("pillow") and "attack_pillow_pre")
				or (weapon:HasTag("propweapon") and "attack_prop_pre")
				or (weapon:HasTag("multithruster") and "multithrust_pre")
				or (weapon:HasTag("helmsplitter") and "helmsplitter_pre")
				or "attack"
		end
	end),
}

local events = {
	CommonHandlers.OnLocomote(true, false),
	CommonHandlers.OnAttacked(),
	CommonHandlers.OnDeath(),
	CommonHandlers.OnHop(),
	CommonHandlers.OnAttack(),
	EventHandler("dance", function(inst)
		if not (inst.sg:HasStateTag("dancing") or inst.sg:HasStateTag("busy")) then
			inst.sg:GoToState("dance")
		end
	end),
	EventHandler("no", function(inst)
		if not (inst.sg:HasStateTag("dancing") or inst.sg:HasStateTag("busy")) then
			inst.sg:GoToState("no")
		end
	end),
}

local states = {

	State({
		name = "pickup",
		tags = { "busy" },
		onenter = function(inst)
			if inst.components.locomotor then
				inst.components.locomotor:StopMoving()
			end
			inst.AnimState:PlayAnimation("pickup")
		end,

		timeline = {
			TimeEvent(5 * FRAMES, function(inst)
				inst:PerformBufferedAction()
			end),
		},

		events = {
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
		},
	}),
	State({
		name = "spawn",
		tags = { "busy", "noattack", "temp_invincible" },

		onenter = function(inst, mult)
			inst.Physics:Stop()
			ToggleOffCharacterCollisions(inst)
			inst.AnimState:PlayAnimation("minion_spawn")

			-- inst.SoundEmitter:PlaySound("maxwell_rework/shadow_worker/spawn")
			mult = mult or 0.8 + math.random() * 0.2
			inst.AnimState:SetDeltaTimeMultiplier(mult)

			mult = 1 / mult
			inst.sg.statemem.tasks = 
{
				inst:DoTaskInTime(0 * FRAMES * mult, DoSound, "maxwell_rework/shadow_worker/spawn"),
				inst:DoTaskInTime(0 * FRAMES * mult, TrySplashFX),
				inst:DoTaskInTime(20 * FRAMES * mult, TrySplashFX),
				inst:DoTaskInTime(44 * FRAMES * mult, TrySplashFX, "small"),
			}
			inst.sg:SetTimeout(70 * FRAMES * mult)
		end,

		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	}),

	State({
		name = "quickspawn",

		onenter = function(inst)
			SpawnPrefab("statue_transition_2").Transform:SetPosition(inst.Transform:GetWorldPosition())
			inst.sg:GoToState("idle")
		end,
	}),

	State({
		name = "quickdespawn",

		onenter = function(inst)
			DoDespawnFX(inst)
			if inst.sg.mem.laststepsplash ~= GetTime() then
				TrySplashFX(inst)
			end
			inst:Remove()
		end,
	}),

	State({
		name = "idle",
		tags = { "idle", "canrotate" },

		onenter = function(inst, pushanim)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("idle_loop", true)
			if inst.components.timer ~= nil and not inst.components.timer:TimerExists("shadowstrike_cd") then
				inst.components.combat:SetRange(5)
			end
		end,
	}),

	State({
		name = "ready_pre",
		tags = { "idle", "canrotate" },

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("ready_stance_pre")
			if inst.components.timer ~= nil and not inst.components.timer:TimerExists("shadowstrike_cd") then
				inst.components.combat:SetRange(5)
			end
		end,

		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("ready")
				end
			end),
		},
	}),

	State({
		name = "ready",
		tags = { "idle", "canrotate" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("ready_stance_loop", true)
		end,

		onupdate = function(inst)
			if not inst.components.combat:HasTarget() then
				inst.sg:GoToState("ready_pst")
			end
		end,
	}),

	State({
		name = "ready_pst",
		tags = { "idle", "canrotate" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("ready_stance_pst")
		end,

		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	}),

	State({
		name = "run_start",
		tags = { "moving", "running", "canrotate" },

		onenter = function(inst)
			inst.components.locomotor:RunForward()
			inst.AnimState:PlayAnimation("run_pre")
		end,

		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("run")
				end
			end),
		},

		timeline = {
			TimeEvent(1 * FRAMES, TryStepSplash),
			TimeEvent(3 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_step")
			end),
		},
	}),

	State({
		name = "run",
		tags = { "moving", "running", "canrotate" },

		onenter = function(inst)
			inst.components.locomotor:RunForward()
			if not inst.AnimState:IsCurrentAnimation("run_loop") then
				inst.AnimState:PlayAnimation("run_loop", true)
			end
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,

		timeline = {
			TimeEvent(5 * FRAMES, TryStepSplash),
			TimeEvent(7 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_step")
				inst.sg.mem.laststepsplash = GetTime()
			end),
			TimeEvent(13 * FRAMES, TryStepSplash),
			TimeEvent(15 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_step")
				inst.sg.mem.laststepsplash = GetTime()
			end),
		},

		ontimeout = function(inst)
			inst.sg.statemem.running = true
			inst.sg:GoToState("run")
		end,

		onexit = function(inst)
			if not inst.sg.statemem.running then
				TryStepSplash(inst)
			end
		end,
	}),

	State({
		name = "run_stop",
		tags = { "canrotate", "idle" },

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("run_pst")
		end,

		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	}),
	State({
		name = "death",
		tags = { "busy" },

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("death")
			inst.components.inventory:DropEverything(true)
		end,

		timeline = {
			TimeEvent(13 * FRAMES, TrySplashFX),
			TimeEvent(38 * FRAMES, TrySplashFX),
		},

		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					DoDespawnFX(inst)
					TrySplashFX(inst)
					inst:Remove()
				end
			end),
		},
	}),

	State({
		name = "hit",
		tags = { "busy" },

		onenter = function(inst)
			inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("hit")
			inst.Physics:Stop()
		end,

		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},

		timeline = {
			TimeEvent(3 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},
	}),

	State({
		name = "stunned",
		tags = { "busy", "canrotate" },

		onenter = function(inst)
			inst:ClearBufferedAction()
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("idle_sanity_pre")
			inst.AnimState:PushAnimation("idle_sanity_loop", true)
			inst.sg:SetTimeout(5)
		end,

		ontimeout = function(inst)
			inst.sg:GoToState("idle")
		end,
	}),

	State({
		name = "chop_start",
		tags = { "prechop", "working" },

		onenter = function(inst)
			local buffaction = inst:GetBufferedAction()
			inst.sg.statemem.target = buffaction ~= nil and buffaction.target or nil

			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("chop_pre")
		end,

		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("chop")
				end
			end),
		},
	}),

	State({
		name = "chop",
		tags = { "prechop", "chopping", "working" },

		onenter = function(inst)
			inst.sg.statemem.action = inst:GetBufferedAction()
			inst.sg.statemem.iswoodcutter = inst:HasTag("woodcutter")
			inst.AnimState:PlayAnimation(inst.sg.statemem.iswoodcutter and "woodie_chop_loop" or "chop_loop")
		end,

		timeline = {
			----------------------------------------------
			--Woodcutter chop

			TimeEvent(2 * FRAMES, function(inst)
				if inst.sg.statemem.iswoodcutter then
					inst:PerformBufferedAction()
				end
			end),

			TimeEvent(5 * FRAMES, function(inst)
				if inst.sg.statemem.iswoodcutter then
					inst.sg:RemoveStateTag("prechop")
				end
			end),

			TimeEvent(10 * FRAMES, function(inst)
				if
					inst.sg.statemem.iswoodcutter
					and inst.components.playercontroller ~= nil
					and inst.components.playercontroller:IsAnyOfControlsPressed(
						CONTROL_PRIMARY,
						CONTROL_ACTION,
						CONTROL_CONTROLLER_ACTION
					)
					and inst.sg.statemem.action ~= nil
					and inst.sg.statemem.action:IsValid()
					and inst.sg.statemem.action.target ~= nil
					and inst.sg.statemem.action.target.components.workable ~= nil
					and inst.sg.statemem.action.target.components.workable:CanBeWorked()
					and inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action)
					and CanEntitySeeTarget(inst, inst.sg.statemem.action.target)
				then
					inst:ClearBufferedAction()
					inst:PushBufferedAction(inst.sg.statemem.action)
				end
			end),

			TimeEvent(12 * FRAMES, function(inst)
				if inst.sg.statemem.iswoodcutter then
					inst.sg:RemoveStateTag("chopping")
				end
			end),

			----------------------------------------------
			--Normal chop

			TimeEvent(2 * FRAMES, function(inst)
				if not inst.sg.statemem.iswoodcutter then
					inst:PerformBufferedAction()
				end
			end),

			TimeEvent(9 * FRAMES, function(inst)
				if not inst.sg.statemem.iswoodcutter then
					inst.sg:RemoveStateTag("prechop")
				end
			end),

			TimeEvent(14 * FRAMES, function(inst)
				if
					not inst.sg.statemem.iswoodcutter
					and inst.components.playercontroller ~= nil
					and inst.components.playercontroller:IsAnyOfControlsPressed(
						CONTROL_PRIMARY,
						CONTROL_ACTION,
						CONTROL_CONTROLLER_ACTION
					)
					and inst.sg.statemem.action ~= nil
					and inst.sg.statemem.action:IsValid()
					and inst.sg.statemem.action.target ~= nil
					and inst.sg.statemem.action.target.components.workable ~= nil
					and inst.sg.statemem.action.target.components.workable:CanBeWorked()
					and inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action)
					and CanEntitySeeTarget(inst, inst.sg.statemem.action.target)
				then
					inst:ClearBufferedAction()
					inst:PushBufferedAction(inst.sg.statemem.action)
				end
			end),

			TimeEvent(16 * FRAMES, function(inst)
				if not inst.sg.statemem.iswoodcutter then
					inst.sg:RemoveStateTag("chopping")
				end
			end),
		},

		events = {
			EventHandler("unequip", function(inst)
				inst.sg:GoToState("idle")
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					--We don't have a chop_pst animation
					inst.sg:GoToState("idle")
				end
			end),
		},
	}),

	State({
		name = "mine_start",
		tags = { "premine", "working" },

		onenter = function(inst)
			local buffaction = inst:GetBufferedAction()
			inst.sg.statemem.target = buffaction ~= nil and buffaction.target or nil

			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("pickaxe_pre")
		end,

		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("mine")
				end
			end),
		},
	}),

	State({
		name = "mine",
		tags = { "premine", "mining", "working" },

		onenter = function(inst)
			local buffaction = inst:GetBufferedAction()
			inst.sg.statemem.target = buffaction ~= nil and buffaction.target or nil

			inst.AnimState:PlayAnimation("pickaxe_loop")
		end,

		timeline = {
			TimeEvent(7 * FRAMES, function(inst)
				local buffaction = inst:GetBufferedAction()
				if buffaction ~= nil then
					PlayMiningFX(inst, buffaction.target)
					inst:PerformBufferedAction()
				end
			end),

			TimeEvent(14 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("premine")
			end),
		},

		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.AnimState:PlayAnimation("pickaxe_pst")
					inst.sg:GoToState("idle", true)
				end
			end),
		},
	}),

	State({
		name = "dig_start",
		tags = { "predig", "working" },

		onenter = function(inst)
			local buffaction = inst:GetBufferedAction()
			inst.sg.statemem.target = buffaction ~= nil and buffaction.target or nil

			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("shovel_pre")
		end,

		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("dig")
				end
			end),
		},
	}),

	State({
		name = "dig",
		tags = { "predig", "digging", "working" },

		onenter = function(inst)
			local buffaction = inst:GetBufferedAction()
			inst.sg.statemem.target = buffaction ~= nil and buffaction.target or nil

			inst.AnimState:PlayAnimation("shovel_loop")
		end,

		timeline = {
			TimeEvent(15 * FRAMES, function(inst)
				inst:PerformBufferedAction()
				inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
			end),

			TimeEvent(35 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("predig")
			end),
		},

		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.AnimState:PlayAnimation("shovel_pst")
					inst.sg:GoToState("idle", true)
				end
			end),
		},
	}),

	State({
		name = "dance",
		tags = { "idle", "dancing" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()
			if inst.AnimState:IsCurrentAnimation("run_pst") then
				inst.AnimState:PushAnimation("emoteXL_pre_dance0")
			else
				inst.AnimState:PlayAnimation("emoteXL_pre_dance0")
			end
			inst.AnimState:PushAnimation("emoteXL_loop_dance0", true)
		end,
	}),
	State({
		name = "chicken",
		tags = { "idle", "dancing" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()
			if inst.AnimState:IsCurrentAnimation("run_pst") then
				inst.AnimState:PushAnimation("emoteXL_loop_dance6")
			else
				inst.AnimState:PlayAnimation("emoteXL_loop_dance6")
			end
			inst.AnimState:PushAnimation("emoteXL_loop_dance6", true)
		end,
	}),

	State({
		name = "no",
		tags = { "idle", "no" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()
			if inst.AnimState:IsCurrentAnimation("run_pst") then
				inst.AnimState:PushAnimation("emoteXL_annoyed")
			else
				inst.AnimState:PlayAnimation("emoteXL_annoyed")
			end
			inst.AnimState:PushAnimation("emoteXL_annoyed", true)
		end,
	}),

	State({
		name = "facepalm",
		tags = { "idle", "facepalm" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()
			if inst.AnimState:IsCurrentAnimation("run_pst") then
				inst.AnimState:PushAnimation("emoteXL_facepalm")
			else
				inst.AnimState:PlayAnimation("emoteXL_facepalm")
			end
			inst.AnimState:PushAnimation("emoteXL_facepalm", true)
		end,
	}),

	State({
		name = "cry",
		tags = { "idle", "cry" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()
			if inst.AnimState:IsCurrentAnimation("run_pst") then
				inst.AnimState:PushAnimation("emoteXL_sad")
			else
				inst.AnimState:PlayAnimation("emoteXL_sad")
			end
			inst.AnimState:PushAnimation("emoteXL_sad", true)
		end,
	}),

	State({
		name = "blowdart",
		tags = { "attack", "notalking", "abouttoattack", "autopredict" },

		onenter = function(inst)
			if inst.components.combat:InCooldown() then
				inst.sg:RemoveStateTag("abouttoattack")
				inst:ClearBufferedAction()
				inst.sg:GoToState("idle", true)
				return
			end
			local buffaction = inst:GetBufferedAction()
			local target = buffaction ~= nil and buffaction.target or nil
			local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			inst.components.combat:SetTarget(target)
			inst.components.combat:StartAttack()
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("dart_pre")
			if inst.sg.laststate == inst.sg.currentstate then
				inst.sg.statemem.chained = true
				inst.AnimState:SetFrame(5)
			end
			inst.AnimState:PushAnimation("dart", false)

			inst.sg:SetTimeout(
				math.max((inst.sg.statemem.chained and 14 or 18) * FRAMES, inst.components.combat.min_attack_period)
			)

			if target ~= nil and target:IsValid() then
				inst:FacePoint(target.Transform:GetWorldPosition())
				inst.sg.statemem.attacktarget = target
				inst.sg.statemem.retarget = target
			end

			if (equip ~= nil and equip.projectiledelay or 0) > 0 then
				--V2C: Projectiles don't show in the initial delayed frames so that
				--     when they do appear, they're already in front of the player.
				--     Start the attack early to keep animation in sync.
				inst.sg.statemem.projectiledelay = (inst.sg.statemem.chained and 9 or 14) * FRAMES
					- equip.projectiledelay
				if inst.sg.statemem.projectiledelay <= 0 then
					inst.sg.statemem.projectiledelay = nil
				end
			end
		end,

		onupdate = function(inst, dt)
			if (inst.sg.statemem.projectiledelay or 0) > 0 then
				inst.sg.statemem.projectiledelay = inst.sg.statemem.projectiledelay - dt
				if inst.sg.statemem.projectiledelay <= 0 then
					inst:PerformBufferedAction()
					inst.sg:RemoveStateTag("abouttoattack")
				end
			end
		end,

		timeline = {
			TimeEvent(8 * FRAMES, function(inst)
				if inst.sg.statemem.chained then
					inst.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_shoot", nil, nil, true)
				end
			end),
			TimeEvent(9 * FRAMES, function(inst)
				if inst.sg.statemem.chained and inst.sg.statemem.projectiledelay == nil then
					inst:PerformBufferedAction()
					inst.sg:RemoveStateTag("abouttoattack")
				end
			end),
			TimeEvent(13 * FRAMES, function(inst)
				if not inst.sg.statemem.chained then
					inst.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_shoot", nil, nil, true)
				end
			end),
			TimeEvent(14 * FRAMES, function(inst)
				if not inst.sg.statemem.chained and inst.sg.statemem.projectiledelay == nil then
					inst:PerformBufferedAction()
					inst.sg:RemoveStateTag("abouttoattack")
				end
			end),
		},

		ontimeout = function(inst)
			inst.sg:RemoveStateTag("attack")
			inst.sg:AddStateTag("idle")
		end,

		events = {
			EventHandler("equip", function(inst)
				inst.sg:GoToState("idle")
			end),
			EventHandler("unequip", function(inst)
				inst.sg:GoToState("idle")
			end),
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			inst.components.combat:SetTarget(nil)
			if inst.sg:HasStateTag("abouttoattack") then
				inst.components.combat:CancelAttack()
			end
		end,
	}),

	State({
		name = "joy",
		tags = { "idle", "joy" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()
			if inst.AnimState:IsCurrentAnimation("run_pst") then
				inst.AnimState:PushAnimation("research")
			else
				inst.AnimState:PlayAnimation("research")
			end
			inst.AnimState:PushAnimation("research", true)
		end,
	}),

	State({
		name = "attack",
		tags = { "attack", "notalking", "abouttoattack", "busy" },

		onenter = function(inst)
			local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

			inst.sg.statemem.target = inst.components.combat.target
			inst.components.combat:StartAttack()
			inst.Physics:Stop()
			if equip ~= nil and (equip.components.projectile ~= nil or equip:HasTag("rangedweapon")) then
				inst.AnimState:PlayAnimation("dart_pre")
				if inst.sg.laststate == inst.sg.currentstate then
					inst.sg.statemem.chained = true
					inst.AnimState:SetFrame(5)
				end
				inst.AnimState:PushAnimation("dart", false)
			else
				inst.AnimState:PlayAnimation("atk")
				-- inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")
			end
			if inst.components.combat.target ~= nil and inst.components.combat.target:IsValid() then
				inst:FacePoint(inst.components.combat.target.Transform:GetWorldPosition())
			end
		end,

		timeline = {
			TimeEvent(8 * FRAMES, function(inst)
				inst.components.combat:DoAttack(inst.sg.statemem.target)
				inst.sg:RemoveStateTag("abouttoattack")
			end),
			TimeEvent(12 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
			TimeEvent(13 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("attack")
			end),
		},

		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	}),

	State({
		name = "jumpout",
		tags = { "busy", "canrotate", "jumping" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("jumpout")
			inst.Physics:SetMotorVel(4, 0, 0)
			inst.Physics:ClearCollisionMask()
			inst.Physics:CollidesWith(COLLISION.GROUND)
		end,

		timeline = {
			TimeEvent(10 * FRAMES, function(inst)
				inst.Physics:SetMotorVel(3, 0, 0)
			end),
			TimeEvent(15 * FRAMES, function(inst)
				inst.Physics:SetMotorVel(2, 0, 0)
			end),
			TimeEvent(15.2 * FRAMES, function(inst)
				inst.sg.statemem.physicson = true
				inst.Physics:ClearCollisionMask()
				inst.Physics:CollidesWith(COLLISION.WORLD)
				inst.Physics:CollidesWith(COLLISION.CHARACTERS)
				inst.Physics:CollidesWith(COLLISION.GIANTS)
			end),
			TimeEvent(17 * FRAMES, function(inst)
				inst.Physics:SetMotorVel(1, 0, 0)
			end),
			TimeEvent(18 * FRAMES, function(inst)
				inst.Physics:Stop()
			end),
		},

		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.physicson then
				inst.Physics:ClearCollisionMask()
				inst.Physics:CollidesWith(COLLISION.WORLD)
				inst.Physics:CollidesWith(COLLISION.CHARACTERS)
				inst.Physics:CollidesWith(COLLISION.GIANTS)
			end
		end,
	}),
}
CommonStates.AddHopStates(states, true, { pre = "boat_jump_pre", loop = "boat_jump_loop", pst = "boat_jump_pst" })

return StateGraph("kochosei_enemy", states, events, "idle", actionhandlers)
