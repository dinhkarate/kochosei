require("behaviours/chaseandattack")
require("behaviours/wander")
require("behaviours/doaction")
require("behaviours/follow")
local BrainCommon = require("brains/braincommon")
local MAX_CHASE_TIME = 8
local GIVE_UP_DIST = 20
local MAX_CHARGE_DIST = 60
local SEE_FOOD_DIST = 15
local SEE_STRUCTURE_DIST = 30
local MIN_FOLLOW_DIST = 0
local TARGET_FOLLOW_DIST = 20
local MAX_FOLLOW_DIST = 20

local function GetFaceTargetFn(inst)
	return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
	return inst.components.follower.leader == target
end

local function GetLeader(inst)
	return inst.components.follower.leader
end

local function InRamDistance(inst, target)
	local target_is_close = inst:IsNear(target, 10)
	if target_is_close then
		return false
	elseif target:IsOnValidGround() then
		-- Our target is on land, and we already know we're far enough away because the above test failed!
		return true
	else
		-- If our target is not on land, they are on a boat or in the water.
		-- In that case, check whether we can stand close enough for them to be within our attack range.
		return CanProbablyReachTargetFromShore(inst, target, TUNING.BEARGER_ATTACK_RANGE - 0.25)
	end
end
local function IsDeciduousTreeMonster(guy)
	return guy.monster and guy.prefab == "deciduoustree"
end

local CHOP_MUST_TAGS = { "CHOP_workable"}
local DIG_MUST_TAGS = { "DIG_workable"}
local function FindDeciduousTreeMonster(inst)
	return FindEntity(inst, SEE_FOOD_DIST / 3, IsDeciduousTreeMonster, CHOP_MUST_TAGS)
end
local function FindTreeToChopAction(inst)
	local target = FindEntity(inst, SEE_FOOD_DIST, nil, CHOP_MUST_TAGS)
	if target ~= nil then
		if inst.tree_target ~= nil then
			target = inst.tree_target
			inst.tree_target = nil
		else
			target = FindDeciduousTreeMonster(inst) or target
		end
		return BufferedAction(inst, target, ACTIONS.CHOP)
	end
end

local function FindTreeToDigAction(inst)
	local target = FindEntity(inst, SEE_FOOD_DIST, nil, DIG_MUST_TAGS)
	if target ~= nil then
		if inst.tree_target ~= nil then
			target = inst.tree_target
			inst.tree_target = nil
		else
			target = FindDeciduousTreeMonster(inst) or target
		end
		return BufferedAction(inst, target, ACTIONS.DIG)
	end
end

local KochoBeargerBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function KochoBeargerBrain:OnStart()
	local root = PriorityNode({
		-- Liz: Removed offscreen behaviour at Jamie's request, pending a solution to repopulate trees & stuff over time.
		-- Also, this will need to be done by a periodic task instead since brain updates don't run when the entity is asleep.
		-- (It does trigger before the entity goes to sleep, so we can probably just have BeargerOffScreen set up its own periodic task)
		--WhileNode(function() return OutsidePlayerRange(self.inst) end, "OffScreen", BeargerOffScreen(self.inst)),

		WhileNode(function()
			return self.inst.cangroundpound
				and self.inst.components.combat.target ~= nil
				and not self.inst.components.combat.target:HasTag("beehive")
				and (
					self.inst.sg:HasStateTag("running") or InRamDistance(self.inst, self.inst.components.combat.target)
				)
		end),
		ChaseAndAttack(self.inst),

		Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
		DoAction(self.inst, FindTreeToChopAction),
		DoAction(self.inst, FindTreeToDigAction),
		WhileNode(function()
			return GetLeader(self.inst) ~= nil
		end, "Has Leader", Wander(self.inst), FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)),
	}, 0.25)

	self.bt = BT(self.inst, root)
end

return KochoBeargerBrain
