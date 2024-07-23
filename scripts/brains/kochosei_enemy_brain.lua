require("behaviours/faceentity")
require("behaviours/chaseandattack")
require("behaviours/follow")
require("behaviours/attackwall")
require("behaviours/leash")
require("behaviours/runaway")

local kochosei_enemy_brain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)
local DIG_TAGS = { "stump", "grave", "farm_debris" }
local MIN_FOLLOW_DIST = 0
local TARGET_FOLLOW_DIST = 6
local MAX_FOLLOW_DIST = 12

local START_FACE_DIST = 6
local KEEP_FACE_DIST = 8


local KITING_DIST = 3
local STOP_KITING_DIST = 5

local KEEP_DANCING_DIST = 4

local KEEP_WORKING_DIST = 14
local SEE_WORK_DIST = 14
local function GetLeader(inst)
	return inst.components.follower.leader
end

local function GetLeaderPos(inst)
	return inst.components.follower.leader:GetPosition()
end

local function GetFaceTargetFn(inst)
	local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
	return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function IsNearLeader(inst, dist)
	local leader = GetLeader(inst)
	return leader ~= nil and inst:IsNear(leader, dist)
end

local function KeepFaceTargetFn(inst, target)
	return not target:HasTag("notarget") and inst:IsNear(target, KEEP_FACE_DIST)
end

local function ShouldKite(target, inst)
	return inst.components.combat:TargetIs(target)
		and target.components.health ~= nil
		and not target.components.health:IsDead()
end

local function DanceParty(inst)
	inst:PushEvent("dance")
end

local function ShouldDanceParty(inst)
	local leader = GetLeader(inst)
	return leader ~= nil and leader.sg:HasStateTag("dancing")
end
local TOWORK_CANT_TAGS = { "fire", "smolder", "event_trigger", "waxedplant", "INLIMBO", "NOCLICK", "carnivalgame_part" }
local function FindEntityToWorkAction(inst, action, addtltags) -- DEPRECATED, use FindAnyEntityToWorkActionsOn.
	local leader = GetLeader(inst)
	if leader ~= nil then
		--Keep existing target?
		local target = inst.sg.statemem.target
		if
			target ~= nil
			and target:IsValid()
			and not (target:IsInLimbo() or target:HasTag("NOCLICK") or target:HasTag("event_trigger"))
			and target:IsOnValidGround()
			and target.components.workable ~= nil
			and target.components.workable:CanBeWorked()
			and target.components.workable:GetWorkAction() == action
			and not (target.components.burnable ~= nil and (target.components.burnable:IsBurning() or target.components.burnable:IsSmoldering()))
			and target.entity:IsVisible()
			and target:IsNear(leader, KEEP_WORKING_DIST)
		then
			if addtltags ~= nil then
				for i, v in ipairs(addtltags) do
					if target:HasTag(v) then
						return BufferedAction(inst, target, action)
					end
				end
			else
				return BufferedAction(inst, target, action)
			end
		end

		--Find new target
		target = FindEntity(leader, SEE_WORK_DIST, nil, { action.id .. "_workable" }, TOWORK_CANT_TAGS, addtltags)
		return target ~= nil and BufferedAction(inst, target, action) or nil
	end
end
function kochosei_enemy_brain:OnStart()
	local root = PriorityNode({

		WhileNode(
			function()
				return IsNearLeader(self.inst, KEEP_WORKING_DIST)
			end,
			"Leader In Range",
			PriorityNode({
				IfNode(
					function()
						return self.inst.prefab == "kochosei_enemy"
					end,
					"Is Duelist",
					PriorityNode({
						WhileNode(
							function()
								return self.inst.components.combat:GetCooldown() > 0.5
									and ShouldKite(self.inst.components.combat.target, self.inst)
							end,
							"Dodge",
							RunAway(self.inst, {
								fn = ShouldKite,
								tags = { "_combat", "_health" },
								notags = { "INLIMBO" },
							}, KITING_DIST, STOP_KITING_DIST)
						),
						ChaseAndAttack(self.inst),
					}, 0.25)
				),
			}, 0.25)
		),
		WhileNode(
			function()
				return ShouldDanceParty(self.inst)
			end,
			"Dance Party",
			PriorityNode({
				Leash(self.inst, GetLeaderPos, KEEP_DANCING_DIST, KEEP_DANCING_DIST),
				ActionNode(function()
					DanceParty(self.inst)
				end),
			}, 0.25)
		),
		Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
		WhileNode(
			function()
				return not self.inst.sg:HasStateTag("phasing") and self.inst.needtostop == 1
			end,
			"Keep Chopping",
			DoAction(self.inst, function()
				return FindEntityToWorkAction(self.inst, ACTIONS.CHOP)
			end)
		),
		WhileNode(
			function()
				return not self.inst.sg:HasStateTag("phasing") and self.inst.needtostop == 1
			end,
			"Keep Mining",
			DoAction(self.inst, function()
				return FindEntityToWorkAction(self.inst, ACTIONS.MINE)
			end)
		),
		WhileNode(
			function()
				return not self.inst.sg:HasStateTag("phasing") and self.inst.needtostop == 1
			end,
			"Keep Digging",
			DoAction(self.inst, function()
				return FindEntityToWorkAction(self.inst, ACTIONS.DIG, DIG_TAGS)
			end)
		),
		--DoAction(self.inst, FindTreeToChopAction),
		WhileNode(function()
			return GetLeader(self.inst) ~= nil
		end, "Has Leader", FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)),
	}, 0.25)

	self.bt = BT(self.inst, root)
end

return kochosei_enemy_brain
