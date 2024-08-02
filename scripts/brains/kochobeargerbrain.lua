require("behaviours/chaseandattack")
require("behaviours/wander")
require("behaviours/doaction")
require("behaviours/follow")
local BrainCommon = require("brains/braincommon")
local SEE_FOOD_DIST = 15
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

local CHOP_MUST_TAGS = { "CHOP_workable" }
local DIG_MUST_TAGS = { "DIG_workable" }

local function FindTreeToChopAction(inst)
	local target = FindEntity(inst, SEE_FOOD_DIST, nil, CHOP_MUST_TAGS)
	if target ~= nil and not target:HasTag("DIG_workable") then
		return BufferedAction(inst, target, ACTIONS.CHOP)
	else
		return false
	end
end

local function FindTreeToDigAction(inst)
	local target = FindEntity(inst, SEE_FOOD_DIST, nil, DIG_MUST_TAGS)
	if target ~= nil and not target:HasTag("CHOP_workable") then
		return BufferedAction(inst, target, ACTIONS.DIG)
	else
		return false
	end
end

local function GetLeaderPos(inst)
    return inst.components.follower.leader:GetPosition()
end

local KochoBeargerBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function KochoBeargerBrain:OnStart()
	local root = PriorityNode({
		ChaseAndAttack(self.inst),
		Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
		DoAction(self.inst, FindTreeToChopAction),
		DoAction(self.inst, FindTreeToDigAction),
		WhileNode(function()
			return GetLeader(self.inst) ~= nil	end, "Has Leader", 
			Wander(self.inst, GetLeaderPos, MAX_FOLLOW_DIST)),
	}, 0.25)

	self.bt = BT(self.inst, root)
end

return KochoBeargerBrain
